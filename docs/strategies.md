# Loader strategies

## Introduction

In order to support different use cases like interactive loading during development, unattended loading for a continuous integration build, using a specific version name or getting it from the git repository the applications are saved, etc, the _loader_ (a `TonelLoader`) will delegate some actions to, currently, three different strategies, all inheriting from the `TonelLoaderStrategy` class, each of them with an "interactive" and an "unattended" subclass.

* Prerequisites strategy
* Version strategy
* Base edition strategy
* Application naming strategy

By "interactive" whe mean involving the GUI, so, it is opening a dialog, a prompt of some sort, etc. While by "unattended" we mean that if there is a decision to be taken, it will be programmed in the strategy without requiring the display of any GUI element.

The _loader_ will instantiate a separate `TonelApplicationLoader` (aka _application loader_) to load each `Application`, but the strategies are shared among the all the _application loaders_ in the _loader_.

## Prerequisites strategy

When loading an `Application` the _loader_ will read it's prerequisites from the `vaPrerequisites` metadata in the `.package` file, but there could be the case where you need to specify some other prerequisite at load time.

### `TonelLoaderInteractivePrereqStrategy` (interactive)

This strategy will display an `EtPrerequisiteCollectingPrompter` enabling the user to add/remove prerequisites before loading the application

### `TonelLoaderComputedPrerequisitesStrategy` (unattended, default)

This strategy uses the prequisites specified in the metadata plus the ones computed by the loader.

```smalltalk
"Enable it by evaluating"
aTonelLoader useComputedPrerequisites
```

## Version strategy

The version strategy handles both the versioning, and also the creation of editions prior to versioning.

### `TonelLoaderInteractiveVersionStrategy` (interactive)

This will prompt the user to specify a version name _for each application_ using the default version name prompter, leaving the option to not define any, and so only the edition will be created, but without versioning it.

```smalltalk
"Enable it by evaluating"
aTonelLoader useInteractiveVersioning
```

### `TonelLoaderNoVersionStrategy` (unattended, default)

This strategy will create an new edition but won't version it. It is useful when you are developing and want to control manually the versioning and/or don't want to version at all.

```smalltalk
"Enable it by evaluating"
aTonelLoader doNotCreateVersions
```

### `TonelLoaderSpecificVersionStrategy` (unattended)

This strategy will use an specified version name when versioning, if you pass `nil` as the version name, it will behave like the `TonelLoaderNoVersionStrategy`.

```smalltalk
"Enable it by evaluating"
aTonelLoader useSpecifiedVersion: 'DEMO 1.1'
```

### `TonelLoaderGitVersionStrategy` (unattended)

This strategy will read the commit hash, the branch name and the commit date from the `HEAD` of the git repository and use it as the commit.

This strategy can be used only if the folder containing the Tonel files is managed by a git repository and it doesn't need git executables or any shared library, since we directly read the files in the `.git` repository.

```smalltalk
"Enable it by evaluating"
aTonelLoader useGitVersion
```

By default the version name will be something like `e022f87-master (2019-12-30T14:30:00-03:00)`, but you can change the pattern specifing any other `String` that can be expanded using macros (`expandMacrosWith:with:with:`) where the first argument will be the commit hash string, the second the branch name and the third one the branch name.

```smalltalk
"Change the pattern to just the commit hash evaluating"
aTonelLoader versionStrategy versionNamePattern: '<1s>'
```

```smalltalk
"Change the pattern to just the commit hash and branch evaluating"
aTonelLoader versionStrategy versionNamePattern: '<1s> (<2s>)'
```

### Common options

The _loader_ won't create a new edition of a class or subapplication if there are no changes between what's loaded and what being loaded from Tonel. 

To force the creation of new editions, you can set `alwaysCreateEdition` in the version strategy, or directly in the _loader_.

```smalltalk
"Force the creation of editions"
aTonelLoader forceCreationOfEditions
```

## Base edition Strategy

When you're loading an `Application` or `SubApplication` from Tonel sources into your image, if no edition/version of it is loaded from the ENVY Library, and there is an existing version in it, you'll have to chose which version is used as "base" upon which changes will be applied. This is called a "base edition".

When loading the base edition, the application might need to load its prerequisites from the Library, and for that it will delegate the prerequisites loading to the prerequisites strategy defined in the _loader_.

You can also specify whether the lookup of base editions will lookup only for versioned editions, to avoid selecting an edition that might be a draft or broken but that it is more recent than the latest "valid" edition (usually a versioned one).


### `TonelLoaderInteractiveBaseEditionStrategy` (interactive)

This is the default strategy, that will display a list of base editions to choose, and prompt the user to select one from the list.


### `TonelLoaderLatestBaseEditionStrategy` (unattended, default)

This will automatically select the latest (newest) edition as the base edition for the App/Subapp being loaded.

```smalltalk
"Enable it by evaluating"
aTonelLoader useLatestBaseEditions
```

### `TonelLoaderGitParentBaseEditionStrategy` (unattended)

In git repositories, each commit has one or more parent commits, this strategy will try to find a base edition whose versionName matches the parent commit hash (only its first eight characters), and if no edition is found, it will choose the latest one, as in `TonelLoaderlatestBaseEditionStrategy`.

When setting `useGitVersion` in the `TonelLoader`, this base edition strategy will be set as well.

So if you're loading `MyApplication` from a git repository whose commit id is `8c3fa3d` and parent commit is `b78df32`, when loading a base edition it will look for an edition of `MyApplication` in the EM Library whose `versionName` match `b78df32`.

## Naming strategy

### `TonelLoaderDefaultNamingStrategy` (default)

You can specify a prefix for your apps, and a special suffix for applications and subapplications.

E.g.
```smalltalk
aTonelLoader namingStrategy
	appSuffix: 'App';
	subAppSuffix: 'SubApp';
	prefix: 'Et'.
```

This will convert an application otherwise named `Controller` with a subapplication named `Core` into `EtControllerApp` and `EtCoreSubApp`.

**NOTE:** by default no prefix nor suffix is defined.

### Creating your own naming strategy

It is possible to create your own naming strategy by subclassing `TonelLoaderNamingStrategy` and redefining `nameForApp:` and `nameForSubApp:`.

# Common recipes

Below there is a small sample of "recipes" for the common use cases.

## Interactive

Load applications interactively without creating versions

```smalltalk
(TonelLoader readFromPath: (CfsPath named: "...")) 
	beInteractive; "this is redundant, but serves as example"
	doNotCreateVersions;
	loadApplicationsForPackagesNamed: #('Package-Core' 'Package-Tests')
```

## Unattended from git repository

Load applications unattended from a git repository

```smalltalk
(TonelLoader readFromPath: (CfsPath named: "...")) 
	beUnattended;
	useGitVersion;
	loadApplicationsForPackagesNamed: #('Package-Core' 'Package-Tests')
```

## Unattended with specified version name

Load applications unattended with a specified version name.

```smalltalk
(TonelLoader readFromPath: (CfsPath named: "...")) 
	beUnattended;
	useSpecificVersion: 'vX.Y';
	loadApplicationsForPackagesNamed: #('Package-Core' 'Package-Tests')
```

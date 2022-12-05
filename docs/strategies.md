# Loader strategies

## Introduction

In order to support different use cases like interactive loading during development, unattended loading for a continuous integration build, using a specific version name or getting it from the git repository the applications are saved, etc, the _loader_ (a `TonelLoader`) will delegate some actions to, currently, three different strategies, all inheriting from the `TonelLoaderStrategy` class, each of them with an "interactive" and an "unattended" subclass.

There are strategies for the following:
* Package dependency
* Prerequisites
* Base edition selection
* Application naming
* SubApplication mapping
* Versioning
* Configuration Maps Resolution

By "interactive" whe mean involving the GUI, so, it is opening a dialog, a prompt of some sort, etc. While by "unattended" we mean that if there is a decision to be taken, it will be programmed in the strategy without requiring the display of any GUI element.

The _loader_ will instantiate a separate `TonelApplicationLoader` (aka _application loader_) to load each `Application`, but the strategies are shared among the all the _application loaders_ in the _loader_.

There are some options in the _loader_ and the _writer_ that are not implemented as first class strategies, but are included in this document as well for the sake of reference.

## Prerequisites strategy

When loading an `Application` the _loader_ will read it's prerequisites from the `vaPrerequisites` metadata in the `.package` file, but there could be the case where you need to specify some other prerequisite at load time.

### `TonelLoaderInteractivePrereqStrategy` (interactive)

This strategy will display an `EtPrerequisiteCollectingPrompter` enabling the user to add/remove prerequisites before loading the application

### `TonelLoaderComputedPrerequisitesStrategy` (unattended, default)

This strategy uses the prerequisites specified in the metadata plus the ones computed by the loader.

```smalltalk
"Enable it by evaluating"
aTonelLoader useComputedPrerequisites
```

### `TonelLoaderApplicationPrereqsTableStrategy`

This strategy allows to specify mappings between a Tonel package name and ENVY applications that will be set as application prerequisites.

```smalltalk
"Enable it by evaluating"
aTonelLoader useApplicationPrerequisitesTable
  at: 'Seaside-Core' put: #('Kernel' 'GreaseCoreApp')
```

### Common prerequisites strategy options

#### Prerequisites mismatch
There might be the case where the computed prerequisites or the specified prerequisites are redundant after all the classes and application editions have been created, for that, there is the option to fix any mismatch at the end of the load of the application.


```smalltalk
aTonelLoader useApplicationPrerequisitesTable
  at: 'Seaside-Core' put: #('Kernel' 'GreaseCoreApp' 'SUnit');
  fixMismatchs
```

In the example above, `Seaside-Core` should  only depend on `GreaseCoreApp` since this one already depends on `Kernel`, and should not depend on `SUnit` because there is no real dependency to it. So enabling this options will remove redundant or unnecessary  dependencies.

#### Missing prerequisites

The opposite of having redundant prerequisites is the case where the loaded package has no prerequisites defined in the `package.st` file.

If you add extending or creating a subclass of a class not defined in the application being loaded, 
you need to have the application where that extended/subclassed app is defined as a prerequisite of
the app you're loading. 

This mostly happens when the package comes from a Smalltalk dialect other than VAST, because
when you export from VAST it will add the `#vaPrerequisites` metadata to the `package.st` file.

So if you want to control whether to dynamically add missing prerequisites, the prerequisites strategy
provides a setting named `addsMissingPrerequisites` that you can set to either true or false. 

If you don't define such setting it will compute its default value based on whether the application's
package definition (`package.st` file) contains or not the `#vaPrerequisites` metadata. If it contains
such metadata, it means that the prerequisites were already computed when writing the file, so the 
loader won't add them when loading back, so the setting will compute to false.


In case you need to define or override such setting you can do it with the following expression:

```smalltalk
aTonelLoader prerequisitesStrategy addsMissingPrerequisites: true
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

By default the version name will be something like `e022f87-master (2019-12-30T14:30:00-03:00)`, but you can change the pattern specifying any other `String` that can be expanded using macros (`expandMacrosWith:with:with:`) where the first argument will be the commit hash string, the second the branch name and the third one the branch name.

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

In git repositories, each commit has one or more parent commits, this strategy will try to find a base edition whose `versionName` matches the parent commit hash (only its first eight characters), and if no edition is found, it will choose the latest one, as in `TonelLoaderlatestBaseEditionStrategy`.

When setting `useGitVersion` in the `TonelLoader`, this base edition strategy will be set as well.

So if you're loading `MyApplication` from a git repository whose commit id is `8c3fa3d` and parent commit is `b78df32`, when loading a base edition it will look for an edition of `MyApplication` in the EM Library whose `versionName` match `b78df32`.


### `TonelLoaderNoBaseEditionStrategy` (unattended)

This strategy skips choosing an existing edition as base and creates all applications and subapplications from scratch. If you want to avoid loading anything from the library, this is the right strategy to use.

```smalltalk
"Enable it by evaluating"
aTonelLoader doNotUseBaseEditions
```

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

## Package tags and SubApplications strategy

### Introduction
When writing an Application hierarchy, the `TonelWriter` will map each application and subapplication to its own Tonel package, and add the relation between each SubApplication to its children via an [specific metadata](vastspecific.md#application-and-subapplication-hierarchy). This is a feature specific to VAST, since in the canonical version of Tonel there is no such a concept like "SubApplication" or packages hierarchy.

So when reading the applications and subapplications back with `TonelLoader`, the _loader_ will rebuild such hierarchy based on the above described metadata.

However, there is an abstraction used in other dialects, that is not present in the Tonel specification nor its implementation: the "package tag". The package tag or just _tag_, is a way to organize classes in the class browser based on some grouping criteria based on the class category, effectively working as _"virtual sub packages"_.

So the _tags_ introduce a semantic mismatch, because VAST's classes don't have a category at all. What usually is a Package/Tag relation in other dialects is defined as an Application/SubApplication relation in VAST. But VAST also supports Application/SubApplication/SubSubApplication/... organization.

To overcome that, we provide a strategies to map a Package/Tag to Application/SubApplication or simply load a Package in a single Application. And also provide an option to the `TonelWriter` to map Application/SubApplication to Package/Tag when exporting, or to export each SubApplication as a separate Package.

### `TonelLoaderSubapplicationsConditionsMappingStrategy` (default)

This is the default strategy configured in the `TonelLoader` that honors the 1:1 relation between a Package and an Application. 

If you're loading code that was written with the `TonelWriter` (it is, written by VAST to be loaded into VAST), it is the recommended option, since it will also load code based on the conditions defined in each Application/SubApplication.

### `TonelLoaderSubapplicationsTagMappingStrategy`

This strategy will create an Application for the package and one SubApplication for each tag found in the category of classes.

This is recommended if you're loading Tonel code generated from a dialect other than VAST, one that uses Package and _tags_ to organize code.

E.g. For the package `Grease-Core` all classes categorized as `Grease-Core-Utilities` will end up in the `GreaseCoreUtilities` sub application inside the `GreaseCoreApp` application.

Note: This strategy will use the name of the Application (without the `App` suffix) concatenated with the name of the tag to define the name of the sub application. This is so because if used only `Utilities` as the name of the sub application it might collide with other package that also has a `Utilities` tag (i.e. `Grease-Core` / `Utilities` with `Seaside-Core` / `Utilities`).

If you need a more specific naming you can subclassify this strategy.


## Package dependencies strategy

When loading several packages from a Tonel-based repository, there might be some dependency between these packages, and hence dependencies in the Applications that derive from them. Such dependency imposes a load order of the packages, and to simplify the use of the loader and not having to specify the exact load order for a lot loaded packages, the loader will determine which package depends on each other (for the packages within a repository), and attempt to load the dependencies before the actual package.

All the resolved packages dependencies will end up as application prerequisites of the application created from the Tonel package.

NOTE: If the Package was written using the _Tonel Writer_ from VAST, it will include the necessary metadata (it is. `vaPrerequisites:` attribute) to load them.


### `TonelLoaderComputedPackageDependencyStrategy` (default)

This is the default strategy, the _loader_ will walk all the defined classes, extensions and defined methods to determine whether such package depends on another one in the same repository.

### `TonelLoaderPackageDependencyTableStrategy`

If the _computed_ dependency resolver doesn't work for your needs or if the dependency graph is wrong, e.g. because the original packages have cyclic dependencies, you can manually specify the dependencies for each package name.

```smalltalk
"Enable it by evaluating"
aTonelLoader usePackageDependenciesTable
	at: 'Grease-Tests-Core' add: 'Grease-Core'; "adding one"
	at: 'Grease-Core' put: #('Grease-VAST-Core'); "defining all at once".
```

## Configuration Maps resolution

* See specific [Configuration maps documentation](configmaps.md).

## TonelReader options
### Package filtering

Sometimes you simply want to pick a few packages from a repository containing lots of them, so it doesn't make sense to parse the contents of all the package directories just to use a few of them.

To make this process more effective, mostly in terms of speed, you can specify a filtering block that will receive the package name as argument.

```smalltalk
reader := TonelReader new 
            readFrom: aCfsPath
			filtering: [:packageName | 
			  ('*-Core-*') match: packageName ]
			].
```

## TonelLoader options

### Applications "lifecycle" methods

After the load or unload of an `Application` or `SubApplication` into/from the image, there are a few class side methods that are invoked by the ENVY framework to ensure proper initialization or cleanup. The most know and used method is `#loaded`.

The _loader_ provides an option to create such methods for each application and subapplication loaded from source.

```smalltalk
(TonelLoader readFromPath: (CfsPath named: "...")) 
	createsHookMethods: true;
	"..."
```

The `createHookMethods` accessor (initialized to `true` by default) will create such methods. If you're migrating code from a dialect other than VAST you could disable this, and create them manually based on your own needs.

If the code in the repository already have such methods defined, they'll be treated as regular methods, and will be loaded _after_ this hook methods are created, so it's safe to leave this option enabled, since the code from the repository will replace the definition in the image.


### Initialized instances
The default implementation of `new` in VAST doesn't send the `initialize` message to the newly created instance, but in other dialects it does send `initialize`.

So if you need to rely on importing classes and be sure that the instances will be initialized after being created you can set the _loader_ to create a "class-side" `new` that has this behavior.

To enable this feature, you can do:

```smalltalk
(TonelLoader readFromPath: (CfsPath named: "...")) 
   autogenerateInstanceInitializers: true
```

This option is `false` by default.




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

## Map package tags to sub applications

```smalltalk
(TonelLoader readFromPath: (CfsPath named: "...")) 
	mapTagsToSubapplications; "<-- convenience method"
	loadApplicationsForPackagesNamed: #('Package-Core' 'Package-Tests')
```

# Tonel Writer options

Please read the specific [Tonel Writer](writer.md) documentation.
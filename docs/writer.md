## TonelWriter options

### Writing sub applications as package tags

If when writing you want to perform the opposite step of the `TonelLoaderSubapplicationsTagMappingStrategy`, then you can configure the _writer_ to flatten sub applications and map them as package tags.

```smalltalk
writer := TonelWriter new.
writer flattenSubApplications: true.
```

NOTES: Since there is no "class category" in VAST classes the package tag is going to be computed based on the root application #tonelPackageName and the SubApplication name.

E.g. For an Application named `GreaseCoreApp` with the `GreaseCoreUtilities` and `GreaseCoreExceptions` sub applications, it will attempt to find remove the application name from the subapplication name (with or without the `App` suffix), and the resulting string is going to be used as the package tag. In this case it will remove `GreaseCore` from `GreaseCoreExceptions` and produce `Exceptions` as the package tag.

### Writing out `Application` and `SubApplications` subclasses

`Applications` and `SubApplication` subclasses have a dual purpose: to work as a "package" that works as container to class definitions and extensions in ENVY, and as a regular class that manage the lifetime of the app/sub app loading, initialization, etc.

So when exporting your `Application` subclass (e.g. `MyApplication`) it will export a class definition for it, with `Application` as its superclass. If your plan is to load it back into VAST, then that's totally fine, and the desired behavior, but if your intention is to export to another dialect you either have to have `Application` and `SubApplication` defined in such dialect (as some  dialect compatibility package) or to omit the writing of such classes altogether.

So if you want to omit the write of ENVY app/subapp classes you can do:

```smalltalk
writer := TonelWriter new.
writer writeENVYApps: false.
```

By default the writer is configured to write the ENVY app/subapps, so if that's your intention you don't have to do anything special.

### Identifiers
Tonel, the file format, has a loose specification, and in some dialects it uses Symbols for its identifiers and in others it uses Strings because in not all the dialects aString = aSymbol.

So to avoid having file differences when working on code that share a common repository you can configure the `TonelWriter` to use Symbols or Strings for its identifiers.

```smalltalk
writer := TonelWriter new.
writer identifiersClass: Symbol.
```
### _Monticello_ extension methods

Before extension methods had first-class support in other dialects, the Monticello packaging format established a convention to define them using the method category as a hint to the package system. So if you want to extend the class `Object` in the package `MyPackage` you'd do it by adding the extension method to the `*MyPackage`. 

So if you want to avoid writing extension methods with such _"weird"_ names, you can disable them, and the `TonelWriter` will write the existing VAST category as the method category, instead of that.

```smalltalk
writer := TonelWriter new.
writer useMonticelloExtensions: false.
```


### Format convenience settings

#### _"Canonical"_ format

If your objective is to export code to be used in another dialect, you can set different options as a whole like [converting shared pools](sharedpools.md) to `SharedPools` subclasses, not writing ENVY Application classes, using the Monticello extension category (as in `*PackageName` category) and will flatten SubApplications (if any) as package tags.

```smalltalk
writer := TonelWriter new.
writer beCanonical.
```
#### _"VAST Only"_ format

If the purpose of using Tonel Tools in VAST is to export code to files to be loaded back into VAST, then you can optimize a lot of settings by configuring the writer to write the files to be read only by VAST's Tonel Tools.

```smalltalk
writer := TonelWriter new.
writer beVASTOnly.
```


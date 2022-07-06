# Configuration Maps

## Introduction

Configuration Maps (aka _config maps_) are an unique VAST Artifact to precisely define which Applications and prerequisites (other Configuration Maps) are going to be loaded as a whole, providing a reliable dependency management solution.

Unfortunately, Tonel doesn't define any similar artifact nor _type_ that we could leverage to provide similar features.

## Solution

In order to provide an artifact that is human readable (and friendly with a file based source control system) all configuration maps will be written to a single `.configmaps` file in STON syntax along Tonel's `.properties` file in the sources directory. So if you choose to write more than one config map, all of them will be written to that single file.

The rationale to have a single file instead of several ones is that config maps can have names with spaces or other special characters (`/`, `#`, etc.) that would require special handling on the filesystem. 

## Writing Configuration Maps to disk

The `TonelWriter` in addition to the list of Applications that will be written as Tonel packages, has a separate list of configuration maps, where **only one version of each config map is allowed**, each configuration map must be an instance of _EmConfigurationMap_.

You can add a config map to the writer as follows
```smalltalk
writer := TonelWriter new.
writer addConfigurationMap: (EmConfigurationMap editionsFor: 'Tonel') first.
```
Or
```smalltalk
writer := TonelWriter new.
writer addConfigurationMapNamed: 'Tonel' versionName: '1.61'.
```
Or just use the latest in the Library
```smalltalk
writer := TonelWriter new.
writer addLatestConfigurationMapNamed: 'Tonel'.
```


The addition of a config map to the _writer_ is separate from the addition of its applications, but to avoid having to lookup each app you could send `#addApplicationsFromConfigurationMaps` to the writer, which will lookup all the applications in the config map, and add them to the writer.

```smalltalk
writer := TonelWriter new.
writer addConfigurationMapNamed: 'Tonel' versionName: '1.61'.
writer addApplicationsFromConfigurationMaps.
```

This will produce the a `.configmaps` file with the following STON content:

```smalltalk
[
	{
		#formatVersion : '1.1',
		#name : 'Tonel',
		#versionName : '1.61',
		#ts : 3767592545,
		#comment : '',
		#applications : OrderedCollection [
			{
				#name : 'AbtShellProgramStarterApp',
				#versionName : '1.0',
				#ts : 3762611357
			},
			{
				#name : 'TonelBaseApp',
				#versionName : '1.1',
				#ts : 3762002743
			},
			{
				#name : 'TonelFileSystem',
				#versionName : '1.23',
				#ts : 3758350880
			},
			{
				#name : 'TonelLoaderModel',
				#versionName : '1.67',
				#ts : 3767591460
			},
			{
				#name : 'TonelReaderModel',
				#versionName : '1.50',
				#ts : 3765716956
			},
			{
				#name : 'TonelTools',
				#versionName : '1.13',
				#ts : 3767528479
			},
			{
				#name : 'TonelWriterModel',
				#versionName : '1.57',
				#ts : 3767541102
			}
		],
		#conditions : [
			{
				#condition : 'true',
				#requiredMaps : [
					{
						#name : 'z.ST: STON Support',
						#versionName : 'V 9.2.1  [457]',
						#ts : 3761144594
					}
				]
			}
		]
	}
]
```

### Autoloading

If you attempt to write a Configuration Map that isn't loaded in the image, by default `TonelWriter` will attempt to load it first (and its required maps).

If you want to disable this behavior, you can do it by evaluating:
```smalltalk
aTonelWriter autoLoad: false
```

With the autoloading disabled, if you attempt to write a Configuration Map, an exception will be raised.

## Loading Configuration Maps from disk

The load of configuration maps from disk is straighfoward.

Following the above written config map you should only send `#loadAllMapsWithRequiredMaps` to the _TonelLoader_ and it will automatically load the applications and required maps.

```smalltalk
loader := TonelLoader readFromPath:  ((CfsPath named: CfsDirectoryDescriptor getcwd) append: 'tonel-vast').
loader beUnattended; useSpecifiedVersion: '1.40'.
loader loadAllMapsWithRequiredMaps.
```

### How dependency lookup is performed

When loading a Configuration Map the _TonelLoader_ will first search for any matching edition in the Tonel repository and if not found then it will search it up in the ENVY Library. If no edition is found in neither of these, and error will be thrown.

All applications of the Configuration Map read from disk are expected to be in the Tonel repository as well, so there is currently no way to load just the configuration map from disk and the applications from the EM Library.

**NOTE**: On its binary format (within the ENVY Library or when exported as `.dat` file) the configuration maps refer to appplications and prerequisites using their internal timestamp, and Tonel will use that first to lookup their prerequisites or an existing map with the same timestamp in the repository.

### Loading required maps

When loading required maps for maps defined in a Tonel repository, there are going to be two kinds of required maps: those that are defined in the repository (e.g. from Test to the core), and those that are external configuration maps, that are expected to be available in the ENVY Library. We call the later, "references" (represented by the class `TonelEmConfigurationMapReference`).

As in the UI of the Configuration Maps Browser, sometimes you want to load the map together with its required maps, and 
in some other cases you just want to load the map without the required maps, because you already have them (or its Applications) in the image.

To mimic that UI behavior, the `TonelLoader` has a boolean property called `loadsRequiredMaps` which, as you might guess
will instruct the loader to load the map and the required maps. This property is set to `true` by default.


```smalltalk
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader
	loadsRequiredMaps: true;
	loadAllConfigurationMaps.

"Or its equivalent version"
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader loadAllMapsWithRequiredMaps.
```

Or the option to NOT LOAD the required maps:
```smalltalk
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader
	loadsRequiredMaps: false;
	loadAllConfigurationMaps.

"Or its equivalent version"
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader loadAllMapsWithoutRequiredMaps.
```

This setting will be honored only for those configuration maps that are "references", it is, those that are not defined within the Tonel Repository.

E.g. If you have `Config Map A` and `Config Map B` in the repository, and `Config Map B` has `Config Map A` and `Config Map C` as prerequisites, if you setup the loader to not load maps prerequisites, when loading `Config Map B` it still will load `Config Map A`, because it is defined in the same repository.


## Configuration Maps resolution

When you define a Configuration Map it will likely have required maps, and those maps are defined within a loading condition (`true` by default in  most cases), and each required map will be referenced by its timestamp (the internal ID used by the ENVY Library).

When working using file based repositories it's also very likely that different developers will have the same _"code"_ (Applications and Configuration Maps) but with different timestamps, so some required maps will be shown as _`missing`_ in the Configurations Maps Browser.

To overcome the situation described above the Tonel Tools provide different strategies to resolve the referenced Configuration Maps when looking for a configuration map.

Taking the example above, we extract this small part related with the definition of a required map (`z.ST: STON Support`):

```smalltalk
	#requiredMaps : [
		{
			#name : 'z.ST: STON Support',
			#versionName : 'V 9.2.1  [457]',
			#ts : 3761144594
		}
	]
```

In the required maps definition, you can see that each reference includes its name, its version name and its timestamp.


### `TonelLoaderConfigMapResolverByVersion` (default)

This strategy will attempt to find and load a configuration map that matches both the timestamp or version name (if no matching timestamp is found).

If you want the resolution to match only timestamp, then you can do:

```smalltalk
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader
	configMapResolver beExact; "<< this message"
	loadAllConfigurationMaps.
```

If no configuration map is found, then an exception will be thrown.


### `TonelLoaderConfigMapResolverLatest`

This strategy will load the latest configuration map available in the library that matches the name of the required map. It works in an optimistic way and it is very convenient during development, since most configuration maps are backwards compatible, so for instance in the example above loading `z.ST: STON Support` in its latest version (e.g. `11.0.0`) will not break code developed with the previous version (e.g. `9.2.2`).

To enable this configuration map you can do the following:

```smalltalk
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader
	resolveToLatestConfigMaps; "<< this message"
	loadAllConfigurationMaps.
```

Since it will bring the very latest edition of the config map, you can restrict it to only look for editions with a version name by doing:


```smalltalk
loader := TonelLoader readFromPath: (CfsPath named: '...').
loader resolveToLatestConfigMaps.

loader configMapResolver versionedEditionsOnly: true.
loader loadAllConfigurationMaps.
```

Which is very useful if you have a "stable" version and one or more open editions created after it.
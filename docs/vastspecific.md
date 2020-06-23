## VAST specific features

Since Tonel wasn't designed with VAST use in mind, some features are not supported by the spec and we needed to extend it to support them. We describe such features below.

Some of these features affect interoperability with other dialects and only a few affect VAST-only use of Tonel.

### Multiple method categories

Since VAST supports multiple categories per method (not just one), when writing Tonel from VAST if the method has more than one category in addition to the `#category` property containing a single category name, we add a custom `#vaCategories` property to the method definition metadata whose value is an array of category names.

This way, when loading methods from source code, single method categories dialects will read only the `#category` property and the VAST Tonel loader will look for the `vaCategories` (if available).

### Private and Public methods

In VAST method visibility is not a simple category convention but a boolean property of the method itself, so methods can be treated as `private` or `public` and the tools will accommodate to this accordingly.

To support this feature we added a `#vaVisibility` property to the method definition metadata whose value is a string containing either `public` or `private` values.

When reading code if this property is not present, the method will use `public` visibility by default.


### Application prerequisites

VAST Applications have prerequisites, that are the dependencies on other applications. Such concept is absent from the Tonel spec that only has the concept of _Package_ and dependency is managed elsewhere.

We fulfill this need by adding a custom property named  `#vaPrerequisites` to the package definition file (`.package`) whose value is an array containing the names of the prerequisites.


### Application and SubApplication hierarchy

VAST Applications can contain SubApplications, and these SubApplications can contain other SubApplications forming a composition tree, each node in the hierarchy conditioning the load of the sub applications to some condition (aka _config expression_, more on this later).

Such hierarchy of composition concept is not considered by the original Tonel spec, and for Tonel everything is just a _Package_ on a flat level.

To work around this we map each _Application_ or _Subapplication_ to a _Package_ and write them at the same flat level, also adding VAST specific properties to the package metadata definition. In addition, since the composition depends on some _config expression_ (a Smalltalk expression that returns a boolean) we store the expression and the SubApplications it would load as as a `#vaSubapplications` property as follows:

 ```smalltalk
#vaSubApplications : [
  	{
		    #condition : '(System subsystemType: #OS) = ''WIN32s''',
		    #subapps : [
     		'SomeWindowsSpecificApp'
	    ]
   }
 	]
 ```

For the most cases the config expression is just `true` meaning the sub applications will always load.

 ```smalltalk
#vaSubApplications : [
  {
		  #condition : 'true',
		  #subapps : [
			   'TonelExampleAnotherSubSubApp',
			   'TonelExampleSubSubApp'
		  ]
  }
]
 ```

Also, in the case of _SubApplications_ they will contain the name of parent _Application_ or _SubApplication_ using the property `#vaParent`, whose value will be the name of the _Application_ or _SubApplication_ in VAST and the name of the Tonel _Package_.
'TonelExampleApp'.

So extending our example above for the [sample subapp](https://github.com/vasmalltalk/tonel-demos/blob/master/source/TonelExampleSubApp/package.st)

 ```smalltalk
#vaParent: 'TonelExampleApp',
#vaSubApplications : [
  {
		  #condition : 'true',
		  #subapps : [
			   'TonelExampleAnotherSubSubApp',
			   'TonelExampleSubSubApp'
		  ]
  }
]
 ```

### Shadow SubApplications Limitation

When an _Application_ or _SubApplication_ has different branches of SubApplications based on different _config expressions_ the SubApplications in the branch that is not loaded in the image are called _shadow_ SubApplications. The typical example is some OS-specific features that are loaded based on the OS in which the image is running (e.g. UNIX vs Windows).

The current implementation of Tonel Writer for VAST fully supports writing the conditions and SubApplications to disk, but the Tonel Loader will only compile and create editions for the applications whose _config expressions_ are _valid_ (it is, that evaluates to _true_).

So if you now write an existing _Application_ with shadow _SubApplications_ they will be written to disk, but once you load them back, the shadowed ones will not be loaded (and hence not versioned in the ENVY Library).
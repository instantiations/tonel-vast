<p align="center">
 <h1 align="center">Tonel for VASmalltalk</h1>
  <p align="center">
    Providing git friendly file format support to VASmalltalk
    <!---
    <br>
    <a href="docs/"><strong>Explore the docs »</strong></a>
    <br>
    -->
    <br>
    <a href="https://github.com/vasmalltalk/tonel-vast/issues/new?labels=Type%3A+Defect">Report a defect</a>
    |
    <a href="https://github.com/vasmalltalk/tonel-vast/issues/new?labels=Type%3A+Feature">Request feature</a>
  </p>
</p>

For [Instantiations](https://www.instantiations.com/) and VASmalltalk, having git support is a priority. The first step is to have a Tonel format writer and reader.

[Tonel](https://github.com/pharo-vcs/tonel) is the current file format widely accepted by the Smalltalk community to store source code on disk for a friendly VCS like Git.

## License
- The code is licensed under [MIT](LICENSE).
- The documentation is licensed under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/).


## Installation

- Download the [9.2 ECAP 2 or newer from Instantiations](https://www.instantiations.com/ecap/).
- Clone this repository.
- From the configuration map browser, import all versions of the `Tonel` map from `envy/Tonel.dat`. Then "Load With Required Maps" the latest version of it.
- Run SUnit Suite for all `Tonel` map (right click on the map -> `Test Loaded Applications`). You should see around 58 unit tests and most of them passing.
- Explore the [documentation](docs/).


## Quick Start

- Open Application Manager and try the menu option "Import/Export" -> "Import Applications from Tonel packages..." and "Export Applications as Tonel packages..."
<img width="500" alt="Import/Export" src="https://user-images.githubusercontent.com/1032834/64197391-621ea780-ce5c-11e9-8312-55994d01f68e.png">
- Or..you can do it from code too:

```smalltalk
(TonelLoader
 on: (TonelReader new readPackagesFrom:
   ((CfsPath named: CfsDirectoryDescriptor getcwd) append: '..\TonelRepositories\tonel-demos')))
     loadApplicationNamed: 'TonelExampleApp'.
TonelWriter new writeInWorkingDirectoryProjectIncluding: (Array with: TonelExampleApp)
"WARNING: This deletes everything in the target directory."
TonelWriter new
 writeProjectIncluding: (Array with: TonelTestPackageAApp)  
 into: ((CfsPath named: CfsDirectoryDescriptor getcwd) append: '..\TonelRepositories\tonel-demos').
 ```

## Tonel for VA in a Nutshell

 Supporting the [Tonel format](https://github.com/pharo-vcs/tonel) is a work in progress for VA 9.2. Our implementation tries to satisfy as much as possible the spec. However, the spec didn't take into account some important VA-specific features. Below is the list of differences and how they were accomplished in VA:

 - VA supports multiple categories per method (not just one). Solution: add custom `#vaCategories:` key to method definition whose value is an array of categories.
 - VA supports `private` vs `public` methods. Solution: add custom `#vaVisibility` key to method definition whose value is a string.
 - VA applications define prerequisites (dependencies on other applications). Therefore, we must store this information on Tonel in order to be able to import correctly. Solution: add custom key `#vaPrerequisites:` in package definition whose value is an array of the prereqs.
 - In VA, applications can define subapplications that should be loaded whenever an associated `config expression` (Smalltalk code) answers `true`. The fact of having conditional loading (config expression) means that a current loaded root app may have some `shadow` subapps, which are subapps that haven't been loaded because the config expression for it answered `false`. However, when we are versioning code, we always want to version all of the subapps, whether they are shadow or not. Solution: add custom key `#vaSubApplications:` to package definition whose value is an array of arrays. The inner array is tuple where the first element is the config expression and the second element is an array of all the apps associated to it. Example:
 ```smalltalk
 	#vaSubApplications : [
 		[ '(Smalltalk at: #\''TonelExampleConfExp\'' ifAbsentPut: [true] ) == false', [ 'TonelExampleShadowSubSubApp','TonelAnotherShadowSubSubApp']],
 		[ '(Smalltalk at: #\''TonelExampleConfExp\'' ifAbsentPut: [true] ) == true', [ 'TonelExampleSubSubApp','TonelExampleAnotherSubSubApp']]
 	]
 ```
 - Subapplications may also have sub sub applications up to level N. Solution: instead of having all tonel definitions in one root directory containing a `package.st`, allow a directory having subdirectories mapping subapplications, each having its own `package.st`.

 > **Important**: Note that the last solution mentioned above to support N levels of subapps is *not* compatible with ANSI Tonel spec. Of course, it will be able to be imported by Tonel on VA but not on another dialect. The conclusion is: if you want to be cross-dialect compatible, then you can't use subapps. if you use subapps, you will be able to import only in VA.

## Examples and Demos
There is a [whole Github project](https://github.com/vasmalltalk/tonel-demos/) that contains demos about Tonel integration with VASmalltalk.


## Acknowledgments

- [Mercap Software](https://github.com/Mercap) for their first draft on the Tonel writer
- Github repository layout was generated with [Ba-St Github-setup project](https://github.com/ba-st/GitHub-setup).


## Contributing

Check the [Contribution Guidelines](CONTRIBUTING.md)

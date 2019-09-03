<p align="center">
 <h1 align="center">Tonel for VASmalltalk</h1>
  <p align="center">
    What is this thing? “the motto” and the goals. The vision.
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
- You can do it from code:
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


## Acknowledgments

- [Mercap Software](https://github.com/Mercap) for their first draft on the Tonel writer
- Github repository layout was generated with [Ba-St Github-setup project](https://github.com/ba-st/GitHub-setup).


## Contributing

Check the [Contribution Guidelines](CONTRIBUTING.md)

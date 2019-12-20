
# Roadmap / Next steps

There are some outstanding features that are missing in the current codebase.

## Configuration Maps

Tonel doesn't provide any artifact to have something similar as a Configuration Map, so we might implement it once [Rowan](https://github.com/GemTalk/Rowan/) is stable. Although it is not a Tonel feature, but a tool that uses Tonel as one of its supported file format.

## Strategy based behavior

The current behavior of the loader is interactive, meaning that we need input from the user. This has to do with the fact that the ENVY/Manager codebase itself is GUI dependent at some parts, but we can have a few pluggable settings/strategies to handle some of the current UI interactions to resolve things like:

* Version naming (from git, fossil, manual, etc.)
* Use the same version for all Applications/Classes
* Prerequisite version choosing (latest/etc)

This would allow us to load a whole project unattended (headless), for things like Continuous Integration, which is a common use case that requires file based SCM.

## ENVY/Manager version migration

Be able to migrate the history of an application (or set of applications) from the ENVY Library to a git repository, with one commit+tag for each Application version, etc.

## Real use testing

This codebase was tested with a good suite of unit testing, the example repositories mentioned before and [VAST Tensorflow](https://github.com/vasmalltalk/tensorflow-vast/) library.

VAST users might have other use cases and needs that weren't considered in this codebase. If you have suggestions or issues [please report them](https://github.com/vasmalltalk/tonel-vast/issues/) so we can continue .

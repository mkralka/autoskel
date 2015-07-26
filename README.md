# Autoskel

The _**auto**tools_ _**skel**eton_ generator is a simple tool for
bootstrapping an autotools-based project, with emphasis on C projects
maintained with the [git](https://git-scm.com/) CSM.

With a single command, _autoskel_ will generate the boilerplate autoconf,
automake, and libtool files, orgaized in a helpful way.

_Autoskel_ assumes POSIX-compliant tools, so should work on most systems. The
generated scripts also assume POSIX-compliant tools, but should only need
to run on developer machines and shouldn't normally be run when users build
a project from a distribution tarball.

## Quick Start
To generate an autotools-based project called _cool-project_, stored in
`~/dev/cool-project`, simply run the following command:

    ./autoskel ~/dev/cool-project

For this to work, the target directory must not exist. Don't worry, _autoskel_
is non-destructive and will fail if the target directory already exists.

For help on available options, see the online help:

    ./autoskel --help 

## Options
_Autoskel_ supports a few options, mostly related to project bookkeeping. For
options that modify how _autoconf_ is configured, refer to the
[autoconf manual](http://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf.html#Initializing-configure).

### Package Name
If not specified, the package name is derived from the target directory.
Specifically, it is set to the last component of the target directory. This is
sometimes OK, but usually a more human-readable project name is desired.

To override the default _package_ of the project, use the `-p` (or `--package`)
option:

    ./autoskel --package 'Super Cool Project' ~/dev/cool-project 

In addition to changing the package name, this may also change the name of the
generated tarball (which, by default, is derived from the package name).

This can be changed after the fact by editing the `AC_INIT` line in the
generated `configure.ac`.

### Tarball Name
If not specified, the tarball name is derived from the package name. This
follows _autoconf_ rules, by first stripping off a leading `GNU ` (if any),
force to lower case, and convert sequences of 1 or more characters, different
from alphanumeric and underscore, to a single `-`. For example with the package
named _Super Cool Project_, the default tarball is `super-cool-project`.

To override the default name of the generated _tarball_, use the `-t` (or
`--tar-name`) option:

    ./autoskel --tar-name 'scp' ~/dev/cool-project 

This will create tarballs named similarly to `scp-1.0.3.tar.gz`.

This can be changed after the fact by editing the `AC_INIT` line in the
generated `configure.ac` and the line in `.gitignore` for ignoring generated
tarballs.

### Bug Report Location
By default, the _bug report_ location is unspecified (i.e., the project will not
have bug report location). To specify a _bug report_ location, use the `-b`
(or `--bug-report`) option:

    ./autoskel --bug-report 'bugs@cool-project.com' ~/dev/cool-project 

The bug report location is typically an email address or URL of a bug
management web page.

This can be changed after the fact by editing the `AC_INIT` line in the
generated `configure.ac`.

### Project URL
By default, the project's _url_ is unspecified (i.e., the project will not have
a published URL).

To specify a _url_, use the `-u` (or `--url`) option:

    ./autoskel --url 'https://cool-project.com' ~/dev/cool-project 

A URL may be important as it allows users to find out more information,
including the latest version, about the project.

This can be changed after the fact by editing the `AC_INIT` line in the
generated `configure.ac`.

## Installation
_Autoskel_ is not designed to be installed per se. To use, simply clone
this github repo:

    cd ~/dev
    git clone https://github.com/mkralka/autoskel
    
then run `autoskel` directly. E.g.,

    cd ~/dev
    ~/dev/autoskel -p 'Super Cool Project' scp

## Structure of the Generated Skeleton
### Autotools
Seasoned autotools users will find the structure of the generated skeleton
very familiar, with the following notable differences:

1. The creation of a special `.autoconf` directory for placing autoconf (m4)
   files.  
   This is the perfect location for custom or third-party m4 files used by
   `configure.ac`.    This directory should help keep `configure.ac` clean as
   utility macros can be created in separate files.
2. The creation of a special `.automake` directory for placing automake files.  
   This is the perfect location for placing files containing definitions used
   by multiple automake files (e.g., setting `AM_CPPFLAGS` or `AM_CFLAGS`).
   They can be included in other automake files. E.g.,
   ```
   include $(top_srcdir)/.automake/buildflags.am
   ```

### Code
Two directories are created for placing source code: `include` and `src`.

As its name suggests, `include` is for placing public header files (those that
will be installed, usually in `/usr/include`).

As its name suggests, `src` is for placing source code and private header files
(those that will not be installed). There are no restrictions on how the code
underneath is organized, so use good judgment.

### Support Scripts
In addition to the autotools skeleton, two support tools are installed:

1. `autogen.sh`
2. `version.sh`

`autogen.sh` is a relatively simple script designed to bootstrap autotools, by
running `autoconf`, `automake`, and `libtool` with appropriate options. It
should only need to be run once as `automake` can automatically detect
changes and will re-run commands as necessary.

`version.sh` is a relatively simple script designed to generate helpful version
numbers between releases by looking at the state of the local git repo (if any).
The only assumption that the tool makes is that releases are tagged (with
`rel-<version>`, but the prefix can be changed by editing the generated
`configure.ac`).

To allow for _autoskel_ to update an existing project, the support scripts
should not be modified directly.

## Limitations
1. It is not currently possible to update the support scripts, to fix bug
   or implement new features, using _autoskel_ itself. To update manually,
   copy `autogen.sh` and `version.sh` from the `skel/` directory to the
   project root. No other files should need updating.
2. `version.sh` only has special support for git-backed projects. This
   means that projects using other SCMs (e.g., subversion, mercurial,
   etc) will not get automatic versioning when changes are made.

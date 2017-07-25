# MUKLA Design Document

## Dependency resolution

MUKLA reads `mukla.yml` and `mukla.lock` in the current directory and uses 
information from these files to download dependencies and add them to the
current directory.

The process for install is as follows:

 * If `mukla.lock` is found, only downloads dependencies from this file using
   specified git revisions; fail if the revision cannot be found
 * Otherwise, read the lists of `require` (and `require-dev`, in case of
   developer install) packages
 * Treating each package name as a GitHub repository name, check out the master
   branch of the repository to the cache location (`~/.mukla/cache/`); if it's
   already been cached, update the repo from git
 * Add a record about the dependency and its git revision to `mukla.lock`
 * For each package, load package's `mukla.yml` file and process all
   dependencies for this package recursively
 * After all dependencies have been processed recursively, read `files` section
   of each dependency and copy files defined there to the current directory
   (where `mukla.yml` file is located)

The process for uninstall is as follows:
 * Read `mukla.lock` to collect the list of dependencies or read `mukla.yml`
   and recursively build a list of dependencies
 * Get `mukla.yml` for each dependency (using cache or a new checkout, if
   absent from cache) and remove all files specified in `files` section of its
   `mukla.yml` from the current directory
 * Remove `mukla.lock` file
 * Remove uninstalled package from `mukla.yml` in the current directory
 * Run the process for install to reinstall dependencies and rebuild
   `mukla.lock` file

MUKLA will detect circular dependencies and will fail as soon as it finds one.

At this point MULKA doesn't support tags and branches and always checks out
a master branch and locks a dependency on a latest git revision number. If a
version other than `master` is provided, MUKLA will report an error and
refuse to continue.

MUKLA won't check if one package overwrites files from another package which
can cause issues if two packages install the files with the same name to the
same location. The resolution to this problem is up to a package maintainer
at this point.

## Lock file

Lock file is used to speed up dependency downloads, as it contains the whole
dependency tree with revision numbers and, thus, allows parallel processing.

Lock file contains hash of the corresponding `mukla.yml` file and the time of
its creation.

Every time MUKLA runs, it checks this timestamp and a hash against the
`mukla.yml` in current directory and, if `mukla.yml` is newer or the hash is
wrong, will issue a warning and suggest to update the project.

Having a lock file essentially bypasses dependency resolution when using
`install` and `uninstall` commands.

## Commands

### init
Initialize a new project, creating a `mukla.yml` file

### get
Download and install one or more packages and add dependency to `mukla.yml`

### remove
Remove a package from the `mukla.yml` file, and regenerate the lock file

### install
Install project's dependencies (using `mukla.lock`, if present)

### install-dev
Install project's dependencies, including developer's dependencies

### update
Update project's dependencies

### list
List prints all dependencies that the present code references

### info
Info prints information about this project

### about
Learn about MUKLA

### clear
Clears MUKLA cache

### help
Shows a list of commands or help for one command

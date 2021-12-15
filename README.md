# log4j-jar-upgrade
Script for upgrading log4j jar files.

## Usage:
`sh log4j-upgrade.sh <dir to search for log4j>`

## Example:
`sh log4j-upgrade.sh /`

## How does it work?

1. It identifies the latest log4j version, where to download from, where to search for log4j and a temporary working directory.

2. Checks whether wget is installed and a working directory (`/tmp/log4j/`) exists.

3. Downloads the latest `log4j` binaries.

4. Extracts the downloaded binaries.

5. Searches to find `log4j` files matching the pattern `*log4j*.jar` within the given search directory.

6. Backups the current version of the log4j library (e.g. `log4j-core`, `log4j-web`, etc.).

7. Copies the new libary (`.jar`) file to the found directory containing the old version.


## Nice to know
The script does *not* consider the following:

* File rights and permissions (`chmod`, `chown`),

* Detecting permission errors (though, you would receive a error message),

* Eventual needed configuration implementations (e.g. where a configuration file for an application points to a specific `.jar` file containing the version number)

* The script is not written to be used as a interactive script (though, an implementation of this would be an easy fix)
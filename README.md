# Daily Report Script 2 #

## Overview ##

The Daily Report Script (DRS) is a PowerShell scripts module to support health gathering on a local or set of remote computers.
The DRS can be run as individual commands to get health objects, individual reports to receive single pages, or the entire report.
the config.json is heavily leveraged for the script.

## Installation ##

Currently, this module is not available in the powershell gallery and must be manually downloaded from this git repository

Once the repository is downloaded, extract the files and copy the DRS folder and all contents to one of the directories in your $env:PSModulePath

## Usage ##

Import-Module DRS

TODO: Create documentation for the commands

## Configurations ##
Use the config.json to modify alert values

Alert rules currently support the following comparisons
* -gt or >
* -lt or \<
* -eq or ==

Alert Rules can be the following severity
* Critical
* Alert
* Warning
* Info
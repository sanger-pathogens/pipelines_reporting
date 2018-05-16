# pipelines_reporting

Email groups of users when lanes have gone through different stages of the pipeline.

[![Build Status](https://travis-ci.org/sanger-pathogens/pipelines_reporting.svg?branch=574328_fix_travis)](https://travis-ci.org/sanger-pathogens/pipelines_reporting)   
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/sanger-pathogens/pipelines_reporting/blob/master/GPL-LICENSE)   

## Contents
  * [Introduction](#introduction)
  * [Installation](#installation)
    * [From source](#from-source)
  * [Usage](#usage)
  * [License](#license)
  * [Feedback/Issues](#feedbackissues)

## Introduction
This application will send emails to groups of users assocaitated with studies if there are new lanes out of the qc and mapping pipelines.

## Installation
The details for installing pipelines_reporting are provided below. If you encounter an issue when installing pipelines_reporting please contact your local system administrator. If you encounter a bug please log it [here](https://github.com/sanger-pathogens/pipelines_reporting/issues) or email us at path-help@sanger.ac.uk.

### From source
Clone the github repository:
```
git clone https://github.com/sanger-pathogens/pipelines_reporting.git
```
Move into the directory and install all dependencies using DistZilla:
```
cd pipelines_reporting
dzil authordeps --missing | cpanm
dzil listdeps --missing | cpanm
```
Run the tests:
```
dzil test
```
If the tests pass, install pipelines_reporting:
```
dzil install
```
## Usage
```
send_pipeline_emails.pl -e (test|production) -p my_master_db_password
   
Options:
     --environment       The configuration settings you wish to use ( test | production )
     --database_password [Optional] Used instead of the password setting in the database.yml file
```
## License
pipelines_reporting is free software, licensed under [GLPv3](https://github.com/sanger-pathogens/pipelines_reporting/blob/master/GPL-LICENSE).

## Feedback/Issues
Please report any issues to the [issues page](https://github.com/sanger-pathogens/pipelines_reporting/issues) or email path-help@sanger.ac.uk.
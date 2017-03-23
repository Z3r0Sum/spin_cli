# SPINCLI 

## Goals

* Interact with the Spinnaker RESTful API via Gate
* Abstract some of the nuances of trying to work with the Spinnaker API, since it is largely undocumented.

## Current Featureset

* Supports interacting with Pipeline aspects within Spinnaker: CRUD

## Future Plans

* Expose other commands through the API as they are warranted.  

## Pre-Req's
* Tested with ruby 2.1+
* `gem install bundler`
* Assumes the Spinnaker Application already exists

## Setup

1. Clone the repo
2. Run `bundle install` from the project's root
3. Export an environment variable containing your Spinnaker Endpoint: `export SPINNAKER_ENDPOINT=localhost:8084` (Spinnaker Gate Endpoint)
4. Leverage the `spincli` command in `spin_cli/bin`

## Basic Use

The `-h` or `--help` can be appended to any command/sub-command for clarification, a few examples will be included below to get you started.

```shell
./spincli   
                                                                                                                                                                                                    
Interface with the Spinnaker REST API

Usage: spincli [options] {help | pipeline | version}

Available commands:
    help (*)          Provide help for individual commands
    pipeline          Command for Manipulating pipelines
      create          Creates a pipeline from scratch via a JSON file that meets
      delete          Delete an existing pipeline
      get             Obtain an existing pipeline's config information
      get-name-ids    Obtain all existing pipelines' names and IDs
      update          Update an existing pipeline
    version           Show the version of the program

Options (take precedence over global options):
    -v, --version                    Show the version of the program

Global Options:
    -h, --help                       Show help
```

### Creation and Updates

* Create and update rely that you've formatted the JSON for pipelines correctly

* The update call has some magic built in that retrieves information that the user otherwise wouldn't care to specify or obtain (namely, the pipeline ID) - it then prepends this onto the data structure you're passing in, so that the update can take place without much effort.

* There's an examples directory within this project that provide some extremely trivial ideas for what the JSON would look like for a Pipeline.  If unfamiliar - it is best to generate a pipeline through the UI and then edit it as JSON to get an idea of how the pipeline templates should be formatted. 

#### Create

```shell
./spincli pipeline create -h                                                                                                                                                                                              

Interface with the Spinnaker REST API

Usage: spincli [options] pipeline create PIPELINE_JSON_FILE

Summary:
    create - Creates a pipeline from scratch via a JSON file that meets the

Global Options:
    -h, --help                       Show help
```

```shell
./spincli pipeline create ../examples/create-pipeline.json                                                                                                                                                                         
Running create pipeline using file: ../examples/create-pipeline.json
```


#### Update

```shell
./spincli pipeline update -h                                                                                                                                                                                                       

Interface with the Spinnaker REST API

Usage: spincli [options] pipeline update PIPELINE_JSON_FILE APP PIPELINE_NAME

Summary:
    update - Update an existing pipeline

Global Options:
    -h, --help                       Show help
```

```shell
./spincli pipeline update ../examples/update-pipeline.json underarmour test-pipeline2                                                                                                                                             
Running update pipeline using file: ../examples/update-pipeline.json
```

## TODO

* Expose other Spinnaker RESTful endpoints for use.
* Create a Docker Image, making the need for most of the Setup and Pre-Req's unnecessary.

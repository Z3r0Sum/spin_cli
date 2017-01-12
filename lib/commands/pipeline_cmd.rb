require 'cmdparse'
require_relative '../pipeline/actions'

module SpinCli
  class PipelineCmd < CmdParse::Command
    attr_reader :endpoint
    def initialize(endpoint)
      super('pipeline')
      @endpoint = endpoint
      short_desc('Command for Manipulating pipelines')
      add_command(PipelineCreateCmd.new(@endpoint))
      add_command(PipelineDeleteCmd.new(@endpoint))
      add_command(PipelineUpdateCmd.new(@endpoint))
      add_command(PipelineReadCmd.new(@endpoint))
      add_command(PipelineGetNameIdsCmd.new(@endpoint))
    end
  end

  class PipelineCreateCmd < CmdParse::Command
    def initialize(endpoint)
      super('create', takes_commands: false)
      @endpoint = endpoint
      short_desc('Creates a pipeline from scratch via a JSON file that meets the Spinnaker JSON Spec.')
    end

    def execute(pipeline_json_file)
      puts "Running create pipeline using file: #{pipeline_json_file}" 
      pipeline_action = SpinCli::PipelineActions.new(@endpoint)
      pipeline_action.create(pipeline_json_file)
    end
  end

  class PipelineGetNameIdsCmd < CmdParse::Command
    def initialize(endpoint)
      super('get-name-ids', takes_commands: false)
      @endpoint = endpoint
      short_desc('Obtain all existing pipelines\' names and IDs')
    end

    def execute
      pipeline_action = SpinCli::PipelineActions.new(@endpoint)
      pipeline_action.name_ids
    end
  end

  class PipelineReadCmd < CmdParse::Command
    def initialize(endpoint)
      super('get', takes_commands: false)
      @endpoint = endpoint
      short_desc('Obtain an existing pipeline\'s config information')
    end

    def execute(app, pipeline_name)
      pipeline_action = SpinCli::PipelineActions.new(@endpoint)
      puts pipeline_action.get(app, pipeline_name).to_json
    end
  end

  class PipelineDeleteCmd < CmdParse::Command
    def initialize(endpoint)
      super('delete', takes_commands: false)
      @endpoint = endpoint
      short_desc('Delete an existing pipeline')
    end

    def execute(app, pipeline_name)
      puts "Running delete pipeline for spinnaker app: #{app} and pipeline: #{pipeline_name}"
      pipeline_action = SpinCli::PipelineActions.new(@endpoint)
      pipeline_action.delete(app, pipeline_name)
    end
  end

  class PipelineUpdateCmd < CmdParse::Command
    def initialize(endpoint)
      super('update', takes_commands: false)
      @endpoint = endpoint
      short_desc('Update an existing pipeline')
    end

    def execute(pipeline_json_file, app, pipeline_name)
      puts "Running update pipeline using file: #{pipeline_json_file}" 
      pipeline_action = SpinCli::PipelineActions.new(@endpoint)
      pipeline_action.update(pipeline_json_file, app, pipeline_name)
    end
  end
end

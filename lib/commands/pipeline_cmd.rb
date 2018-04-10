require 'cmdparse'
require_relative '../pipeline/actions'

module SpinCli
  class PipelineCmd < CmdParse::Command
    attr_reader :endpoint
    attr_reader :global_options_data
    def initialize(endpoint)
      super('pipeline')
      @endpoint = endpoint
      @options_data = {}
      short_desc('Command for Manipulating pipelines')
      add_command(PipelineCreateCmd.new(@endpoint, @options_data))
      add_command(PipelineDeleteCmd.new(@endpoint, @options_data))
      add_command(PipelineUpdateCmd.new(@endpoint, @options_data))
      add_command(PipelineReadCmd.new(@endpoint, @options_data))
      add_command(PipelinePlanCmd.new(@endpoint, @options_data))
      add_command(PipelineRunCmd.new(@endpoint, @options_data))
      add_command(PipelineCancelCmd.new(@endpoint, @options_data))
      add_command(PipelineExecutionsCmd.new(@endpoint, @options_data))
      add_command(PipelineGetNameIdsCmd.new(@endpoint, @options_data))
      options.on('-s', '--ssl', 'Enable use of SSL X.509 Client (See README)') { @options_data[:ssl] = true }
    end
  end

  class PipelineCreateCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('create', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Creates a pipeline from scratch via a JSON file that meets the Spinnaker JSON Spec.')
    end

    def execute(pipeline_json_file)
      puts "Running create pipeline using file: #{pipeline_json_file}"
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.create(pipeline_json_file)
    end
  end

  class PipelineGetNameIdsCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('get-name-ids', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Obtain all existing pipelines\' names and IDs')
    end

    def execute
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.name_ids
    end
  end

  class PipelineReadCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('get', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Obtain an existing pipeline\'s config information')
    end

    def execute(app, pipeline_name)
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      puts pipeline_action.get(app, pipeline_name).to_json
    end
  end

  class PipelinePlanCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('plan', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('See desired pipelines changes before updating')
    end

    def execute(app, pipeline_name, updated_pipeline_file)
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.plan(app, pipeline_name, updated_pipeline_file)
    end
  end

  class PipelineDeleteCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('delete', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Delete an existing pipeline')
    end

    def execute(app, pipeline_name)
      puts "Running delete pipeline for spinnaker app: #{app} and pipeline: #{pipeline_name}"
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.delete(app, pipeline_name)
    end
  end

  class PipelineUpdateCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('update', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Update an existing pipeline')
    end

    def execute(app, pipeline_name, pipeline_json_file)
      puts "Running update pipeline using file: #{pipeline_json_file}"
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.update(app, pipeline_name, pipeline_json_file)
    end
  end

  class PipelineRunCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('run', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Run a pipeline (timeout threshold default: 1800 seconds)')
    end

    def execute(app, pipeline_name, timeout_threshold = 1800)
      puts "Running pipeline: #{pipeline_name}"
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.run(app, pipeline_name, timeout_threshold)
    end
  end

  class PipelineCancelCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('cancel', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Cancel a pipeline execution')
    end

    def execute(pipeline_execution_id)
      puts "Canceling pipeline execution id: #{pipeline_execution_id}"
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.cancel(pipeline_execution_id)
    end
  end

  class PipelineExecutionsCmd < CmdParse::Command
    def initialize(endpoint, options_data)
      super('executions', takes_commands: false)
      @endpoint = endpoint
      @options_data = options_data
      short_desc('Lists running/not started pipeline executions')
    end

    def execute(app, pipeline_name)
      pipeline_action = SpinCli::PipelineActions.new(@endpoint, @options_data)
      pipeline_action.executions(app, pipeline_name)
    end
  end
end

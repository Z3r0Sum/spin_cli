require_relative '../utils/pipeline_compare'
require_relative '../utils/http'
require 'json'
require 'colorize'
require 'uri'

module SpinCli
  class PipelineActions
    attr_reader :http

    def initialize(endpoint, options_data)
      @endpoint = endpoint
      @options_data = options_data
      @http = SpinCli::Utils::Http.new(@endpoint, @options_data)
    end

    # Creates a pipeline from scratch via a JSON file that meets the Spinnaker JSON Spec.
    def create(json_file)
      pipeline_json = File.read(json_file)
      @http.pipelines.post pipeline_json
    rescue StandardError => e
      puts "Error creating pipeline: #{e}"
      Process.exit(1)
    end

    # Deletes a pipeline within Spinnaker for a certain Spinnaker app
    def delete(app, pipeline_name)
      @http.pipelines[URI.escape("#{app}/#{pipeline_name}")].delete
    rescue StandardError => e
      puts "Error deleting pipeline: #{e}"
      Process.exit(1)
    end

    # Returns a string of all pipeline names and IDs
    def name_ids
      parse_pipelines_name_id(@http.pipelineConfigs.get)
    rescue StandardError => e
      puts "Error getting all pipeline names and IDs from Spinnaker: #{e}"
      Process.exit(1)
    end

    # Returns a pipeline config for a certain Spinnaker app and pipeline
    def get(app, pipeline_name)
      parse_pipeline_name(@http.pipelineConfigs.get,
                          app,
                          pipeline_name)
    rescue StandardError => e
      puts "Error reading pipelines configs from Spinnaker: #{e}"
      Process.exit(1)
    end

    # Retrieve current state Pipeline and perform a comparision with
    # desired changes. Then try to create it (separate from the existing
    # pipeline).
    def plan(app, pipeline_name, updated_pipeline)
      # diff existing_pipeline_json to updated_pipeline_json
      updated_pipeline_hash = JSON.parse(File.read(updated_pipeline))
      updated_pipeline_hash['name'] = pipeline_name
      SpinCli::Utils::Pipeline.compare(get(app, pipeline_name), updated_pipeline_hash)

      # Try to create the pipeline and then remove it
      # Create it under a different name
      rng = Random.new(Time.now.to_i)
      random_pipeline_number = rng.rand(1000)
      updated_pipeline_hash['name'] = "#{pipeline_name}-#{random_pipeline_number}"

      @http.pipelines.post updated_pipeline_hash.to_json
      puts "Successfully validated pipeline changes for: #{pipeline_name}".colorize(:green)
      puts "\nTo Update - Run: #{$PROGRAM_NAME} pipeline update #{app} #{pipeline_name} " \
           "#{updated_pipeline}".colorize(:green)

      # Cleanup validated pipeline
      delete(app, "#{pipeline_name}-#{random_pipeline_number}")
    rescue StandardError => e
      puts "Error performing a plan on #{pipeline_name}: #{e}"
    end

    # This needs to read the pipeline config in order to get the
    # id, ts, and name associated with it in order to update the correct pipeline.
    def update(app, pipeline_name, json_file)
      # We need certain data about the pipeline that the user won't have or want
      # to get ahead of their changes.
      pipeline_config = get(app, pipeline_name)
      begin
        f = File.read(json_file)
        updated_pipeline_cfg = JSON.parse(f)
        updated_pipeline_cfg['id'] = pipeline_config['id']
        updated_pipeline_cfg['application'] = pipeline_config['application']
        updated_pipeline_cfg['name'] = pipeline_config['name']
        updated_pipeline_cfg['updateTs'] = pipeline_config['updateTs']
        @http.pipelines.post updated_pipeline_cfg.to_json
      rescue StandardError => e
        puts "Error updating pipeline: #{e}"
        Process.exit(1)
      end
    end

    def run(app, pipeline_name, timeout_threshold_seconds)
      payload = { type: 'manual', dryRun: false }
      @http.pipelines[URI.escape("#{app}/#{pipeline_name}")].post payload.to_json
      pipeline_config_id = get(app, pipeline_name)['id']

      status = check_pipeline_status(pipeline_config_id)
      timeout = 0

      while (status == 'RUNNING' || status == 'NOT_STARTED') && \
            timeout < timeout_threshold_seconds.to_i

        puts "Pipeline Status: #{status}"
        sleep 5
        status = check_pipeline_status(pipeline_config_id)
        timeout += 5
      end

      if timeout >= timeout_threshold_seconds.to_i
        puts "Timeout threshold of #{timeout_threshold_seconds} seconds reached!"
        puts "Please investigate pipeline: #{pipeline_name}."
        Process.exit(1)
      end

      puts "Pipeline Completed Status: #{check_pipeline_status(pipeline_config_id)}"
    rescue StandardError => e
      puts "Unable to run pipeline #{pipeline_name}: #{e}"
      Process.exit(1)
    end

    def cancel(execution_id)
      reason = { reason: 'spincli cancel' }
      @http.pipelines["#{execution_id}/cancel"].put reason.to_json
    rescue StandardError => e
      puts "Unable to cancel pipeline #{pipeline_name}: #{e}"
      Process.exit(1)
    end

    def executions(app, pipeline_name)
      executions = JSON.parse(@http.execution_status(get(app, pipeline_name)['id'], 30).get)
      executions.each do |execution|
        next unless execution['status'] == 'RUNNING' || execution['status'] == 'NOT_STARTED'
        puts "id:#{execution['id']} user:#{execution['authentication']['user']} status: #{execution['status']}"
      end
    end

    private

    # Return a singleton pipeline's JSON config
    def parse_pipeline_name(json_resp, app, pipeline_name)
      # We get an array of configs back from the API in JSON form - parse them.
      configs = JSON.parse(json_resp)
      count = 0
      configs.each do |config|
        break if config['name'] == pipeline_name && config['application'] == app
        count += 1
      end

      configs[count]
    end

    # Return the name and IDs of all the pipelines we have
    def parse_pipelines_name_id(json_resp)
      configs = JSON.parse(json_resp)
      configs.each do |config|
        puts "#{config['name']}:#{config['id']}"
      end
    end

    def check_pipeline_status(pipeline_config_id)
      parsed_results = JSON.parse(@http.execution_status(pipeline_config_id).get)
      parsed_results.each do |result|
        return result['status']
      end
    rescue StandardError => e
      puts "Unable to retrieve pipeline status: #{e}"
    end
  end
end

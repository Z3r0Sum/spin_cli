require 'rest-client'
require 'json'

module SpinCli
  class PipelineActions

    attr_reader :endpoint

    def initialize(endpoint)
      @endpoint  = endpoint
    end

    # Creates a pipeline from scratch via a JSON file that meets the Spinnaker JSON Spec.
    def create(json_file)
      url = "#{@endpoint}/gate/pipelines"
      begin
        f = File.read(json_file)
        json_payload = JSON.parse(f)
        RestClient.post(url,
                        json_payload.to_json,
                        { :content_type => :json, :accept => :json }
                       )
      rescue => e
        puts "Error creating pipeline: #{e}"
        Process.exit(1)
      end
    end

    # Deletes a pipeline within Spinnaker for a certain Spinnaker app
    def delete(app, pipeline_name)
      url = "#{@endpoint}/gate/pipelines/#{app}/#{pipeline_name}"
      begin
        RestClient.delete(url)
      rescue => e
        puts "Error deleting pipeline: #{e}"
        Process.exit(1)
      end
    end

    # Returns a string of all pipeline names and IDs
    def name_ids
      url = "#{@endpoint}/gate/pipelineConfigs"
      begin
        json_resp = RestClient.get(url, { :accept => :json })
        parse_pipelines_name_id(json_resp)
      rescue => e
        puts "Error getting all pipeline names and IDs from Spinnaker: #{e}"
        Process.exit(1)
      end
    end

    # Returns a pipeline config for a certain Spinnaker app and pipeline
    def get(app, pipeline_name)
      url = "#{@endpoint}/gate/pipelineConfigs"
      begin
        json_resp = RestClient.get(url, { :accept => :json })
        pipeline_config = parse_pipeline_name(json_resp, app, pipeline_name)
        return pipeline_config
      rescue => e
        puts "Error reading pipelines configs from Spinnaker: #{e}"
        Process.exit(1)
      end
    end

    # This needs to read the pipeline config in order to get the 
    # id, ts, and name associated with it in order to update the correct pipeline.
    def update(json_file, app, pipeline_name)
      # We need certain data about the pipeline that the user won't have or want
      # to get ahead of their changes.
      pipeline_config = get(app, pipeline_name)
      url = "#{@endpoint}/gate/pipelines"
      begin
        f = File.read(json_file)
        json_payload = JSON.parse(f)
        json_payload['id'] = pipeline_config['id']
        json_payload['application'] = pipeline_config['application']
        json_payload['name'] = pipeline_config['name']
        json_payload['updateTs'] = pipeline_config['updateTs']
        RestClient.post(url,
                        json_payload.to_json,
                        { :content_type => :json, :accept => :json }
                       )
      rescue => e
        puts "Error updating pipeline: #{e}"
        Process.exit(1)
      end
    end

    private 
    # Return a singleton pipeline's JSON config
    def parse_pipeline_name(json_resp, app, pipeline_name)
      # We get an array of configs back from the API in JSON form - parse them.
      json_configs = JSON.parse(json_resp)
      count = 0
      json_configs.each do |config|
        break if config['name'] == pipeline_name
        count += 1
      end

      return json_configs[count]
    end

    # Return the name and IDs of all the pipelines we have
    def parse_pipelines_name_id(json_resp)
      json_configs = JSON.parse(json_resp)
      json_configs.each do |config|
        puts "#{config['name']}:#{config['id']}"
      end
    end

  end
end

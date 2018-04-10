require 'rest-client'

module SpinCli
  module Utils
    class Http
      SAML_SESSION_COOKIE_ID = ENV['SAML_SESSION_COOKIE_ID'] || ''
      CLIENT_CERT = ENV['CLIENT_CERT'] || ''
      CLIENT_KEY = ENV['CLIENT_KEY'] || ''
      CLIENT_KEY_PASSPHRASE = ENV['CLIENT_KEY_PASSPHRASE'] || ''
      # CA_CERTIFICATE = ENV['CA_CERTIFICATE'] || ''

      def initialize(endpoint, options_data)
        @endpoint = endpoint
        @options_data = options_data
      end

      def pipelines
        if @options_data[:ssl]
          rest_client_resource_ssl("#{@endpoint}/pipelines")
        else
          rest_client_resource("#{@endpoint}/pipelines")
        end
      end

      def pipelineConfigs
        if @options_data[:ssl]
          rest_client_resource_ssl("#{@endpoint}/pipelineConfigs")
        else
          rest_client_resource("#{@endpoint}/pipelineConfigs")
        end
      end

      def execution_status(pipeline_config_id, limit = 1)
        if @options_data[:ssl]
          rest_client_resource_ssl("#{@endpoint}/executions?pipelineConfigIds=#{pipeline_config_id}&limit=#{limit}")
        else
          rest_client_resource("#{@endpoint}/executions?pipelineConfigIds=#{pipeline_config_id}&limit=#{limit}")
        end
      end

      private

      def rest_client_resource(url)
        RestClient::Resource.new(url,
                                 headers: {
                                   content_type: 'application/json',
                                   accept: 'application/json',
                                   cookies: {
                                     'SESSION' => SAML_SESSION_COOKIE_ID.to_s
                                   }
                                 })
      end

      def rest_client_resource_ssl(url)
        RestClient::Resource.new(url,
                                 headers: {
                                   content_type: 'application/json',
                                   accept: 'application/json',
                                   cookies: {
                                     'SESSION' => SAML_SESSION_COOKIE_ID.to_s
                                   }
                                 },
                                 ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(CLIENT_CERT.to_s)),
                                 ssl_client_key: OpenSSL::PKey::RSA.new(File.read(CLIENT_KEY.to_s),
                                                                        CLIENT_KEY_PASSPHRASE.to_s),
                                 verify_ssl: OpenSSL::SSL::VERIFY_NONE)
      end
    end
  end
end

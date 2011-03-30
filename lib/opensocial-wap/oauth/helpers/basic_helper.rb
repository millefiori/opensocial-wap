require 'oauth'
require 'oauth/signature/rsa/sha1'

module OpensocialWap
  module OAuth
    module Helpers
      class BasicHelper < Base

        def self.setup(options)
          # Set class instance variables.
          options.each do |k, v|
            self.instance_variable_set "@#{k.to_s}", v
          end
          self
        end
        
        def verify(options = nil)
          opts = {
            :consumer_secret => self.class.consumer_secret,
            :token_secret => request_proxy.parameters['oauth_token_secret'] }
          signature = ::OAuth::Signature.build(request_proxy, opts)

          logger = @request.logger
          if logger
            logger.debug "oauth signature : #{::OAuth::Signature.sign(request_proxy, opts)}"
            logger.debug "OauthHandler OAuth verification:"
            logger.debug "  authorization header: #{@request.env['HTTP_AUTHORIZATION']}"
            logger.debug "  base string:          #{signature.signature_base_string}"
            logger.debug "  signature:            #{signature.signature}"      
          end

          signature.verify
        rescue Exception => e
          false
        end        

        def authorization_header(api_request, options = nil)
          opts = {
            :consumer => consumer,
            :token => access_token,
          }
          oauth_helper = ::OAuth::Client::Helper.new(api_request, opts.merge(options))
          oauth_helper.header
        end

        private

        def self.consumer_key
          @consumer_key
        end
        
        def self.consumer_secret
          @consumer_secret
        end

        def request_proxy
          @request_proxy ||= ::OpensocialWap::OAuth::RequestProxy::BasicRackRequest.new(@request)
        end

        def consumer 
          @consumer ||= ::OAuth::Consumer.new(self.class.consumer_key, self.class.consumer_secret)
        end

        def access_token
          @access_token ||= ::OAuth::AccessToken.from_hash(consumer, request_proxy.parameters)
        end

      end
    end
  end
end
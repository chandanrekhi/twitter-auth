module TwitterAuth
  module Dispatcher
    module Shared
      def append_extension_to(path)
        path, query_string = *(path.split("?"))
        path << '.json' unless path.match(/\.(:?xml|json)\z/i)
        "#{path}#{"?#{query_string}" if query_string}"
      end

      def handle_response(response)
        case response
        when Net::HTTPOK 
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            response.body
          end
        else
          message = begin
            JSON.parse(response.body)['error']
          rescue JSON::ParserError
            if match = response.body.match(/<error>(.*)<\/error>/)
              match[1]
            else
              'An error occurred processing your Twitter request.'
            end
          end

          raise TwitterAuth::Dispatcher::Error, message
        end
      end
    end
  end
end

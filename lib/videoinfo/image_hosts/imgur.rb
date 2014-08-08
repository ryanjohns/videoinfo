module Videoinfo
  module ImageHosts
    class Imgur < ImageHost

      def initialize
        @boundary     = SecureRandom.hex(6)
        @header       = { 'Content-Type' => "multipart/form-data, boundary=#{@boundary}" }
        @uri          = URI.parse('https://imgur.com/upload')
        @http         = Net::HTTP.new(@uri.host, @uri.port)
        @http.use_ssl = true
      end

      def upload(image)
        begin
          request      = Net::HTTP::Post.new(@uri.request_uri, @header)
          request.body = post_body(image)
          response     = @http.request(request)
          img_name     = JSON.parse(response.body)['data']['hash']
          "https://i.imgur.com/#{img_name}.png"
        rescue => e
          raise Error, "could not upload image #{File.basename(image.path)}. #{e.message}"
        end
      end

      private

      def post_body(image)
        body  = "--#{@boundary}\r\n"
        body << "Content-Disposition: form-data; name=\"Filedata\"; filename=\"#{File.basename(image.path)}\"\r\n"
        body << "Content-Type: image/png\r\n\r\n"
        body << image.read
        body << "\r\n\r\n--#{@boundary}--\r\n"
      end

    end
  end
end

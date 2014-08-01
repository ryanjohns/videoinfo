module Videoinfo
  class Video

    attr_accessor :name, :file, :screenshots, :result

    def initialize(name, file, screenshots = 0)
      self.name        = name
      self.file        = file
      self.screenshots = screenshots
    end

    def file=(f)
      @file = File.expand_path(f)
    end

    def result
      @result ||= Result.new
    end

    def populate_result!
      result.mediainfo       = read_mediainfo
      result.screenshot_urls = capture_screenshots.map { |ss| upload_screenshot(ss) }.compact

      result
    end

    def read_mediainfo
      raise Error, "#{file}: file not found" unless File.file?(file)

      info = Dir.chdir(File.dirname(file)) { %x(#{Videoinfo.mediainfo_binary} #{File.basename(file).shellescape}) }
      raise Error, 'unable to read mediainfo' unless $?.success?

      info
    end

    def capture_screenshots
      return [] unless screenshots > 0
      raise Error, "#{file}: file not found" unless File.file?(file)

      duration = %x(#{Videoinfo.mediainfo_binary} --Inform="General;%Duration%" #{file.shellescape}).strip.to_f / 1000
      raise Error, 'unable to determine video duration' unless $?.success? && duration > 0

      images   = []
      stepsize = screenshots == 1 ? 100 : 60 / (screenshots - 1)
      (20..80).step(stepsize) do |percent|
        image = Tempfile.new(["ss_#{percent}.", '.png'])
        %x(#{Videoinfo.ffmpeg_binary} -y -ss #{duration * percent / 100} -i #{file.shellescape} -vframes 1 -f image2 #{image.path} -v quiet)
        if $?.success?
          images << image
        else
          STDERR.puts "ERROR: unable to capture screenshot at #{percent}% into the video"
        end
      end

      images
    end

    def upload_screenshot(image)
      begin
        http         = bb_images_http
        request      = Net::HTTP::Post.new(@bb_images_uri.request_uri, @bb_images_header)
        request.body = post_body(image)
        response     = http.request(request)
        img_name     = JSON.parse(response.body)['ImgName']
        "https://images.baconbits.org/images/#{img_name}"
      rescue => e
        STDERR.puts "ERROR: could not upload screenshot #{File.basename(image.path)}. #{e.message}"
        nil
      end
    end

    private

    def bb_images_http
      return @bb_images_http unless @bb_images_http.nil?

      @boundary               = SecureRandom.hex(6)
      @bb_images_header       = { 'Content-Type' => "multipart/form-data, boundary=#{@boundary}" }
      @bb_images_uri          = URI.parse('https://images.baconbits.org/upload.php')
      @bb_images_http         = Net::HTTP.new(@bb_images_uri.host, @bb_images_uri.port)
      @bb_images_http.use_ssl = true

      @bb_images_http
    end

    def post_body(image)
      body  = "--#{@boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"ImageUp\"; filename=\"#{File.basename(image.path)}\"\r\n"
      body << "Content-Type: image/png\r\n\r\n"
      body << image.read
      body << "\r\n\r\n--#{@boundary}--\r\n"
    end

  end
end

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
      result.screenshot_urls = capture_screenshots.map { |ss| Videoinfo.upload_screenshot(ss) }

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
      stepsize = screenshots == 1 ? 100 : 25 / (screenshots - 1)
      (5..30).step(stepsize) do |percent|
        image = Tempfile.new(["ss_#{percent}.", '.png'])
        %x(#{Videoinfo.ffmpeg_binary} -y -ss #{duration * percent / 100} -i #{file.shellescape} -vframes 1 -f image2 #{image.path} -v quiet)
        if $?.success?
          images << image
        else
          raise Error, "ERROR: unable to capture screenshot at #{percent}% into the video"
        end
      end

      images
    end

  end
end

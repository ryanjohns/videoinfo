require 'optparse'

module Videoinfo
  class CLI

    ENV_IMAGE_HOST = 'VIDEOINFO_IMAGE_HOST'

    # Analyze a video from command line arguments and print the result to STDOUT.
    def self.run(args)
      Videoinfo.interactive = true
      image_host            = ENV[ENV_IMAGE_HOST] || Videoinfo.image_host.class.to_s.split('::').last
      screenshots           = 2
      option_parser         = OptionParser.new do |opts|
        opts.banner = 'Usage: videoinfo [options] "MOVIENAME" file'
        opts.on('-i', '--image-host=IMAGEHOST', "The ImageHost to use for uploading screenshots. Default: #{image_host}") do |host|
          image_host = host
        end
        opts.on('-s', '--screenshots=SCREENSHOTS', "The number of screenshots to create, max 7. Default: #{screenshots}") do |ss|
          screenshots = ss.to_i
          if screenshots > 7
            STDERR.puts opts
            exit 1
          end
        end
        opts.on('-n', '--no-prompt', 'Disable interactive mode') do
          Videoinfo.interactive = false
        end
        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end

      begin
        Videoinfo.image_host = Videoinfo::ImageHosts.const_get(image_host).new
      rescue
        hosts = Videoinfo::ImageHosts.constants.map(&:to_s).join(', ')
        STDERR.puts "ERROR: '#{image_host}' is an unknown image host. Available hosts: #{hosts}"
        exit 1
      end

      name, file = option_parser.parse!(args)
      if name.to_s == '' || file.to_s == ''
        STDERR.puts option_parser
        exit 1
      end

      begin
        result = Videoinfo.analyze_movie(name, file, screenshots)
        puts result.to_s
      rescue Error => e
        STDERR.puts "ERROR: #{e.message}"
        exit 1
      end
    end

  end
end

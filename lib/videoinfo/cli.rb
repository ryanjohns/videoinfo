require 'optparse'

module Videoinfo
  class CLI

    ENV_IMAGE_HOST = 'VIDEOINFO_IMAGE_HOST'

    # Analyze a video from command line arguments and print the result to STDOUT.
    def self.run(args)
      Videoinfo.interactive = true
      image_host            = ENV[ENV_IMAGE_HOST] || Videoinfo.image_host.class.to_s.split('::').last
      screenshots           = 2
      episode               = nil
      option_parser         = OptionParser.new do |opts|
        opts.banner = 'Usage: videoinfo [options] "MOVIENAME/SHOWNAME" file'
        opts.on('-i', '--image-host=IMAGEHOST', "The image host to use for uploading screenshots. Default: #{image_host}") do |host|
          image_host = host
        end
        opts.on('-s', '--screenshots=SCREENSHOTS', "The number of screenshots to create, max 6. Default: #{screenshots}") do |ss|
          screenshots = ss.to_i
          if screenshots > 6
            STDERR.puts opts
            exit 1
          end
        end
        opts.on('-e', '--episode=EPISODE', 'The TV show episode or season number. Formats: S01E01 or S01') do |ep|
          if ep =~ /\AS\d{2,3}\z/i || ep =~ /\AS\d{2,3}E\d{2,3}\z/i
            episode = ep
          else
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

      name, file = option_parser.parse!(args)

      begin
        Videoinfo.image_host = Videoinfo::ImageHosts.const_get(image_host).new
      rescue
        hosts = Videoinfo::ImageHosts.constants.map(&:to_s).join(', ')
        STDERR.puts "ERROR: '#{image_host}' is an unknown image host. Available hosts: #{hosts}"
        exit 1
      end

      if name.to_s.strip == '' || file.to_s.strip == ''
        STDERR.puts option_parser
        exit 1
      end

      begin
        if episode
          result = Videoinfo.analyze_tv("#{name} #{episode}".strip, file.strip, screenshots)
        else
          result = Videoinfo.analyze_movie(name.strip, file.strip, screenshots)
        end
        puts result.to_s
      rescue Error => e
        STDERR.puts "ERROR: #{e.message}"
        exit 1
      end
    end

  end
end

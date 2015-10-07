require 'tempfile'
require 'shellwords'
require 'cgi'
require 'uri'
require 'net/https'
require 'json'
require 'securerandom'
require 'imdb'
require 'imdb/imdb'
require 'videoinfo/errors'
require 'videoinfo/image_host'
require 'videoinfo/image_hosts/imgur'
require 'videoinfo/result'
require 'videoinfo/results/movie_result'
require 'videoinfo/results/tv_result'
require 'videoinfo/version'
require 'videoinfo/video'
require 'videoinfo/videos/movie'
require 'videoinfo/videos/tv'

module Videoinfo

  # Helper method to analyze a movie.
  def self.analyze_movie(name, file, screenshots = 0)
    Videos::Movie.new(name, file, screenshots).populate_result!
  end

  # Helper method to analyze a tv episode or season.
  def self.analyze_tv(name, file, screenshots = 0)
    Videos::Tv.new(name, file, screenshots).populate_result!
  end

  # Performs a google search and returns the top 10 results.
  def self.google(term)
    uri = URI("https://www.google.com/search?hl=en&q=#{CGI.escape(term)}")
    begin
      response = Net::HTTP.get_response(uri)
      document = Nokogiri::HTML(response.body.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => ''))
      document.css('cite').map { |node| node.inner_text }
    rescue => e
      raise Error, "could not search google for '#{term}'. #{e.message}"
    end
  end

  # Uploads a screenshot to the currently configured image_host and returns a URL to the image.
  def self.upload_screenshot(image)
    image_host.upload(image)
  end

  # Set the path of the mediainfo binary.
  def self.mediainfo_binary=(mediainfo)
    @mediainfo_binary = mediainfo.to_s.shellescape
  end

  # Get the path to the mediainfo binary, defaulting to 'mediainfo'.
  def self.mediainfo_binary
    @mediainfo_binary ||= 'mediainfo'
  end

  # Set the path of the ffmpeg binary.
  def self.ffmpeg_binary=(ffmpeg)
    @ffmpeg_binary = ffmpeg.to_s.shellescape
  end

  # Get the path to the ffmpeg binary, defaulting to 'ffmpeg'.
  def self.ffmpeg_binary
    @ffmpeg_binary ||= 'ffmpeg'
  end

  # Set the image host class. Must be an object that responds to upload(File) and returns a URL.
  def self.image_host=(host)
    @image_host = host
  end

  # Get the image host class, defaulting to ImageHosts::Imgur.new.
  def self.image_host
    @image_host ||= ImageHosts::Imgur.new
  end

  # Set interactive mode to true or false.
  def self.interactive=(value)
    @interactive = value
  end

  # True if interactive mode is enabled, defaulting to false.
  def self.interactive?
    @interactive ||= false
  end

end

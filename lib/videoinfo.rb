require 'tempfile'
require 'shellwords'
require 'cgi'
require 'uri'
require 'net/http'
require 'json'
require 'securerandom'
require 'imdb'
require 'videoinfo/errors'
require 'videoinfo/result'
require 'videoinfo/results/movie_result'
require 'videoinfo/version'
require 'videoinfo/video'
require 'videoinfo/videos/movie'

module Videoinfo

  # Helper method to analyze a movie.
  def self.analyze_movie(name, file, screenshots = 0)
    Videos::Movie.new(name, file, screenshots).populate_result!
  end

  # Performs a google search and returns the top 10 results.
  def self.google(term)
    uri = URI("https://www.google.com/search?hl=en&q=#{CGI.escape(term)}")
    begin
      response = Net::HTTP.get_response(uri)
      response.body.scan(%r(<cite>.+</cite>)).map { |c| c.gsub(%r((</?cite>|</?b>)), '') }
    rescue => e
      raise Error, "could not search google for '#{term}'. #{e.message}"
    end
  end

  # Set the path of the mediainfo binary.
  def self.mediainfo_binary=(mediainfo)
    @mediainfo_binary = mediainfo.to_s.shellescape
  end

  # Get the path to the mediainfo binary, defaulting to 'mediainfo'.
  def self.mediainfo_binary
    @mediainfo_binary || 'mediainfo'
  end

  # Set the path of the ffmpeg binary.
  def self.ffmpeg_binary=(ffmpeg)
    @ffmpeg_binary = ffmpeg.to_s.shellescape
  end

  # Get the path to the ffmpeg binary, defaulting to 'ffmpeg'.
  def self.ffmpeg_binary
    @ffmpeg_binary || 'ffmpeg'
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

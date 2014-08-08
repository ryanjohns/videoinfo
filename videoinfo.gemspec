# -*- encoding: utf-8 -*-

require File.expand_path('../lib/videoinfo/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'videoinfo'
  s.version     = Videoinfo::VERSION
  s.summary     = 'Simple tool for aggregating video metadata and capturing screenshots'
  s.description = 'Combines metadata from a variety of sources with codec details from mediainfo to produce a marked-up summary for a video file. Also captures screenshots using ffmpeg.'
  s.authors     = ['Ryan Johns']
  s.email       = 'ryanjohns@gmail.com'
  s.homepage    = 'https://github.com/ryanjohns/videoinfo'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'imdb', '~> 0.8'

  s.requirements << 'mediainfo'
  s.requirements << 'ffmpeg'
end

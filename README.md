## Videoinfo

Videoinfo is a simple tool for aggregating video metadata and capturing/uploading screenshots.

## Installation

First, you'll want to install the prerequisite binaries and make sure they are in your PATH.

 * [mediainfo](http://mediaarea.net/en-us/MediaInfo/Download)
 * [ffmpeg](https://www.ffmpeg.org/download.html)

Add this line to your application's Gemfile:

    gem 'videoinfo'

And then execute:

    bundle install

Or install it yourself with:

    $ gem install videoinfo

## Configuration

There are only a few configuration options:

```ruby
Videoinfo.mediainfo_binary = '/path/to/mediainfo'  # defaults to 'mediainfo'
Videoinfo.ffmpeg_binary    = '/path/to/ffmpeg'     # defaults to 'ffmpeg'
Videoinfo.image_host       = ImageHosts::Imgur.new # can be any object that responds to upload(File)
Videoinfo.interactive      = true                  # defaults to true when using the command line, false otherwise
```

## Usage

#### Command Line

```
$ videoinfo -h
Usage: videoinfo [options] "MOVIENAME/SHOWNAME" file
    -i, --image-host=IMAGEHOST       The image host to use for uploading screenshots. Default: Imgur
    -s, --screenshots=SCREENSHOTS    The number of screenshots to create, max 6. Default: 2
    -e, --episode=EPISODE            The TV show episode or season number. Formats: S01E01 or S01
    -n, --no-prompt                  Disable interactive mode
    -h, --help                       Show this message

$ videoinfo -s 5 -i Imgur 'Hackers' Hackers.1995.mkv > hackers.txt
Is your movie "Hackers (1995)" (tt0113243)? [Y/n] y
```

#### In scripts

The simpliest way to analyze a movie is with `Videoinfo.analyze_movie()`:

```ruby
result = Videoinfo.analyze_movie('hackers', 'Hackers.1995.mkv', 0) # => #<Videoinfo::Results::MovieResult>
result.imdb_id         # => "0113243"
result.title           # => "Hackers"
result.plot_summary    # => "A young boy is arrested..."
result.release_date    # => "15 September 1995 (USA)"
result.rating          # => 6.2
result.rating_over_ten # => "6.2 / 10"
result.genres          # => ["Action", "Crime", "Drama", "Thriller"]
result.director        # => "Iain Softley"
result.writers         # => ["Rafael Moreu"]
result.runtime         # => 107
result.imdb_url        # => "http://www.imdb.com/title/tt0113243"
result.wiki_url        # => "https://en.wikipedia.org/wiki/Hackers_(film)"
result.trailer_url     # => "https://www.youtube.com/watch?v=vCobCU9FfzI"
result.screenshot_urls # => ["https://i.imgur.com/SoBhWfQ.png", ...]
result.mediainfo       # => "General..."
```

Or, you can be more explicit:

```ruby
movie = Videoinfo::Videos::Movie.new('hackers', 'Hackers.1995.mkv', 5)
movie.populate_result!            # => #<Videoinfo::Results::MovieResult>
movie.result                      # => #<Videoinfo::Results::MovieResult>
movie.search_imdb                 # => [#<Imdb::Movie>, ...]
movie.search_wiki                 # => "https://en.wikipedia.org/wiki/Hackers_(film)"
movie.search_youtube              # => "https://www.youtube.com/watch?v=vCobCU9FfzI"
movie.read_mediainfo              # => "General..."
movie.capture_screenshots         # => [#<Tempfile:/var/folders/l1/qf5v1rlj6n99n20_rhwrp_5r0000gn/T/ss_20.20140803-67537-ur85vi.png>, ...]
Videoinfo.upload_screenshot(file) # => "https://i.imgur.com/SoBhWfQ.png"
```

It works with TV shows too:

```ruby
result = Videoinfo.analyze_tv('survivor s01e01', 'survivor.s01e01.mkv', 0) # => #<Videoinfo::Results::TvResult>
tv = Videoinfo::Videos::Tv.new('survivor s01e01', 'survivor.s01e01.mkv', 3)
````

## Contributing

You are welcome to submit patches with bug fixes or feature additions. Please
make sure to test your changes throughly and keep to the style you see throughout
the rest of the code base. Indent with 2 spaces and no trailing spaces at the end
of lines. Just follow the steps below.

1. Fork and clone the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a Pull Request

## Links

* Code: `git clone git@github.com:ryanjohns/videoinfo.git`
* Home: <https://github.com/ryanjohns/videoinfo>
* Bugs: <https://github.com/ryanjohns/videoinfo/issues>
* mediainfo: <http://mediaarea.net/en-us/MediaInfo/Download>
* ffmpeg: <https://www.ffmpeg.org/download.html>

## Author/Maintainter

 * [Ryan Johns](https://github.com/ryanjohns)

## License

Videoinfo is released under the [MIT License](http://www.opensource.org/licenses/MIT).

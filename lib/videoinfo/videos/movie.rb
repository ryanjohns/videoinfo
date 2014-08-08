module Videoinfo
  module Videos
    class Movie < Video

      def result
        @result ||= Results::MovieResult.new
      end

      def populate_result!
        result.mediainfo = read_mediainfo

        movie = search_imdb.first
        if movie
          result.imdb_id      = movie.id
          result.title        = movie.title.sub(/\(\d{4}\)/, '').strip
          result.plot_summary = movie.plot_summary
          result.release_date = movie.release_date
          result.rating       = movie.rating
          result.genres       = movie.genres
          result.director     = movie.director.first
          result.writers      = movie.writers.compact
          result.runtime      = movie.length
          result.wiki_url     = search_wiki
          result.trailer_url  = search_youtube
        end

        result.screenshot_urls = capture_screenshots.map { |ss| Videoinfo.upload_screenshot(ss) }

        result
      end

      def search_imdb
        movies = []
        begin
          movies = Imdb::Search.new(name).movies
        rescue => e
          raise Error, "could not search IMDB. #{e.message}"
        end

        return movies unless Videoinfo.interactive?

        movies.each do |m|
          STDERR.print "Is your movie \"#{m.title}\" (tt#{m.id})? [Y/n] "
          return [m] if STDIN.gets.strip !~ /^(n|no)$/i
        end

        []
      end

      def search_wiki
        wiki_url = Videoinfo.google("site:wikipedia.org #{result.title || name} film").first
        wiki_url ? "https://#{wiki_url}" : nil
      end

      def search_youtube
        youtube_url = Videoinfo.google("site:youtube.com #{result.title || name} trailer").first
        youtube_url ? "https://#{youtube_url}" : nil
      end

    end
  end
end

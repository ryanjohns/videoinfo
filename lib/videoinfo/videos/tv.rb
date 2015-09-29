module Videoinfo
  module Videos
    class Tv < Video

      attr_reader :episode_string, :season_number, :episode_number

      def result
        @result ||= Results::TvResult.new
      end

      def populate_result!
        result.mediainfo = read_mediainfo

        serie = search_imdb.first
        if serie
          result.imdb_id   = serie.id
          result.title     = serie.title
          result.plot      = serie.plot
          result.rating    = serie.rating
          result.genres    = serie.genres
          result.country   = serie.countries.first
          result.premiered = serie.year

          if season_number
            season = serie.season(season_number.to_i)
            if season
              result.season_number = season.season_number
              if episode_number
                episode = season.episode(episode_number.to_i)
                if episode
                  result.episode_number  = episode.episode
                  result.episode_imdb_id = episode.id
                  result.episode_title   = episode.title
                  result.episode_url     = episode.url
                  result.episode_rating  = episode.rating
                  result.air_date        = episode.air_date
                end
              end
            end
          end
        end

        result.screenshot_urls = capture_screenshots.map { |ss| Videoinfo.upload_screenshot(ss) }

        result
      end

      def search_imdb
        series = []
        begin
          series = Imdb::Search.new(name).movies
        rescue => e
          raise Error, "could not search IMDB. #{e.message}"
        end

        return series.map { |s| Imdb::Serie.new(s.id) } unless Videoinfo.interactive?

        series.each do |s|
          STDERR.print "Is your series \"#{s.title}\" (tt#{s.id})? [Y/n] "
          return [Imdb::Serie.new(s.id)] if STDIN.gets.strip !~ /^(n|no)$/i
        end

        []
      end

      def name=(n)
        @episode_string = n.slice!(/(\AS\d{2,3}E\d{2,3}\ |\ S\d{2,3}E\d{2,3}\z|\AS\d{2,3}\ |\ S\d{2,3}\z)/i)
        @name           = n

        if @episode_string
          @episode_string.strip!
          @season_number, @episode_number = @episode_string.gsub(/[SE]/i, ' ').split
        end

        @name
      end

    end
  end
end

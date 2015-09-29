module Videoinfo
  module Results
    class TvResult < Result

      attr_accessor :imdb_id, :title, :plot, :rating, :genres, :country, :premiered, :season_number, :episode_number, :episode_imdb_id, :episode_title, :episode_url, :episode_rating, :air_date

      def rating_over_ten
        rating ? "#{rating} / 10" : nil
      end

      def episode_rating_over_ten
        episode_rating ? "#{episode_rating} / 10" : nil
      end

      def imdb_url
        imdb_id ? "http://www.imdb.com/title/tt#{imdb_id}" : nil
      end

      def to_s
        output = ['[b]Description:[/b]', '[quote]', plot, '[/quote]', '']
        output << '[b]Information:[/b]'
        output << '[quote]'
        output << "Show Name: #{title}"
        output << "Show url: #{imdb_url}"
        output << "Rating: #{rating_over_ten}"
        output << "Genres: #{(genres || []).join(' | ')}"
        output << "Country: #{country}"
        output << "Premiered: #{premiered}"                    if premiered
        output << "Season Number: #{season_number}"            if season_number
        output << "Episode Number: #{episode_number}"          if episode_number
        output << "Episode Name: #{episode_title}"             if episode_title
        output << "Episode url: #{episode_url}"                if episode_url
        output << "Episode Rating: #{episode_rating_over_ten}" if episode_rating_over_ten
        output << "Air Date: #{air_date}"                      if air_date
        output << '[/quote]'

        if screenshot_urls && screenshot_urls.size > 0
          output += ['', '[b]Screenshots:[/b]', '[quote][align=center]']
          output += screenshot_urls.map { |url| "[img=#{url}]" }
          output += ['[/align][/quote]']
        end

        output += ['', '[mediainfo]', mediainfo, '[/mediainfo]']

        output.join("\n")
      end

    end
  end
end

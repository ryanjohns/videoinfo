module Videoinfo
  module Results
    class MovieResult < Result

      attr_accessor :imdb_id, :title, :plot_summary, :release_date, :rating, :genres, :director, :writers, :runtime, :wiki_url, :trailer_url

      def rating_over_ten
        rating ? "#{rating} / 10" : nil
      end

      def imdb_url
        imdb_id ? "http://www.imdb.com/title/tt#{imdb_id}" : nil
      end

      def to_s
        output = ['[b]Description:[/b]', '[quote]', plot_summary, '[/quote]', '']
        output << '[b]Information:[/b]'
        output << '[quote]'
        output << "Title: #{title}"
        output << "Rating: #{rating_over_ten}"
        output << "Release Date: #{release_date}"
        output << "Genres: #{(genres || []).join(' | ')}"
        output << "Director: #{director}"          if director
        output << "Writers: #{writers.join(', ')}" if writers && writers.size > 0
        output << "Runtime: #{runtime} minutes"    if runtime
        output << "Wikipedia url: #{wiki_url}"     if wiki_url
        output << "IDMB url: #{imdb_url}"
        output << '[/quote]'

        if trailer_url
          output += ['', '[b]Trailer:[/b]', '[quote]', "[center][youtube]#{trailer_url}[/youtube][/center]", '[/quote]']
        end

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

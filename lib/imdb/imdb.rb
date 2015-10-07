module Imdb
  class Search < MovieList
    TYPES = {
      :movie     => 'ft',
      :tv        => 'tv',
      :episode   => 'ep',
      :videogame => 'vg',
    }

    attr_reader :type

    def initialize(query, type = nil)
      @query = query
      @type  = type
    end

    private

    def document
      @document ||= Nokogiri::HTML(submit_query)
    end

    def submit_query
      url = "http://akas.imdb.com/find?q=#{CGI.escape(query)}&s=tt"
      url << "&ttype=#{TYPES[type]}" if type && TYPES.include?(type)
      open(url)
    end
  end
end

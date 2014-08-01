module Videoinfo
  class Result

    attr_accessor :mediainfo, :screenshot_urls

    def to_s
      output = []

      if screenshot_urls && screenshot_urls.size > 0
        output += ['[b]Screenshots:[/b]', '[quote][align=center]']
        output += screenshot_urls.map { |url| "[img=#{url}]" }
        output += ['[/align][/quote]', '']
      end

      output += ['[mediainfo]', mediainfo, '[/mediainfo]']

      output.join("\n")
    end

  end
end

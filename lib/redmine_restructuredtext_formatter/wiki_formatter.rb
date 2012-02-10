# -*- coding: utf-8 -*-
require 'rbst'

module RedmineRestructuredtextFormatter
  class WikiFormatter
    def initialize(text)
      @content_is_html = text.strip[0..0] == '<'    # Check if format of content is HTML using a naive
      if @content_is_html
        @text = text
        return
      end     
         
      # TODO: Implement UI to config these and the CSS and store them in DB:
      @text = <<-EOD
      .. role:: underline
      .. role:: strike
      .. role:: overline
      .. role:: rtl
      .. role:: ltr
      .. role:: lre
      .. role:: rle
      
      .. |lre| unicode:: U+202A
         :rtrim:               
      .. |rle| unicode:: U+202B
         :rtrim:               
      .. |pdf| unicode:: U+202C
         :ltrim:               
      
      EOD
      @text << text
    end

    def to_html(&block)
      return @text if @content_is_html
      # TODO: Make the the parameters configurable:
      RbST.new(@text).to_html(:language => 'en', :part => 'fragment', :tab_width => 4)
    rescue => e
      return("<pre>problem parsing wiki text: #{e.message}\n"+
             "original text: \n"+
               @text+
               "</pre>")
    end

    def get_section(index)
      section = extract_sections(index)[1]
      hash = Digest::MD5.hexdigest(section)
      return section, hash
    end

    def update_section(index, update, hash=nil)
      t = extract_sections(index)
      if hash.present? && hash != Digest::MD5.hexdigest(t[1])
        raise Redmine::WikiFormatting::StaleSectionError
      end
      t[1] = update unless t[1].blank?
      t.reject(&:blank?).join "\n\n"
    end

    private

    def extract_sections(index)
      selected, before, after = [[],[],[]]
      pre = :none
      state = 'before'

      selected_level = 0
      header_count = 0

      @text.each do |line|

        if line =~ /^(~~~|```)/
          pre = pre == :pre ? :none : :pre
        elsif pre == :none
          
          level = if line =~ /^(#+)/
                    $1.length
                  elsif line.strip =~ /^=+$/ 
                    line = eval(state).pop + line
                    1
                  elsif line.strip =~ /^-+$/ 
                    line = eval(state).pop + line
                    2
                  else
                    nil
                  end
          unless level.nil?
            if level <= 4
              header_count += 1
              if state == 'selected' and selected_level >= level
                state = 'after'
              elsif header_count == index
                state = 'selected'
                selected_level = level
              end
            end
          end
        end

        eval("#{state} << line")
      end

      [before, selected, after].map{|x| x.join.strip}
    end
  end
end

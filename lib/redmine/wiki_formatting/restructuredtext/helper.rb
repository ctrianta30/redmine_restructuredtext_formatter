module Redmine
  module WikiFormatting
    module Restructuredtext
      module Helper
        unloadable

        def wikitoolbar_for(field_id, preview_url = preview_text_path)
          heads_for_wiki_formatter
          url = "#{Redmine::Utils.relative_url_root}/help/#{current_language.to_s.downcase}/wiki_syntax_markdown.html"
          javascript_tag(
            "var wikiToolbar = new jsToolBar(document.getElementById('#{field_id}')); " \
              "wikiToolbar.setHelpLink('#{escape_javascript url}'); " \
              "wikiToolbar.setPreviewUrl('#{escape_javascript preview_url}'); " \
              "wikiToolbar.draw();"
          )
        end

        def initial_page_content(page)
          "# #{@page.pretty_title}"
        end

        def heads_for_wiki_formatter
          unless @heads_for_wiki_formatter_included
            content_for :header_tags do
              javascript_include_tag('jstoolbar/jstoolbar') +
              javascript_include_tag('restructuredtext', :plugin => 'redmine_restructuredtext_formatter') +
              javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}") +
              javascript_include_tag("lang/restructuredtext-#{current_language.to_s.downcase}", :plugin => 'redmine_restructuredtext_formatter') +
              stylesheet_link_tag('jstoolbar') +
              stylesheet_link_tag('html4css1', :plugin => 'redmine_restructuredtext_formatter') +
              stylesheet_link_tag('restructuredtext', :plugin => 'redmine_restructuredtext_formatter')
            end
            @heads_for_wiki_formatter_included = true
          end
        end
      end
    end
  end
end

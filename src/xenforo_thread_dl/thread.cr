module XenforoThreadDL
  class Thread
    @html : Myhtml::Parser
    getter html

    def initialize(@uri : URI)
      @html = get_html
    end

    def current_page_num
      @html.css(".pageNav-page--current").first.inner_text.to_i
    end

    def last_page_num
      @html.css(".pageNav-page").to_a.last.inner_text.to_i
    end

    def pages_remaining
      last_page_num - current_page_num
    end

    def goto(@uri : URI)
      @html = get_html
    end

    def images
      # We don't want to include spoiler images since they're duplicates
      @html.css(".bbImage").each_with_object({} of String => String) do |elem, imgs|
        title = elem.attribute_by("title") || ""
        title = elem.attribute_by("alt") || "" if title.empty?
        src = elem.attribute_by("src") || ""
        src = elem.attribute_by("data-src") || "" if src.empty?
        parentElem = elem
        while parentElem = parentElem.parent
          # Ignore images in quotes
          if parentElem.tag_sym == :blockquote
            break
          end

          # Lightbox, use the high quality image instead
          if parentElem.tag_sym == :a && parentElem.attribute_by("class") == "js-lbImage"
            src = parentElem.attribute_by("href") || ""
          end

          if postid = parentElem.attribute_by("data-lb-id")
            title = "#{postid}-#{title}" if !postid.empty?
            break
          end
        end
        imgs[src.as(String)] = title.as(String)
      end
    end

    private def get_html
      XenforoThreadDL::HTML.load_document_from_url @uri
    end
  end
end

require "http/client"
require "uri"
require "myhtml"

module XenforoThreadDL
  module HTML
    class FetchError < Exception
    end

    def self.get_url(url : String | URI, &block : (HTTP::Client::Response) -> _)
      HTTP::Client.get(url) do |response|
        if response.status_code == 200
          yield response
        elsif response.status_code == 301
          get_url response.headers["Location"], &block
        else
          raise FetchError.new "#{response.status_code}"
        end
      end
    end

    def self.download_url(url : String | URI, to : String | Path)
      get_url(url) { |res| File.write(to, res.body_io) }
    end

    def self.load_document_from_url(url : String | URI) : Myhtml::Parser
      get_url(url) do |res|
        html = res.body_io.gets_to_end
        Myhtml::Parser.new(html)
      end
    end
  end
end

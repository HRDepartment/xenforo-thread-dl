require "path"
require "file"
require "file_utils"

module XenforoThreadDL
  class Downloader
    MANIFEST_FILE = ".manifest.json"
    getter thread_uri, directory, thread, manifest

    def initialize(thread_url : String)
      use_cwd = false
      if thread_url.empty?
        use_cwd = true
        @directory = Path.new(Dir.current)
        @manifest = load_manifest
        if @manifest.url.empty?
          raise RuntimeError.new("No URL supplied and no manifest.json present in the working directory, quitting")
        else
          thread_url = @manifest.url
        end
      end

      @thread_uri = URI.parse thread_url
      @thread_uri.path = @thread_uri.path.split("/")[0..2].join("/")
      # TODO: cmdline option to start from a page

      raise ArgumentError.new("Invalid URL: #{thread_url}") if @thread_uri.path.split("/")[1] != "threads"

      unless use_cwd
        @directory = Path.new("#{@thread_uri.host}/#{@thread_uri.path.split("/")[2]}").expand
        FileUtils.mkdir_p(@directory.to_s)
        @manifest = load_manifest
      end

      # Help the compiler realize it's always set
      @directory = @directory.as(Path)
      @manifest = @manifest.as(XenforoThreadDL::Manifest)

      if @manifest.url.empty?
        @manifest.url = @thread_uri.to_s
      end

      @thread = XenforoThreadDL::Thread.new uri: current_page_uri
    end

    def current_page_uri
      page = @manifest.current_page
      uri = URI.parse(@thread_uri.to_s)
      uri.path += "/page-#{page}" if page > 1
      uri
    end

    def download
      total_downloads = 0
      loop do
        images = @thread.images
        puts "Page #{@thread.current_page_num} / #{@thread.last_page_num}, +#{images.size - @manifest.current_page_downloaded} images"

        page_image_max = @manifest.images.size + images.size - @manifest.current_page_downloaded
        images.each do |url, title|
          download_index = "[#{@manifest.images.size + 1}/#{page_image_max}]"
          if @manifest.images.has_key? url
            next
          end

          resolved_url = @thread_uri.resolve(url)
          to = @directory.join(title)
          puts "Downloading #{resolved_url} => #{title} #{download_index}..."
          begin
            XenforoThreadDL::HTML.download_url url: resolved_url, to: to
            @manifest.images[url] = title
            @manifest.current_page_downloaded += 1
            total_downloads += 1
          rescue err : XenforoThreadDL::HTML::FetchError
            puts "Failed to download #{resolved_url}: #{err.message}"
            @manifest.failed_downloads.push resolved_url.to_s
          end
        end

        break unless @thread.pages_remaining != 0
        @manifest.current_page += 1
        @manifest.current_page_downloaded = 0
        @thread.goto current_page_uri
      end
      total_downloads
    end

    def save_manifest
      @manifest.save_to_file manifest_file
    end

    protected def load_manifest
      begin
        filename = File.open(manifest_file)
      rescue File::NotFoundError
        filename = "{}"
      end

      XenforoThreadDL::Manifest.from_json filename
    end

    protected def manifest_file
      @directory.join(MANIFEST_FILE).to_s
    end
  end
end

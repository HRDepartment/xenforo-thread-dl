require "json"
require "file"

module XenforoThreadDL
  class Manifest
    include JSON::Serializable

    # url : title
    property images = Hash(String, String).new
    property failed_downloads = Array(String).new
    property url = ""
    property current_page = 1
    property current_page_downloaded = 0

    def self.load_from_file(file : String) : Manifest
      self.from_json(File.open(file))
    end

    def save_to_file(file : String)
      File.write(file, to_json)
    end
  end
end

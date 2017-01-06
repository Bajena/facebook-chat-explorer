require 'open-uri'
require 'json'
require 'fileutils'

# Steps:
# 1. Download JSON with image URLS
# Example URL for chat images json (you need to be logged into fb):
# https://www.facebook.com/ajax/messaging/attachments/sharedphotos.php?thread_id=1364885221&offset=0&limit=30&__a=1
#
# 2. Call the script
# `JSON_PATH=photos_all.json ruby photo_downloader.rb`
# * You can optionally start from a photo with given index by passing START_FROM=<number>
# * You can save files to custom directory by passing DIRECTORY_NAME=<name>

class PhotoDownloader
  def initialize(json_path:, directory_name: "photos")
    @json_path = json_path
    @directory_name = directory_name
  end

  def download_all(start_from: 1)
    create_directory
    start_from -= 1

    count = photos.count
    photos.shift(start_from)
    i = start_from
    photos.each do |photo|
      i += 1
      puts "Downloading photo #{i}/#{count}"
      download_photo(photo)
    end
  end

  private

  def create_directory
    FileUtils.mkdir_p @directory_name
  end

  def download_photo(photo)
    open(photo_path(photo), 'wb') do |file|
      file << open(photo["src_uri"]).read
    end
  rescue OpenURI::HTTPError => e
    puts "Error: #{e}. Skipping photo: #{photo}"
  end

  def photo_path(photo)
    "#{@directory_name}/" + photo["fbid"] + ".jpg"
  end

  def photos
    @photos_hash ||= JSON.parse(File.read(@json_path))["payload"]["imagesData"]
  end
end

start_from = (ENV["START_FROM"] || 1).to_i
json_path = ENV["JSON_PATH"]
directory_name = ENV["DIRECTORY_NAME"] || "photos"

raise "Please call the script with JSON_PATH variable set" if json_path.nil?

PhotoDownloader.new(json_path: json_path, directory_name: directory_name).download_all(start_from: start_from)

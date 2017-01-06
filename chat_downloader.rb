require "koala"
require "date"

class ChatDownloader
  def initialize(thread_id, access_token)
    @access_token = access_token
    @thread_id = thread_id
  end

  # @param file_name [String]
  # @param max_date [String] Date in iso8601 - messages will be fetched before
  #   this date if passed
  # @param limit [Fixnum] Messages will be fetched until this count is reached
  def download(file_name:, max_date: nil, limit: nil)
    puts "#{DateTime.now}: Downloading messages from fb thread (#{@thread_id})"
    count = 0
    @next_date = max_date if max_date
    File.open(file_name, "a") do |f|
      loop do
        batch = fetch_batch
        count += batch.count
        write_batch(batch, f)
        @next_date = next_until_date(batch)
        puts "#{DateTime.now}: Processed batch. Already downloaded: #{count} messages."
        break if @next_date.nil?
        break if limit && count > limit
      end
    end
    puts "#{DateTime.now}: Done!"
  end

  private

  def fetch_batch
    sleep(1) # throttle requests (there's a limit of 600 reqs per 10 minutes)
    client.get_connections(@thread_id, "comments", until: @next_date, limit: 50)
  end

  def next_until_date(batch)
    return if batch.count.zero?
    one_second = 1.0 / (24 * 3600)

    (DateTime.parse(batch.first["created_time"]) - one_second).iso8601
  end

  def write_batch(batch, f)
    batch.reverse.each do |message|
      f.write(message_content(message))
    end
  end

  def message_content(message)
    "#{message['from']['name']} (#{message['created_time']}):\n"\
      "#{message['message']}\n"
  end

  def client
    @client ||= Koala::Facebook::API.new(@access_token)
  end
end

Koala.config.api_version = "v2.2"

thread_id = "xxx"
access_token = "yyy"
file_name = "chat.txt"

ChatDownloader.new(
  thread_id,
  access_token
).download(file_name: file_name)

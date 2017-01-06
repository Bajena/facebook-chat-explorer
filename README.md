# facebook-chat-explorer

This is a set of scripts for downloading facebook chat data. 
It consists of following scripts:

## chat_downloader.rb:
A script that downloads a full messenger conversation using Graph API

Usage:
`THREAD_ID=x ACCESS_TOKEN=y ruby chat_downloader.rb`

## photo_downloader.rb:
A script that downloads all photos from a conversation.

### Usage:
1. Download JSON with image URLS

   Example URL for chat images json (you need to be logged into fb):
   `https://www.facebook.com/ajax/messaging/attachments/sharedphotos.php?thread_id=1364885221&offset=0&limit=30&__a=1`

2. Call the script

   `JSON_PATH=photos_all.json ruby photo_downloader.rb`
   * You can optionally start from a photo with given index by passing START_FROM=<number>
   * You can save files to custom directory by passing DIRECTORY_NAME=<name>

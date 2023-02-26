require 'faraday'
require 'dotenv'
require 'sqlite3'
require 'yaml'

def get_comments_from_api(video_id, api_key, next_page_token = nil)
  puts 'requesting...'
  host = 'https://www.googleapis.com'
  connection = Faraday.new(url: host)
  params = {
    "key": api_key,
    "videoId": video_id,
    "textFormat": "plainText",
    "part": "snippet",
    "maxResults": 100
  }
  if next_page_token != nil
    params['pageToken'] = next_page_token
  end
  puts "Requesting for video #{video_id} comments... Next page token: [#{params['pageToken']}]"
  response = connection.get("/youtube/v3/commentThreads", params)

  unless response.status == 200
    raise Exception("API respond with #{response.status} code")
  end

  response_unserialized = JSON.load(response.body)
  comments = []

  response_unserialized['items'].each do |comment|
    comments.push({
                    'text_original': comment['snippet']['topLevelComment']['snippet']['textOriginal'],
                    'author_display_name': comment['snippet']['topLevelComment']['snippet']['authorDisplayName'],
                    'id': comment['snippet']['topLevelComment']['id'],
                    'like_count': comment['snippet']['topLevelComment']['snippet']['likeCount']
                  })
  end
  sleep 5

  [comments, response_unserialized['nextPageToken']]
end

def persist_comments(db_cursor, comments, ideology)
  comments.each do |comment|
    db_cursor.execute("INSERT OR IGNORE INTO comments (id, text_original, author_display_name, like_count, ideology) VALUES (?, ?, ?, ?, ?)",
                      [comment[:id], comment[:text_original], comment[:author_display_name], comment[:like_count], ideology])
  end
end

Dotenv.load '.env'

# Database initialize
db = SQLite3::Database.open('youtube_comment_threads.db')
db.execute "CREATE TABLE IF NOT EXISTS comments (
    id VARCHAR(512) PRIMARY KEY,
    text_original VARCHAR(2048) NOT NULL,
    author_display_name VARCHAR(512) NOT NULL,
    like_count INTEGER,
    ideology VARCHAR(128)
)"

# Load video identifiers and ideology
videos_list = YAML.load(File.open('targets.yml'))

# Retrieval comments
videos_list.each do |video_data|

  comments, next_page_token = get_comments_from_api(video_data['videoId'], ENV['YOUTUBE_API_KEY'], nil)
  persist_comments(db, comments, video_data['ideology'])

  while next_page_token != nil
    comments, next_page_token = get_comments_from_api(video_data['videoId'], ENV['YOUTUBE_API_KEY'], next_page_token)
    persist_comments(db, comments, video_data['ideology'])
  end

end

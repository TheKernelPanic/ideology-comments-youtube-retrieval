require 'sqlite3'
require 'csv'

data = [
  ['id', 'text_original', 'author_display_name', 'like_count', 'ideology']
]

db = SQLite3::Database.open('youtube_comment_threads.db')
result_set = db.execute "SELECT * FROM comments"
result_set.each do |result|
  data.push(result)
end

CSV.open('output/comments.csv', 'w') do |csv|
  data.each do |row|
    csv << row
  end
end

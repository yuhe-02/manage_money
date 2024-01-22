#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'sqlite3'
require 'cgi/session'
require_relative 'config'


cgi = CGI.new

def create_table(db)
  # テーブルが存在しない場合は作成
  db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS payment_table (
    id INTEGER PRIMARY KEY,
    category TEXT,
    name TEXT,
    price INTEGER,
    comment TEXT,
    date TEXT
  );
  SQL
end

def register_to_database(cgi)
  date_value = cgi.params['date']
  price_value= cgi.params['price']
  category_value = cgi.params['category']
  comment_value = cgi.params['comment']
  name_value = cgi.params['name']

  # データベースに接続
  database = DB_PATH
  db = SQLite3::Database.new(database)

  is_table_exist = db.execute("PRAGMA table_info(payment_table);").empty?
  if is_table_exist
    create_table(db)
  end 
  query_statement = 'INSERT INTO payment_table (category, name, price, comment, date) VALUES (?, ?, ?, ?, ?)'
  db.execute(query_statement, [category_value, name_value, price_value, comment_value, date_value])
end

register_to_database(cgi)

print cgi.header('text/html; charset=utf-8')
print <<EOF
<html>
<head>
    <meta charset='utf-8' />
</head>
<body>
    <p>登録しました</p>
    <p><a href="register_form.rb">もう一度登録する</a></p>
    <p><a href="main.rb">一覧に戻る</a></p>
</body>
</html>
EOF
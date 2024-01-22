#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'sqlite3'
require_relative 'config'

database = DB_PATH
cgi = CGI.new
db = SQLite3::Database.new(database)
result = db.execute("SELECT * FROM  payment_table")
print cgi.header('text/html; charset=utf-8')
print <<EOF
<!DOCTYPE html>
<html lang='ja'>
<head>
</head>
<body>
    <p><a href="calend.rb">カレンダー</a></p>
    <p><a href="graph_by_month.rb">支出割合（月ごと）</a></p>
    <p><a href="graph_by_year.rb">支出割合（年ごと）</a></p>
    <p><a href="register_form.rb">登録する</a></p>
</body>
</html>
EOF

# HTMLの表形式で出力
puts '<table border="1">'
puts '<tr>'
puts '<th>No.</th>'
puts '<th>カテゴリ</th>'
puts '<th>商品名</th>'
puts '<th>金額</th>'
puts '<th>コメント</th>'
puts '<th>日付</th>'
# 列の数に合わせて追加していく

puts '</tr>'

result.each do |row|
  date = row[5][0..3] + "/" + row[5][5..6].to_i.to_s + "/" + row[5][8..9].to_i.to_s
  puts '<tr>'
  puts "<td>#{row[0]}</td>"
  puts "<td>#{row[1]}</td>"
  puts "<td>#{row[2]}</td>"
  puts "<td>#{row[3]}円</td>"
  puts "<td>#{row[4]}</td>"
  puts "<td>#{date}</td>"
  puts '</tr>'
end
puts '</table>'
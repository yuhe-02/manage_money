#!/usr/bin/env ruby

require 'cgi'
require 'date'
require 'sqlite3'
require 'cgi/session'
require_relative 'config'


cgi = CGI.new
session = CGI::Session.new(cgi)
# パラメータから年月を取得する
year = (session['year']|| Date.today.year).to_i
month = (session['month'] || Date.today.month).to_i

def days_in_month(year, month)
    first_day_of_month = Date.new(year, month, 1)
    if month == 12
        first_day_of_next_month = Date.new(year+1, 1, 1)
    else
        first_day_of_next_month = Date.new(year, month + 1, 1)
    end 
    last_day_of_month = first_day_of_next_month - 1
    return last_day_of_month.day
end

def get_selected_data(year,month,session)
    database = DB_PATH
    db = SQLite3::Database.new(database)
    if db.execute("PRAGMA table_info(payment_table);").empty? #ここでテーブルが存在するか確認している
        db.close
        return []
    end
    query_statement = "SELECT date, price FROM payment_table WHERE date LIKE ? ORDER BY date, price"
    result = db.execute(query_statement,"#{year}-#{sprintf('%02d', month)}%")
    db.close
    return result
end 

def create_payment_list(year,month,session)
    days = days_in_month(year, month)
    result = get_selected_data(year,month,session)
    array = Array.new(days, 0)
    result.each do |row|
        date = row[0]
        day = (date[-2]+date[-1]).to_i
        array[day-1] += row[1].to_i
    end
    return array
end

# カレンダーを表示する関数
def display_calendar(year, month, payments)
    first_day = Date.new(year, month, 1)
    last_day = (first_day >> 1) - 1
    days_in_month = (first_day..last_day).to_a
    weekdays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    weekdays = change_weekday_order(year, month, weekdays)
  
    puts "<h2>#{first_day.strftime('%B %Y')}</h2>"
    puts "<table border='1'>"
    puts "<tr>"
    weekdays.each { |day| puts "<th>#{day}</th>" }
    puts "</tr>"
    i = 0
    days_in_month.each_slice(7) do |week|
      puts "<tr>"
      week.each do |day|
        cell = day.month == month ? day.day.to_s : ''
        puts "<td>#{cell}<br>#{payments[i]} 円</td>"
        i += 1
      end
      puts "</tr>"
    end
  
    puts "</table>"
end
  
def change_weekday_order(year, month, weekdays)
      count = 0
      first_day = Date.new(year, month, 1)
      weekday = first_day.strftime("%A")
      if weekday == "Sunday"
          count = 0
      end 
      if weekday == "Monday"
          count = 1
      end 
      if weekday == "Tuesday"
          count = 2
      end 
      if weekday == "Wednesday"
          count = 3
      end 
      if weekday == "Thursday"
          count = 4
      end
      if weekday == "Friday"
          count = 5
      end 
      if weekday == "Saturday"
          count = 6
      end 
      return weekdays.rotate!(count)
end 

def change_year_and_month(change_month,year,month)

    if month == 12 && change_month == 1
        year += change_month
        month = 1

    elsif month == 1 && change_month == -1
        year += change_month
        month = 12
    else 
        month += change_month
    end

    return year,month
end

if cgi.request_method == 'POST'
    # フォームがPOSTメソッドで送信された場合、Cookieを削除
    change_month = cgi.params['submit'][0].to_i
    year,month = change_year_and_month(change_month,year,month)
    session['year'] = year
    session['month'] = month
    session.close
end

print cgi.header('text/html; charset=utf-8')
# # カレンダーを表示
display_calendar(year, month, create_payment_list(year,month,session))
print <<EOF
<!DOCTYPE html>
<html lang='ja'>
    <head>
        <meta charset='utf-8'/>
        <style>
        button {
            background: none;
            border: none;
            padding: 0;
            font: inherit;
            cursor: pointer;
            text-decoration: underline;
            color: blue; /* リンクの色に合わせて適宜変更してください */
        }
        </style>
    </head>
    <body>
        <form method='post'>
            <button type='submit' name='submit' value='-1'>Last Month</button>
            <button type='submit' name='submit' value='1'>Next Month</button>
        </form>
        <p><a href="main.rb">一覧に戻る</a></p>
    </body></html>
EOF

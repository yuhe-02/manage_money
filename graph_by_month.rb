#!/usr/bin/env ruby
# coding: utf-8

require 'cgi'
require 'date'
require 'sqlite3'
require 'cgi/session'
require 'json'
require_relative 'config'


cgi = CGI.new
session = CGI::Session.new(cgi)
# パラメータから年月を取得する
year = (session['year']|| Date.today.year).to_i
month = (session['month'] || Date.today.month).to_i

def get_selected_data(year,month,session)
    database = DB_PATH
    db = SQLite3::Database.new(database)
    if db.execute("PRAGMA table_info(payment_table);").empty? #ここでテーブルが存在するか確認している
        db.close
        return []
    end
    query_statement = "SELECT price, category FROM payment_table WHERE date LIKE ? ORDER BY price, category"
    result = db.execute(query_statement, "#{year}-#{sprintf("%02d", month)}%")
    db.close
    return result
end 

def create_payment_list(year,month,session)
    result = get_selected_data(year,month,session)
    payment_hash = {}
    payment_list = [['Category', 'Payment']]
    all_price = 0
    result.each do |row|
        category = row[1]
        price = row[0]

        # カテゴリが存在しない場合は初期化
        payment_hash[category] ||= 0

        # カテゴリごとに支出を合計
        payment_hash[category] += price
    end
    payment_hash.each do |key, value|
        payment_list.append([key,value])
        all_price += value
    end
    return payment_list.to_json,all_price
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

payments,all_price = create_payment_list(year,month,session)
first_day = Date.new(year, month, 1)

print cgi.header('text/html; charset=utf-8')
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
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script type="text/javascript">
          google.charts.load('current', {'packages':['corechart']});
          google.charts.setOnLoadCallback(drawChart);
    
          function drawChart() {
            var data = google.visualization.arrayToDataTable(#{payments});
    
            var options = {
              title: '支出割合（カテゴリ別）'
            };
    
            var chart = new google.visualization.PieChart(document.getElementById('piechart'));
    
            chart.draw(data, options);
          }
        </script>
    </head>
    <body>
        <form method='post'>
        <button type='submit' name='submit' value='-1'>Last Month</button>
        <div style='margin: 0 10px; display: inline-block;'>
            <h2>#{first_day.strftime('%B %Y')}</h2>
        </div>
        <button type='submit' name='submit' value='1'>Next Month</button>
        </form>
        <h3>合計額：#{all_price}円</h3>
        <div id="piechart" style="width: 900px; height: 500px;"></div>
        <p><a href="main.rb">一覧に戻る</a></p>
    </body></html>
EOF

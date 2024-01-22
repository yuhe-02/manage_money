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

def get_selected_data(year,session)
    database = DB_PATH
    db = SQLite3::Database.new(database)
    if db.execute("PRAGMA table_info(payment_table);").empty? #ここでテーブルが存在するか確認している
        db.close
        return []
    end
    query_statement = "SELECT price, category, date FROM payment_table WHERE date LIKE ? ORDER BY price, category, date"
    result = db.execute(query_statement,"#{year}%")
    db.close
    return result
end 

def create_hash_from_sql(result)
    category_hash = {}
    month_hash = {}
    result.each do |row|
        category = row[1]
        price = row[0]
        month = ((row[2][-5] + row[2][-4]).to_i).to_s + "月"

        # カテゴリが存在しない場合は初期化
        category_hash[category] ||= 0
        category_hash[category] += price

        month_hash[month] ||= 0
        month_hash[month] += price
    end
    return category_hash,month_hash
end

def create_categorized_list(result)
    payment_by_category = [['Category', 'Payment']]
    payment_by_month = [['Month', 'Payment']]
    category_hash,month_hash = create_hash_from_sql(result)
    all_price = 0
    category_hash.each do |key, value|
        payment_by_category.append([key,value])
        all_price += value
    end
    month_hash.each do |key, value|
        payment_by_month.append([key,value])
    end
    return [payment_by_category, payment_by_month],all_price
end

def create_payment_list(year,session)
    result = get_selected_data(year,session)
    payments,all_price = create_categorized_list(result)
    return [payments[0].to_json, payments[1].to_json],all_price
end  

if cgi.request_method == 'POST'
    # フォームがPOSTメソッドで送信された場合、Cookieを削除
    change = cgi.params['submit'][0].to_i
    year += change
    session['year'] = year
    session.close
end

payments,all_price = create_payment_list(year,session)

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
            var data = google.visualization.arrayToDataTable(#{payments[0]});
    
            var options = {
              title: '支出割合（カテゴリ別）'
            };
    
            var chart = new google.visualization.PieChart(document.getElementById('piechart_category'));
    
            chart.draw(data, options);
          }
        </script>
        <script type="text/javascript">
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawChart);
  
        function drawChart() {
          var data = google.visualization.arrayToDataTable(#{payments[1]});
  
          var options = {
            title: '支出割合（月別）'
          };
  
          var chart = new google.visualization.PieChart(document.getElementById('piechart_month'));
  
          chart.draw(data, options);
          }
        </script>
    </head>
    <body>
        <form method='post'>
            <button type='submit' name='submit' value='-1'>Last Year</button>
            <div style='margin: 0 10px; display: inline-block;'>
                <h2>#{year}</h2>
            </div>
            <button type='submit' name='submit' value='1'>Next Year</button>
        </form>
        <h3>合計額：#{all_price}円</h3>
        <div id="piechart_category" style="width: 900px; height: 500px;"></div>
        <div id="piechart_month" style="width: 900px; height: 500px;"></div>

        <p><a href="main.rb">一覧に戻る</a></p>
    </body></html>
EOF

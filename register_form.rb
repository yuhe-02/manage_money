#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'date'
require 'sqlite3'

cgi = CGI.new
today = Date.today
categories = ["食費", "交際費", "交通費", "生活費（家賃等）", "ガソリン代", "その他"]

def escape_html(input)
  CGI.escapeHTML(input.to_s)
end

def validate_numeric(value)
  Float(value) rescue false
end

print cgi.header('text/html; charset=utf-8')
print <<EOF
<!DOCTYPE html>
<html lang='ja'>
<head>
  <title>支出登録画面</title>
  <meta charset='utf-8'/>
  <script>
    function validateForm() {
      var categoryField = document.getElementById('category');
      var nameField = document.getElementById('name');
      var priceField = document.getElementById('price');
      var commentField = document.getElementById('comment');

      // カテゴリ、商品名、金額が空欄でないかを確認
      if (categoryField.value.trim() === '' || nameField.value.trim() === '' || priceField.value.trim() === '') {
        alert('カテゴリ、商品名、金額は必須項目です。');
        return false;
      }

      // タグを含んでいるかどうかをチェックする正規表現
      var tagRegex = /<[^>]*>/;

      // カテゴリ、商品名、コメントフィールドを検証
      var fieldsToCheck = [
        { field: nameField, fieldName: '商品名' },
        { field: commentField, fieldName: 'コメント' }
      ];

      for (var i = 0; i < fieldsToCheck.length; i++) {
        var fieldObj = fieldsToCheck[i];
        var fieldValue = fieldObj.field.value;

        // タグが含まれている場合はエラーメッセージを表示
        if (tagRegex.test(fieldValue)) {
          alert(fieldObj.fieldName + 'にはHTMLタグを含めることはできません。');
          fieldObj.field.focus(); // エラーがあった場合、対象のフィールドにフォーカスを戻す
          return false;
        }
      }

      // 金額には数値を入力しているかどうかをチェック
      if (!validateNumeric(priceField.value)) {
        alert('金額には数値を入力してください。');
        priceField.focus(); // エラーがあった場合、金額フィールドにフォーカスを戻す
        return false;
      }

      // ここに他のバリデーションを追加できます

      return true; // フォームが正常ならtrueを返す
    }
  </script>
</head>
<body>
  <h1>登録画面</h1>
  <form method='get' action='register_database.rb' onsubmit='return validateForm();'>
    <p>
      <label>カテゴリ：</label>
      <select id='category' name='category'>
EOF

categories.each do |category|
  print "<option value='#{escape_html(category)}'>#{escape_html(category)}</option>"
end

print <<EOF
      </select>
    </p>
    <p>
      <label>商品名：　</label>
      <input type='text' id='name' name='name' value='' />
    </p>
    <p>
      <label>金額：　　</label>
      <input type='number' id='price' name='price' value='' />
      <label>円</label>
    </p>
    <p>
      <label>コメント：</label>
      <input type='text' id='comment' name='comment' value='' />
    </p>
    <label for='date'>日付：　　</label>
    <input type='date' id='date' name='date' value='#{escape_html(today)}' />
    <br>
    <input type='submit' value='登録' />
  </form>
  <p><a href="main.rb">一覧に戻る</a></p>
</body>
</html>
EOF

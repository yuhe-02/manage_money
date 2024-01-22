【Concept】
This application is created with a sole focus on expense management. Consequently, it allows for easy and straightforward management. 
A notable feature of this application is the ability to view past expenditure records from various perspectives. Specifically, 
this includes daily expenditure records from the calendar, graphs depicting the percentage of food expenses for each month, 
graphs showing the percentage of food expenses for the entire year, and monthly expenditure breakdowns.
One innovative aspect is the arrangement of the calendar. 
Overcoming the difficulty of associating dates with weekdays, a solution was found by adjusting the days of the week.

【Technical Perspective】
The programming language used is Ruby, utilizing CGI for the web application.
From a security standpoint, measures were taken to address SQL injection vulnerabilities, 
and there were thoughtful considerations regarding changing access permissions to the database and configuration files.
Additionally, when changing the displayed date, the application records the date before being clicked using session and date, 
and by implementing conditional branching for cases where the date crosses over to a new year, it becomes possible to modify the displayed date.

【Challenges】
Database creation or display for each user has not been implemented.
The weekday arrangement on the overview screen changes every month.
Lack of consistency in design.

【コンセプト】
このアプリケーションは、支出管理に焦点を絞り開発されました。そのため、簡単かつ直感的な管理が可能です。
このアプリケーションの特徴の一つは、様々な視点から過去の支出記録を確認できる点です。具体的には、カレンダーからの日毎の支出記録、
各月の食費の割合を示すグラフ、その年の食費の割合を示すグラフ、そして月ごとの支出内訳が含まれます。
工夫した点としては、カレンダーの配置です。曜日と日付を関連付ける難しさを克服するため、曜日を調整することで解決策が見つかりました。

【技術的な観点】
使用言語はRubyで、WebアプリケーションにはCGIが利用されています。
セキュリティの観点からは、SQLインジェクションへの対策が施され、データベースおよび設定ファイルへのアクセス権限の変更にも注意が払われました。
また、表示されている日付を変更する際には、セッションと日付を利用してクリックされる前の日付を記録し、年をまたぐ場合の条件分岐を実装することで表示される日付を変更できるようにしました。

【課題】
ユーザーごとにデータベースの作成または表示が実装されていません。
一覧画面の曜日配置が毎月変わっています。
デザインに統一性がない。

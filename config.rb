# config.rb

require 'sqlite3'

# データベースのパス
DB_PATH = 'database.db'

# SQLite3データベースの作成とテーブルの作成
def create_database
  begin
    db = SQLite3::Database.new(DB_PATH)

    # テーブルが存在しない場合に作成
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS payment_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        name TEXT,
        price INTEGER,
        comment TEXT,
        date DATE
      );
    SQL

  rescue SQLite3::Exception => e
    puts "An error occurred while creating the database and table: #{e.message}"
  ensure
    db&.close
  end
end

# データベース作成の呼び出し
create_database

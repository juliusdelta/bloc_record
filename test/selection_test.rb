require_relative './test_helper.rb'

class Entry < BlocRecord::Base

  def self.connect_to_database
    db = SQLite3::Database.new 'test_db.sqlite'
    db.execute <<-SQL
      CREATE TABLE entry
       id INTEGER PRIMARY KEY,
       name VARCHAR(30),
       phone_number INTEGER;
    SQL

    BlocRecord.connect_to("db/test_db.sqlite")
  end

end

class SelectionTest < MiniTest::Test

  def setup
    Entry.create('Foo One', '999-999-9999')
  end

  def test_persistance_works
    assert Entry.find(0).name == 'Foo One'
  end

end

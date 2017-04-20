require_relative './test_helper.rb'
BlocRecord.connect_to('test_db.sqlite')
class Entry < BlocRecord::Base

  def self.create_table

    db = SQLite3::Database.new 'test_db.sqlite'
    db.execute('DROP TABLE entry')
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS entry (
       id INTEGER PRIMARY KEY,
       name VARCHAR(30),
       phone_number INTEGER
       );
    SQL
  end
end

class BlocRecordTest < MiniTest::Test

  def setup
    Entry.create_table
    Entry.create({'name' =>'Foo One', 'phone_number' =>'999-999-9999'})
  end

  def test_last_works
    assert_equal Entry.last.name, 'Foo One'
    assert_equal Entry.last.phone_number, '999-999-9999'
  end

end

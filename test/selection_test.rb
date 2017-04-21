require_relative './test_helper.rb'
BlocRecord.connect_to('test_db.sqlite')
class Entry < BlocRecord::Base

  def self.create_table
    db = SQLite3::Database.new 'test_db.sqlite'
    db.execute("DROP TABLE entry;")
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
    Entry.create({'name' => 'Foo Two', 'phone_number' => '888-888-8888'})
    Entry.create({'name' => 'Foo Three', 'phone_number' => '777-777-7777'})
    Entry.create({'name' => 'Foo Four', 'phone_number' => '666-666-6666'})
  end

  def test_first_works
    assert_equal Entry.first.name, 'Foo One'
    assert_equal Entry.first.phone_number, '999-999-9999'
  end

  def test_last_works
    assert_equal Entry.last.name, 'Foo Four'
    assert_equal Entry.last.phone_number, '666-666-6666'
  end

  def test_find_one_works
    assert_equal Entry.find(2).name, 'Foo Two'
  end

  def test_find_multiple_works
    assert_equal Entry.find(1, 2)[0].name, 'Foo One'
    assert_equal Entry.find(1, 2)[1].name, 'Foo Two'
    assert_equal Entry.find(1, 2)[0].phone_number, '999-999-9999'
    assert_equal Entry.find(1, 2)[1].phone_number, '888-888-8888'
  end

  def test_find_by
    assert_equal Entry.find_by(:name, 'Foo Four').phone_number, '666-666-6666'
  end

  def test_method_missing_with_missing_method
    assert_equal Entry.find_by_age('Foo One'), 'There is no find_by_age'
  end

  def test_method_missing_with_valid_method
    assert_equal Entry.find_by_name('Foo One').phone_number, '999-999-9999'
  end

  def test_take_one
    refute_equal Entry.take_one, nil
  end

  def test_all
    get_all = Entry.all
    assert_equal get_all[0].name, 'Foo One'
    assert_equal get_all[0].phone_number, '999-999-9999'
    assert_equal get_all[1].name, 'Foo Two'
    assert_equal get_all[1].phone_number, '888-888-8888'
    assert_equal get_all[2].name, 'Foo Three'
    assert_equal get_all[2].phone_number, '777-777-7777'
    assert_equal get_all[3].name, 'Foo Four'
    assert_equal get_all[3].phone_number, '666-666-6666'
    assert_nil get_all[4]
  end

  ## Exception Testing

  def test_find_one_exception
    assert_raises(ArgumentError){ Entry.find("1") }
  end


end

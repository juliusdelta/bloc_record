require 'sqlite3'

module Selection
  def find(*ids)

    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)

    # Exception one: Validates input is of numeric type and not another type
    unless id.is_a?(Integer)
      raise ArgumentError.new('ID must be an integer')
    end

    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id = #{id};
    SQL

    init_object_from_row(row)
  end

  def find_by(attribute, value)

    # Exception one: Validates that both inputs are strings and not other types of input
    unless value.is_a?(String)
      raise ArgumentError.new('Input Values must be strings!')
    end

    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    init_object_from_row(row)
  end

  def method_missing(m, *args, &block)
    if m == :find_by_name
      return find_by(:name, "#{args[0]}")
    else
     return "There is no #{m} method!"
    end
  end

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  def find_each(start=1, batch_size=nil)

    unless start.is_a?(Integer) && batch_size.is_a?(Integer) || batch_size == nil
      raise ArgumentError.new('Arguments must be integers')
    end

    if batch_size == nil
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
      SQL
    elsif batch_size != nil
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        LIMIT #{batch_size} OFFSET #{start};
      SQL
    end

    yield( rows_to_array(rows) )
  end

  def find_in_batches(start=1, batch_size=1)
    unless start.is_a?(Integer) && batch_size.is_a?(Integer)
      raise ArgumentError.new('Arguments must be integers')
    end

    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size} OFFSET #{start};
    SQL

    rows.each do |row|
      yield(row)
    end

  end

  def where(*args)
    if args.count > 1
      expression = args.shift
      params = args
    else
      case args.first
      when String
        expression = args.first
      when Hash
        expression_hash = BlocRecord::Utility.convert_keys(args.first)
        expression = expression_hash.map{ |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }.join(" and ")
      end
    end

    sql == <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{expression};
    SQL

    rows = connection.execute(sql, params)
    rows_to_array(rows)
  end

  def order(*args)
    orders = []

    if args
      args.each do |arg|
        if arg.kind_of? String
          orders << assend_descend(arg)
        elsif arg.kind_of? Symbol
          orders << assend_descend(arg.to_s)
        end
      end
    end

    orders.join(',')


    rows = connection.execute <<-SQL
      SELECT * FROM #{table}
      ORDER BY #{orders};
    SQL

    rows_to_array(rows)
  end

  def join(*args)
    if args.count > 1
      joins = args.map { |arg| "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"}.join(" ")
      rows = connection.execute <<-SQL
         SELECT * FROM #{table} #{joins}
       SQL
    else
      case args.first
      when String
        rows = connection.execute <<-SQL
           SELECT * FROM #{table} #{BlocRecord::Utility.sql_strings(args.first)};
         SQL
      when Symbol
        rows = connection.execute <<-SQL
           SELECT * FROM #{table}
           INNER JOIN #{args.first} ON #{args.first}.#{table}_id = #{table}.id
         SQL
      when Hash
        key = args.first.keys[0]
        value = args.first.values[0]
        rows = connection.execute <<-SQL
          SELECT * FROM #{table}
          INNER JOIN #{key} ON #{key}.#{table}_id = #{table}.id
          INNER JOIN #{value} ON #{value}.#{key}_id = #{key}.id
        SQL
      end
    end

    rows_to_array(rows)
  end

  private

  def assend_descend(string)
    if string.include?(" asc") || string.include?(" ASC") || string.include?(" desc") || string.include?(" DESC")
      return string
    else
      string << " ASC"
    end
  end

  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    collection = BlocRecord::Collection.new
    rows.each { |row| collection << new(Hash[columns.zip(row)]) }
    collection
  end

end

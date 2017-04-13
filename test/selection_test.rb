require 'test_helper'

class SelectionTest < MiniTest::Unit::TestCase

  def select_by_id
    find_by(5, 5)
  end
end

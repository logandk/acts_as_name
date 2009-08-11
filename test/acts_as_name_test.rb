require 'test/unit'
require 'test_helper'
require 'acts_as_name'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :cooks do |t|
      t.column :first_name, :string
      t.column :last_name, :string
    end
    
    create_table :chefs do |t|
      t.column :name1, :string
      t.column :last_name, :string
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Cook < ActiveRecord::Base
  acts_as_name
end

class Chef < ActiveRecord::Base
  acts_as_name :first_name_column => :name1
end

class ActsAsNameTest < Test::Unit::TestCase
  
  def setup
    setup_db

    @cook1 = Cook.create! :first_name => "John", :last_name => "Doe"
    @cook2 = Cook.create! :first_name => "Paul", :last_name => "Jameson"
    
    @chef1 = Chef.create! :name1 => "Luke", :last_name => "Skywalker"
    @chef2 = Chef.create! :name1 => "Chewy", :last_name => "Chewbacca"
  end

  def teardown
    teardown_db
  end
  
  def test_should_require_name
    assert_raise(ActiveRecord::RecordInvalid) { Cook.create!(:first_name => "John") }
    assert_raise(ActiveRecord::RecordInvalid) { Chef.create!(:last_name => "Test") }
  end
  
  def test_should_return_full_name
    assert_equal "John Doe", @cook1.name
    assert_equal "Luke Skywalker", @chef1.name
  end
  
  def test_should_return_short_name
    assert_equal "J. Doe", @cook1.name(:format => :short)
    assert_equal "L. Skywalker", @chef1.name(:format => :short)
  end
  
  def test_should_return_letter
    assert_equal "P", @cook2.letter
    assert_equal "C", @chef2.letter
  end
  
  def test_should_find_objects
    assert_equal [@cook2], Cook.name_like("Jameson")
    assert_equal [@chef2], Chef.name_like("Chew")
    assert_equal [@cook1, @cook2], Cook.name_like("J")
  end
end
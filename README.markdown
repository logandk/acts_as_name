`acts_as_name` - Helpers for managing first and last name columns
===============================================================

This is a Ruby on Rails plugin that adds some functionality to `ActiveRecord`, to ease the handling of names that are split into two columns.


Installation
============

As a Rails Plugin
-----------------

Use this to install as a plugin in a Ruby on Rails app:

	$ script/plugin install git://github.com/logandk/acts_as_name.git


As a Rails Plugin (using git submodules)
----------------------------------------

Use this if you prefer the idea of being able to easily switch between using edge or a tagged version:

	$ git submodule add git://github.com/logandk/acts_as_name.git vendor/plugins/acts_as_name



Usage
=====

After installation, create your migration:

	class CreatePeople < ActiveRecord::Migration
	  def self.up
	    create_table :people do |t|
	      t.string :first_name, :null => false
	      t.string :last_name, :null => false
	    end
	  end

	  def self.down
	    drop_table :people
	  end
	end


In this case, the name is split into a `first_name` and a `last_name` column.

Next, create your model:

	class Person < ActiveRecord::Base
		acts_as_name
	end

You can now use the helper methods provided by this plugin:

	>> @person = Person.find :first
	=> #<Person first_name: "John", last_name: "Johnson", ...>
	
	>> @person.name
	=> "John Johnson"
	
	>> @person.letter
	=> "J"
	
	>> @person.name :format => :short
	=> "J. Johnson"
	
	>> Person.name_like "John"
	=> [#<Person id:...>, #<Person id:...>]


Configuration
-------------

You can configure the plugin in your model:

	class Person < ActiveRecord::Base
		acts_as_name :first_name_column => "name1", :last_name_column => "name2"
	end


Credits
=======
Copyright (c) 2009 Logan Raarup, released under the MIT license
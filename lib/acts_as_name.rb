module ActsAsName
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # Includes the methods of this module into the ActiveRecord model.
    # Options:
    # * `:first_name_column` sets the name of the column containing the first name. Defaults to "first_name".
    # * `:last_name_column` sets the name of the column containing the last name. Defaults to "last_name".
    #
    # Example:
    #   acts_as_name :first_name_column => "name1", :last_name_column => "name2"
    def acts_as_name(options = {})
      cattr_accessor :first_name_column
      cattr_accessor :last_name_column
      
      configuration = { :first_name_column => "first_name", :last_name_column => "last_name" }
      configuration.update(options) if options.is_a?(Hash)
      
      self.first_name_column = configuration[:first_name_column].to_s
      self.last_name_column = configuration[:last_name_column].to_s
      
      validates_presence_of self.first_name_column
      validates_presence_of self.last_name_column
      
      named_scope :name_like, lambda { |search_name|
        search_name = "\%#{search_name}\%"
        { :conditions => ["LOWER(#{self.first_name_column}) LIKE ? OR LOWER(#{self.last_name_column}) LIKE ?", search_name.downcase, search_name.downcase] }
      }
      
      send :include, InstanceMethods
    end
  end

  module InstanceMethods
    # Returns the uppercase first letter of the first name, and `nil` on error.
    def letter
      first_letter(self.send(self.class.first_name_column).to_s)
    end

    # Returns the full name, combined of the first and last names. The format is configurable through `:format`:
    # * `:normal` (default): John Johnson (both names complete)
    # * `:short`: J. Johnson (first letter of firstname and complete last name)
    #
    # Example:
    #   @person.name
    #   @person.name :format => :short
    def name(options = {})
      configuration = { :format => :normal }
      configuration.update(options) if options.is_a?(Hash)
      
      case configuration[:format].to_sym
      when :short
        first_letter(self.send(self.class.first_name_column).to_s) + ". " + self.send(self.class.last_name_column).to_s
      else
        self.send(self.class.first_name_column).to_s + " " + self.send(self.class.last_name_column).to_s
      end
    rescue
      nil
    end
    
    private
      def first_letter(text)
        text[0].chr.upcase rescue nil
      end
  end
end

ActiveRecord::Base.send :include, ActsAsName
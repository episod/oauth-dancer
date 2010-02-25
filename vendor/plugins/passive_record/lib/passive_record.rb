module PassiveRecord
  class Base
  
    # Assign values to each of the attributes passed in the params hash
    def initialize(params = {})
      params.each { |k, v| send("#{k}=", v)}
    end
  
    # Date accessors to be consistent with ActiveRecord: 
    attr_accessor :created_at, :updated_at
  
    # Return a hash of the class's attribute names and values
    #   @name.attributes => {:first_name=>"Dima", :last_name=>"Dozen"}
    def attributes
      @attributes = {}
      self.class.fields.flatten.each {|att| @attributes[att] = self.send(att) }
      @attributes
    end
  
    # Compare this object with another object of the same class. 
    # Returns true if the attributes and values are identical. 
    #   @name === @name   #=> true
    #   @name === @name2  #=> false
    def ===(other)
      self.attributes == other.attributes
    end
    
    def new_record?
      self.respond_to?(:id) and !id.blank? ? false : true
    end
  
    class_inheritable_accessor :fields, :associations
  
    class << self
      # Provide some basic ActiveRecord-like methods for working with non-ActiveRecord objects
      #   class Person < PassiveRecord::Base
      #     has_many :names, :addresses, :phone_numbers
      #   end
      def has_many(*associations)
        # Simply sets up an attr_accessor for each item in the list
        self.associations = associations
        associations.each {|association| attr_accessor association}
      end
      alias_method :belongs_to, :has_many
      
      # Creates instance methods for each item in the list. Expects an array
      #   class Address < PassiveRecord::Base
      #     define_fields :street, :city, :state, :postal_code, :country
      #   end
      def define_fields(*attrs)
        self.fields ||= []
        self.fields << attrs
        self.fields = self.fields.flatten.uniq
        # Assign attr_accessor for each attribute in the list
        attrs.each {|att| attr_accessor att}
      end
    
      # Return the list of available fields for the class
      # 
      #   Name.fields #=> [:id, :first_name, :last_name]
      # def fields
      #   @fields
      # end
    
      # Returns the list of available has_many associations
      # 
      #   Model.associations #=> [:names, :addresses]
    end
  
  end
end
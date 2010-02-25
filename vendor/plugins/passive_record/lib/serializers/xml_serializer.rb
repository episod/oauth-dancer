module PassiveRecordModule
  module Serialization
    class XmlSerializer
      # Builds an XML document to represent the model.
      #
      # @my_passive_model.to_xml
      # @my_passive_model.to_xml(:skip_instruct => true, :root => "records")
      #
      # Associations:
      #   @my_passive_model.to_xml(:include => :all) # include all associations
      #   @my_passive_model.to_xml(:include => [:specific_association]) # include the specific association
      #
      # Including aditional methods:
      #   Post < PassiveRecord
      #     define_attributes [:title, :content, :created_by]
      #     
      #     def complete_title
      #       "#{self.title} by #{self.created_by}"
      #     end
      #   end
      #
      #   post = Post.new(:title => 'Open source projects are awesome!', :created_by => 'Felipe Mesquita', :content => '...')
      #   post.to_xml
      #     #=>   <?xml version='1.0' encoding='UTF-8'?>
      #           <post>
      #             <title>Open source projects are awesome!</title>
      #             <created_by>Felipe Mesquita</created_by>
      #             <content>...</content>
      #           </post>
      #
      #   post.to_xml(:methods => [:complete_title])
      #     #=>   <?xml version='1.0' encoding='UTF-8'?>
      #           <post>
      #             <title>Open source projects are awesome!</title>
      #             <created_by>Felipe Mesquita</created_by>
      #             <content>...</content>
      #             <complete-title>Open source projects are awesome! by Felipe Mesquita</complete-title>
      #           </post>
      #
      def to_xml(record, options = {})
        options.reverse_merge!({ :root => record.class.to_s.underscore })
        attributes = record.attributes
        attributes.merge!(includes_of(record, options[:include]))
        attributes.merge!(methods_of(record, options[:methods]))
        attributes.to_xml(options)
      end

      protected
        def methods_of(record, methods)
          methods_hashed = {}
          unless methods.nil?
            methods.inject(methods_hashed) do |hash, aditional_method|
              hash.merge!({ aditional_method.to_sym => record.send(aditional_method.to_sym) })
            end
          end
          methods_hashed
        end
      
        def includes_of(record, includes)
          if includes.nil?
            return {}
          elsif (includes.is_a?(Symbol) && includes == :all)
            includes = record.class.associations
          end
          includes.inject({}) do |hash, attribute|
            association = record.send(attribute.to_sym)
            attrs = association.is_a?(Array) ? association.collect { |a| a.attributes } : association.attributes rescue {}
            hash.merge!({ attribute.to_sym => attrs })
          end
        end
    end
  end
end

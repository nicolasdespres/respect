module Respect
  # A schema to specify a JSON array.
  #
  # They are two approaches to specify the structure of a JSON array.
  #
  # If the items of your array have all the same structures then you
  # should use the _item_ method to set their schema.
  #
  # Example:
  #   # An array where all items are integer greater than 42.
  #   s = ArraySchema.define do |s|
  #     s.item do |s|
  #       s.integer greater_than: 42
  #     end
  #   end
  #   s.validate?([])              #=> true
  #   s.validate?([ 43 ])          #=> true
  #   s.validate?([ 43, 44 ])      #=> true
  #   s.validate?([ 43, 44, 30 ])  #=> false
  #
  # Otherwise, you should use the _items_ and _extra_items_. This is called
  # "tuple" typing.
  #
  # Example:
  #   # An array where first item is an integer and the second one
  #   # is a string.
  #   ArraySchema.define do |s|
  #     s.items do |s|
  #       s.integer
  #       s.string
  #     end
  #   end
  #   s.validate?([])              #=> false
  #   s.validate?([ 43 ])          #=> false
  #   s.validate?([ 43, "foo" ])   #=> true
  #   s.validate?([ 43, 44 ])      #=> false
  #
  # You cannot mix tuple typing and single item typing.
  #
  # You can pass several options when creating an ArraySchema:
  # +uniq+:     if true, duplicated items are forbidden (false by default).
  # +min_size+: if set the array must have at least the given number of items
  #             (nil by default). This option apply only in non-tuple typing.
  # +max_size+: if set the array must have at most the given number of items
  #             (nil by default). This option apply only in non-tuple typing.
  class ArraySchema < Schema

    public_class_method :new

    class << self
      # Overwritten method. See Schema::default_options
      def default_options
        super().merge({
            uniq: false,
          }).freeze
      end
    end

    def initialize(options = {})
      super(self.class.default_options.merge(options))
    end

    # Set the schema that all items in the array must validate.
    def item=(item)
      if @items
        raise InvalidSchemaError,
              "cannot mix single item and multiple items validation"
      end
      @item = item
    end

    # Set the array of schema that the corresponding item must validate.
    def items=(items)
      if @item
        raise InvalidSchemaError,
              "cannot mix single item and multiple items validation"
      end
      @items = items
    end

    # Set extra schema items. These are optional. If they are not in the
    # document the validation pass anyway.
    def extra_items=(extra_items)
      return @extra_items unless extra_items
      if @item
        raise InvalidSchemaError,
              "cannot mix single item and extra items validation"
      end
      @items = [] if @items.nil?
      @extra_items = extra_items
    end

    def validate(doc)
      unless doc.is_a?(Array)
        raise ValidationError, "document is not an array but a #{doc.class}"
      end
      # At this point we are sure @item and (@items or @extra_items) cannot be
      # defined both. (see the setters).
      sanitized_doc = []
      # Validate expected item.
      if @item
        if options[:min_size] && doc.size < options[:min_size]
          raise ValidationError,
                "expected at least #{options[:min_size]} item(s) but got #{doc.size}"
        end
        if options[:max_size] && doc.size > options[:max_size]
          raise ValidationError,
                "expected at most #{options[:min_size]} item(s) but got #{doc.size}"
        end
        doc.each_with_index do |item, i|
          validate_item(i, @item, doc, sanitized_doc)
        end
      end
      # Validate doc items count.
      if @items || @extra_items
        if @extra_items
          min_size = @items ? @items.size : 0
          unless min_size <= doc.size
            raise ValidationError,
                  "array size should be at least #{min_size} but is #{doc.size}"
          end
        else
          if @items.size != doc.size
            raise ValidationError,
                  "array size should be #{@items.size} but is #{doc.size}"
          end
        end
      end
      # Validate expected multiple items.
      if @items
        @items.each_with_index do |schema, i|
          validate_item(i, schema, doc, sanitized_doc)
        end
      end
      # Validate extra items.
      if @extra_items
        @extra_items.each_with_index do |schema, i|
          if @items.size + i < doc.size
            validate_item(@items.size + i, schema, doc, sanitized_doc)
          end
        end
      end
      # Validate all items are unique.
      if options[:uniq]
        s = Set.new
        doc.each_with_index do |e, i|
          if s.add?(e).nil?
            raise ValidationError,
                  "duplicated item number #{i}"
          end
        end
      end
      self.sanitized_doc = sanitized_doc
      true
    end

    private

    def validate_item(index, schema, doc, sanitized_doc)
      begin
        schema.validate(doc[index])
        sanitized_doc << schema.sanitized_doc
      rescue ValidationError => e
        e.context << "in array #{index.ordinalize} item"
        raise e
      end
    end
  end
end

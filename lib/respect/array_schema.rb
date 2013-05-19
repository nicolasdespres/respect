module Respect
  # A schema to specify the structure of an array.
  #
  # They are two approaches to specify the structure of an array.
  #
  # If the items of your array have all the same structure then you
  # should use the {#item=} method to set their schema.
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
  # Otherwise, you should use the {#items=} and {#extra_items=}. This is called
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
  # You can pass several options when creating an {ArraySchema}:
  # uniq::     if +true+, duplicated items are forbidden (+false+ by default).
  # min_size:: if set the array must have at least the given number of items
  #            (+nil+ by default). This option apply only in non-tuple typing.
  # max_size:: if set the array must have at most the given number of items
  #            (+nil+ by default). This option apply only in non-tuple typing.
  class ArraySchema < Schema

    public_class_method :new

    class << self
      # Overwritten method. See {Schema.default_options}
      def default_options
        super().merge({
            uniq: false,
          }).freeze
      end
    end

    def initialize(options = {})
      super(self.class.default_options.merge(options))
    end

    def initialize_copy(other)
      super
      @items = other.items.dup unless other.items.nil?
      @extra_items = other.extra_items.dup unless other.extra_items.nil?
    end

    # Set the schema that all items in the array must validate.
    def item=(item)
      if @items
        raise InvalidSchemaError,
              "cannot mix single item and multiple items validation"
      end
      @item = item
    end

    # Get the schema that all items in the array must validate.
    attr_reader :item

    # Set the array of schema that the corresponding items must validate.
    def items=(items)
      if @item
        raise InvalidSchemaError,
              "cannot mix single item and multiple items validation"
      end
      @items = items
    end

    # Get the array of schema that the corresponding items must validate.
    attr_reader :items

    # Set extra schema items. These are optional. If they are not in the
    # object the validation pass anyway.
    def extra_items=(extra_items)
      return @extra_items unless extra_items
      if @item
        raise InvalidSchemaError,
              "cannot mix single item and extra items validation"
      end
      @items = [] if @items.nil?
      @extra_items = extra_items
    end

    # Get the extra schema items.
    attr_reader :extra_items

    # Overwritten method. See {Schema#validate}
    def validate(object)
      # Handle nil case.
      if object.nil?
        if allow_nil?
          self.sanitized_object = nil
          return true
        else
          raise ValidationError, "object is nil but this array schema does not allow nil"
        end
      end
      # Validate type.
      unless object.is_a?(Array)
        raise ValidationError, "object is not an array but a #{object.class}"
      end
      # At this point we are sure @item and (@items or @extra_items) cannot be
      # defined both. (see the setters).
      sanitized_object = []
      # Validate expected item.
      if @item
        if options[:min_size] && object.size < options[:min_size]
          raise ValidationError,
                "expected at least #{options[:min_size]} item(s) but got #{object.size}"
        end
        if options[:max_size] && object.size > options[:max_size]
          raise ValidationError,
                "expected at most #{options[:min_size]} item(s) but got #{object.size}"
        end
        object.each_with_index do |item, i|
          validate_item(i, @item, object, sanitized_object)
        end
      end
      # Validate object items count.
      if @items || @extra_items
        if @extra_items
          min_size = @items ? @items.size : 0
          unless min_size <= object.size
            raise ValidationError,
                  "array size should be at least #{min_size} but is #{object.size}"
          end
        else
          if @items.size != object.size
            raise ValidationError,
                  "array size should be #{@items.size} but is #{object.size}"
          end
        end
      end
      # Validate expected multiple items.
      if @items
        @items.each_with_index do |schema, i|
          validate_item(i, schema, object, sanitized_object)
        end
      end
      # Validate extra items.
      if @extra_items
        @extra_items.each_with_index do |schema, i|
          if @items.size + i < object.size
            validate_item(@items.size + i, schema, object, sanitized_object)
          end
        end
      end
      # Validate all items are unique.
      if options[:uniq]
        s = Set.new
        object.each_with_index do |e, i|
          if s.add?(e).nil?
            raise ValidationError,
                  "duplicated item number #{i}"
          end
        end
      end
      self.sanitized_object = sanitized_object
      true
    rescue ValidationError => e
      # Reset sanitized object.
      self.sanitized_object = nil
      raise e
    end

    def ==(other)
      super && @item == other.item && @items == other.items && @extra_items == other.extra_items
    end

    private

    def validate_item(index, schema, object, sanitized_object)
      begin
        schema.validate(object[index])
        sanitized_object << schema.sanitized_object
      rescue ValidationError => e
        e.context << "in array #{index.ordinalize} item"
        raise e
      end
    end
  end
end

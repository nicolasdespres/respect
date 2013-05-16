module Respect
  class ColorSchema < Schema

    public_class_method :new

    def initialize(options = {})
      super
      @red, @green, @blue, @alpha = 0, 0, 0, 0
    end

    attr_accessor :red, :green, :blue, :alpha

    def validate(doc)
      color = nil
      begin
         color = Color.from_string(doc.to_s)
      rescue Color::FormatError => e
        raise ValidationError, "invalid color: #{e.message}"
      end
      [ :red, :green, :blue, :alpha ].each do |part|
        if expected = send(part)
          value = color.send(part)
          unless value == expected
            raise ValidationError, "color part #{part} is #{value} but should be #{expected}"
          end
        end
      end
      self.sanitized_object = color
    end

  end # class ColorSchema

end # module Respect

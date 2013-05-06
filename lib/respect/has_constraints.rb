module Respect
  module HasConstraints

    def validate_constraints(value)
      options.each do |option, arg|
        if validator_class = Respect.validator_for(option)
          validator_class.new(arg).validate(value)
        end
      end
    end

    def validate(doc)
      sanitized_doc = validate_type(doc)
      validate_constraints(sanitized_doc)
      self.sanitized_doc = sanitized_doc
      true
    end

  end
end

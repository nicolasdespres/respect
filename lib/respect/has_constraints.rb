module Respect
  # Module supporting execution of validators referred in options.
  #
  # Classes including this module must fulfill the following requirements:
  # * Respond to +options+ and returned a hash of options where keys
  #   refers to validator name (i.e. +greater_than+ for {GreaterThanValidator}).
  # * Respond to +validate_type(object)+ which must returns the sanitized object.
  module HasConstraints

    # Validate all the constraints listed in +options+ to the
    # given +value+.
    def validate_constraints(value)
      options.each do |option, arg|
        if validator_class = Respect.validator_for(option)
          validator_class.new(arg).validate(value)
        end
      end
    end

    # Call +validate_type+ with the given +object+, apply the constraints
    # and assign the sanitized object.
    def validate(object)
      sanitized_object = validate_type(object)
      validate_constraints(sanitized_object)
      self.sanitized_object = sanitized_object
      true
    rescue ValidationError => e
      # Reset sanitized object.
      self.sanitized_object = nil
      raise e
    end

  end
end

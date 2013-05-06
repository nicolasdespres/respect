module Respect
  # Module supporting execution of validators referred in options.
  #
  # Classes including this module must fulfill the following requirements:
  # * Respond to +options+ and returned a hash of options where keys
  #   refers to validator name (i.e. +greater_than+ for {GreaterThanValidator}).
  # * Respond to +validate_type(doc)+ which must returns the sanitized doc.
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

    # Call +validate_type+ with the given +doc+, apply the constraints
    # and assign the sanitized document.
    def validate(doc)
      sanitized_doc = validate_type(doc)
      validate_constraints(sanitized_doc)
      self.sanitized_doc = sanitized_doc
      true
    end

  end
end

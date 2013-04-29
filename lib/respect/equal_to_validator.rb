module Respect
  class EqualToValidator < Validator
    def initialize(expected)
      @expected = expected
    end

    def validate(value)
      unless value == @expected
        raise ValidationError,
              "wrong value: `#{value}':#{value.class} instead of `#@expected':#{@expected.class}"
      end
    end

    private

    def to_h_org3
      { 'enum' => [ @expected ] }
    end
  end
end

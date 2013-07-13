module Respect
  class InValidator < Validator
    def initialize(set)
      @set = set
    end

    def validate(value)
      unless @set.include?(value)
        raise ValidationError, "#{value.inspect} is not included in #@set"
      end
    end

    # Overwritten method. See {Validator#explain}.
    def explain
      case @set
      when Range
        "Must be between #{@set.min} and #{@set.max}."
      when Enumerable
        "Must be equal to #{@set.to_sentence(last_word_conntect: " or ")}."
      else
        "Must be in #{@set.inspect}."
      end
    end

    private

    def to_h_org3
      { 'enum' => @set.dup }
    end
  end
end

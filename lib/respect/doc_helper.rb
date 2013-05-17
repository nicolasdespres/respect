module Respect
  # Convenient module to ease usage of {DocParser}.
  #
  # Include it in classes returning their documentation via a +doc+ method.
  # This module provides a {#title} and {#description} methods for extracting
  # them from the documentation.
  module DocHelper
    # Returns the title part of the documentation returned by +doc+ method
    # (+nil+ if it does not have any).
    def title
      if doc.is_a?(String)
        DocParser.new.parse(doc).title
      end
    end

    # Returns the description part of the documentation returned by +doc+ method
    # (+nil+ if it does not have any).
    def description
      if doc.is_a?(String)
        DocParser.new.parse(doc).description
      end
    end
  end
end # module Respect

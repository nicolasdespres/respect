require 'test/unit'
require 'debugger'

require 'respect'

# Test that "hash" methods has been removed from GlabelDef as soon as we load "respect".
# We cannot do it in HashSchema since the "hash" method maybe call before hand.
if Respect::GlobalDef.new.respond_to? :hash
  raise "'hash' method should have been removed before Respect::HashSchema class is loaded."
end

require 'respect/unit_test_helper'

class Test::Unit::TestCase
  # Similar to assert_raises but return the exception object caught.
  def assert_exception(exception_class, message = nil, &block)
    begin
      block.call
      assert false, message
    rescue exception_class => e
      e
    end
  end
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# It *MUST* be defined before EndUserDSLStatement.
module Respect
  # A class to test DSL extension.
  class CoreDef < GlobalDef
    include_core_statements
    include DefWithoutName
  end
end

# A module to test statement extension helper.
module EndUserDSLStatement

  def id(name = "id")
    integer name, greater_than: 0
  end

  def call_to_kernel
    # The point is to call an instance method of the Kernel module.
    integer "kernel", equal_to: Integer(0)
  end

  def call_to_object
    # The point is to call an instance method of the Object class.
    string "object", equal_to: self.class.to_s
  end

end

Respect.extend_dsl_with(EndUserDSLStatement)

FORMAT_HELPER_STATEMENTS_LIST = [
  :phone_number,
  :hostname,
  :email,
]

PRIMITIVE_STATEMENTS_LIST = [
  :integer,
  :string,
  :any,
  :boolean,
  :null,
  :float,
  :numeric,
  :uri,
  :regexp,
  :datetime,
  :ipv4_addr,
  :ipv6_addr,
  :ip_addr,
]

TERMINAL_STATEMENTS_LIST = FORMAT_HELPER_STATEMENTS_LIST + PRIMITIVE_STATEMENTS_LIST

COMPOSITE_STATEMENTS_LIST = [
  :hash,
  :array,
]

BASIC_STATEMENTS_LIST = TERMINAL_STATEMENTS_LIST + COMPOSITE_STATEMENTS_LIST

require "mocha/setup"

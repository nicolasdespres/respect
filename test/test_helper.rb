require 'test/unit'

require 'respect'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Add custom assertions.
module Test::Unit::Assertions
  def assert_validate!(schema, doc)
    result = schema.validate!(doc)
    if result.nil?
      message = "schema '#{schema}' does not validate doc '#{doc}' because:#{schema.last_error.context.join("\n")}"
    end
    assert_not_nil result, message
  end
end

# A module to test command extension helper.
module EndUserDSLCommand

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

Respect.extend_dsl_with(EndUserDSLCommand)

FORMAT_HELPER_COMMANDS_LIST = [
  :phone_number,
  :hostname,
  :email,
]

PRIMITIVE_COMMANDS_LIST = [
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

TERMINAL_COMMANDS_LIST = FORMAT_HELPER_COMMANDS_LIST + PRIMITIVE_COMMANDS_LIST

COMPOSITE_COMMANDS_LIST = [
  :object,
  :array,
]

BASIC_COMMANDS_LIST = TERMINAL_COMMANDS_LIST + COMPOSITE_COMMANDS_LIST

require "mocha/setup"

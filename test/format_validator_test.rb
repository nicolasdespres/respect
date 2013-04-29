require "test_helper"

class FormatValidatorTest < Test::Unit::TestCase

  def setup
    @valid_ipv4_addr = [
      "0.0.0.0",
      "255.255.255.255",
      "1.1.1.1",
      "11.1.1.1",
      "11.1.1.1",
      "1.1.1.1",
      "1.11.1.1",
      "1.111.1.1",
      "1.1.1.1",
      "1.1.11.1",
      "1.1.111.1",
      "1.1.1.1",
      "1.1.1.11",
      "1.1.1.111",
    ]
    @invalid_ipv4_addr = [
      "a1.1.1.1",
      "1.1.1.1b",
      "260.0.0.0",
      "0.260.0.0",
      "0.0.260.0",
      "0.0.0.260",
      "0.0.0.0.0",
    ]
    @valid_ipv6_addr = [
      "1080:0:0:0:8:800:200C:417A",
      "FF01:0:0:0:0:0:0:101",
      "0:0:0:0:0:0:0:1",
      "0:0:0:0:0:0:0:0",
    ]
    @invalid_ipv6_addr = [
      "z1080:0:0:0:8:800:200C:417A",
      "FF01:0:0:0:0:0:0:101z",
      "0:0:0:0",
      "0:0:0:0:0:0:11111:0",
    ]
  end

  def test_ipv4_addr_validator
    # Valid IPv4 sample data.
    @valid_ipv4_addr.each_with_index do |test_data, i|
      assert_nothing_raised("validate #{i}") do
        Respect::FormatValidator.new(:ipv4_addr).validate(test_data)
      end
    end
    # Invalid IPv4 sample data.
    @invalid_ipv4_addr.each_with_index do |test_data, i|
      assert_raises(Respect::ValidationError, "validate #{i}") do
        Respect::FormatValidator.new(:ipv4_addr).validate(test_data)
      end
    end
  end

  def test_ipv4_addr_say_is_not_ipv4
    begin
      Respect::FormatValidator.new(:ipv4_addr).validate("0.333.0.0")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\bIPv4\b/, e.message)
      assert_match(/\b0.333.0.0\b/, e.message)
    end
  end

  def test_ipv4_addr_mention_wrong_value_in_error
    begin
      Respect::FormatValidator.new(:ipv4_addr).validate("invalid")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\binvalid\b/, e.message)
    end
  end

  def test_phone_number_validator
    # Valid phone number sample data.
    [
      "+112",
      "00112",
      "+1212",
      "001212",
      "1",
      "123456789",
    ].each_with_index do |test_data, i|
      assert_nothing_raised("validate #{i}") do
        Respect::FormatValidator.new(:phone_number).validate(test_data)
      end
    end
    # Invalid phone number sample data.
    [
      "-112",
      "00112a",
      "a+1212",
      "00d1212",
      "1-",
      "12 34 56 78 9",
    ].each_with_index do |test_data, i|
      assert_raises(Respect::ValidationError, "validate #{i}") do
        Respect::FormatValidator.new(:phone_number).validate(test_data)
      end
    end
  end

  def test_phone_number_mention_wrong_value_in_error
    begin
      Respect::FormatValidator.new(:phone_number).validate("invalid00phone00number")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\binvalid00phone00number\b/, e.message)
    end
  end

  def test_ipv6_addr_validator
    # Valid IPv6 sample data.
    @valid_ipv6_addr.each_with_index do |test_data, i|
      assert_nothing_raised("validate #{i}") do
        Respect::FormatValidator.new(:ipv6_addr).validate(test_data)
      end
    end
    # Invalid IPV6 sample data.
    @invalid_ipv6_addr.each_with_index do |test_data, i|
      assert_raises(Respect::ValidationError, "validate #{i}") do
        Respect::FormatValidator.new(:ipv6_addr).validate(test_data)
      end
    end
  end

  def test_ipv6_addr_say_it_is_not_ipv6
    begin
      Respect::FormatValidator.new(:ipv6_addr).validate("0.333.0.0")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\bIPv6\b/, e.message)
      assert_match(/\b0.333.0.0\b/, e.message)
    end
  end

  def test_ipv6_addr_mention_wrong_value_in_error
    begin
      Respect::FormatValidator.new(:ipv6_addr).validate("invalid_ipaddr")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\binvalid_ipaddr\b/, e.message)
    end
  end

  def test_ip_addr_validator
    # Valid IP sample data.
    (@valid_ipv4_addr + @valid_ipv6_addr).each_with_index do |test_data, i|
      assert_nothing_raised("validate #{i}") do
        Respect::FormatValidator.new(:ip_addr).validate(test_data)
      end
    end
    # Invalid IP sample data.
    (@invalid_ipv4_addr + @invalid_ipv6_addr).each_with_index do |test_data, i|
      assert_raises(Respect::ValidationError, "validate #{i}") do
        Respect::FormatValidator.new(:ip_addr).validate(test_data)
      end
    end
  end

  def test_ip_mention_wrong_value_in_error
    begin
      Respect::FormatValidator.new(:ip_addr).validate("invalid_ipaddr")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\binvalid_ipaddr\b/, e.message)
    end
  end

  def test_hostname_addr_validator
    # Valid hostname sample data.
    [
      "a.b.c.d",
      "aa.bb.cc.dd",
      "aaa.bbb.ccc.ddd",
      "a",
      "abcdefghijklmnopqrstuvwxyz-0123456789",
      "abcdefghijklmnopqrstuvwxyz-0123456789.abcdefghijklmnopqrstuvwxyz-0123456789",
      "A.B.C.D",
    ].each_with_index do |test_data, i|
      assert_nothing_raised("validate #{i}") do
        Respect::FormatValidator.new(:hostname).validate(test_data)
      end
    end
    # Invalid hostname sample data.
    [
      "-a.b.c.d",
      "1a.b.c.d",
      "a_b",
    ].each_with_index do |test_data, i|
      assert_raises(Respect::ValidationError, "validate #{i}") do
        Respect::FormatValidator.new(:hostname).validate(test_data)
      end
    end
  end

  def test_hostname_say_which_part_is_wrong
    begin
      invalid_part = "b" * 100
      invalid_hostname = "a.#{invalid_part}.c.d"
      Respect::FormatValidator.new(:hostname).validate(invalid_hostname)
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\b#{invalid_part}\b/, e.message)
      assert_match(/\b1st\b/, e.message)
      assert_match(/\b#{invalid_hostname}\b/, e.message)
    end
  end

  def test_ipv4_addr_mention_wrong_value_in_error
    begin
      Respect::FormatValidator.new(:ipv4_addr).validate("invalid_hostname")
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_match(/\binvalid_hostname\b/, e.message)
    end
  end

end

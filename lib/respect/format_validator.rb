require "ipaddr"
require 'uri'

module Respect
  class FormatValidator < Validator

    PHONE_NUMBER_REGEXP = /^((\+|00)\d{1,2})?\d+$/

    # FIXME(Nicolas Despres): RFC 1034 mentions that a valid domain can be " "
    # in section 3.5. (see http://www.rfc-editor.org/rfc/rfc1034.txt) but we don't
    # since I don't understand when it is useful.
    HOSTNAME_REGEXP = /^[a-z][a-z0-9-]*(\.[a-z][a-z0-9-]*)*$/i

    def initialize(format)
      @format = format
    end

    def validate(value)
      send("validate_#@format", value)
    end

    # Validate the given string _value_ describes a well-formed email
    # address following this specification
    # http://www.w3.org/TR/2012/CR-html5-20121217/forms.html#valid-e-mail-address
    def validate_email(value)
      unless value =~ /^[a-zA-Z0-9.!#$\%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
        raise ValidationError, "invalid email address format '#{value}'"
      end
    end

    # Validate URI string format following RFC 2396
    # (see http://tools.ietf.org/html/rfc2396)
    def validate_uri(value)
      URI.parse(value)
    rescue URI::InvalidURIError => e
      raise ValidationError, "invalid URI: #{e.message}"
    end

    # Validate the given string _value_ describes a regular expression
    # following the Ruby regular expression syntax.
    def validate_regexp(value)
      Regexp.new(value)
    rescue RegexpError => e
      raise ValidationError, "invalid regexp: #{e.message}"
    end

    # Validate date and time string format following RFC 3399
    # (see https://tools.ietf.org/html/rfc3339)
    def validate_datetime(value)
      DateTime.rfc3339(value)
    rescue ArgumentError => e
      raise ValidationError, e.message
    end

    # Validate IPV4 using the standard "ipaddr" ruby module.
    def validate_ipv4_addr(value)
      ipaddr = IPAddr.new(value)
      unless ipaddr.ipv4?
        raise ValidationError, "IP address '#{value}' is not IPv4"
      end
      ipaddr
    rescue ArgumentError => e
      raise ValidationError, "invalid IPv4 address '#{value}' - #{e.message}"
    end

    # Validate phone number following E.123
    # (see http://en.wikipedia.org/wiki/E.123)
    def validate_phone_number(value)
      unless value =~ PHONE_NUMBER_REGEXP
        raise ValidationError, "invalid phone number '#{value}'"
      end
    end

    # Validate that the given string _value_ describes a well-formed
    # IPV6 network address using the standard "ipaddr" ruby module.
    def validate_ipv6_addr(value)
      ipaddr = IPAddr.new(value)
      unless ipaddr.ipv6?
        raise ValidationError, "IP address '#{value}' is not IPv6"
      end
      ipaddr
    rescue ArgumentError => e
      raise ValidationError, "invalid IPv6 address '#{value}' - #{e.message}"
    end

    # Validate that the given string _value_ describes a well-formed
    # IP (IPv6 or IPv4) network address using the standard "ipaddr" ruby module.
    def validate_ip_addr(value)
      IPAddr.new(value)
    rescue ArgumentError => e
      raise ValidationError, "invalid IP address '#{value}' - #{e.message}"
    end

    # Validate that the given string _value_ describes a well-formed
    # host name as specified by RFC 1034.
    # (see http://www.rfc-editor.org/rfc/rfc1034.txt)
    def validate_hostname(value)
      match_data = HOSTNAME_REGEXP.match(value)
      if match_data
        value.split('.').each_with_index do |label, i|
          unless label.length <= 63
            raise ValidationError,
                  "hostname's #{i.ordinalize} label '#{label}' is not less than 63 characters in '#{value}'"
          end
        end
      else
        raise ValidationError, "invalid hostname '#{value}'"
      end
    end

    private

    def to_h_org3
      { 'format' => convert_to_org3_format(@format) }
    end

    def convert_to_org3_format(format)
      format_type_map = {
        regexp: 'regex',
        datetime: 'date-time',
        ipv4_addr: 'ip-address',
        phone_number: 'phone',
        ipv6_addr: 'ipv6',
        ip_addr: nil,
        hostname: 'host-name',
      }.freeze
      if format_type_map.has_key?(format)
        translation_value = format_type_map[format]
        translation_value unless translation_value.nil?
      else
        format.to_s
      end
    end

  end # class FormatValidator
end # module Respect

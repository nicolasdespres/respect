require "test_helper"

class URISchemaTest < Test::Unit::TestCase

  def test_uri_schema_creates_uri_object
    s = Respect::URISchema.new
    assert_nil s.sanitized_doc
    assert s.validate?("http://foo.com")
    assert s.sanitized_doc.is_a?(URI::Generic)
    assert_equal "http://foo.com", s.sanitized_doc.to_s
  end

  def test_uri_schema_relies_on_format_validator
    doc = "http://foo.com"
    Respect::FormatValidator.any_instance.stubs(:validate_uri).with(doc).at_least_once
    Respect::URISchema.new.validate(doc)
  end

end

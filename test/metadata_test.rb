require "test_helper"

class MetadataTest < Test::Unit::TestCase

  def setup
    @title = "This is a title."
    @description = <<-EOS.strip_heredoc
      This a long description...

      ...with blank line.
      EOS
  end

  def test_can_be_defined
    m = Respect::Metadata.define do |m|
      m.title @title
      m.description { @description }
    end
    assert_equal Respect::Metadata, m.class
    assert_equal @title, m.title
    assert_equal @description, m.description
  end

end # class MetadataTest

require "test_helper"

class DocParserTest < Test::Unit::TestCase
  def setup
    @parser = Respect::DocParser.new
  end

  def test_full_doc
    doc = <<-EOS.strip_heredoc
      A title.

      A description.
      A long description.
      EOS
    @parser.parse(doc)
    assert_equal "A title.", @parser.title
    assert_equal "A description.\nA long description.\n", @parser.description
  end

  def test_no_title
    doc = <<-EOS.strip_heredoc
      A description.
      A long description.
      EOS
    @parser.parse(doc)
    assert_equal nil, @parser.title
    assert_equal "A description.\nA long description.\n", @parser.description
  end

  def test_no_desc
    doc = <<-EOS.strip_heredoc
      A title.
      EOS
    @parser.parse(doc)
    assert_equal "A title.", @parser.title
    assert_equal nil, @parser.description
  end

  def test_no_desc_and_no_newline
    doc = <<-EOS.strip_heredoc
      A title.

      A sparse...

      ... description.
      EOS
    @parser.parse(doc)
    assert_equal "A title.", @parser.title
    desc = <<-EOS.strip_heredoc
      A sparse...

      ... description.
      EOS
    assert_equal desc, @parser.description
  end

  def test_no_title_but_long_desc
    doc = <<-EOS.strip_heredoc
      A first paragraph...
      ...on several lines.

      A second one...
      ... on several lines.


      And a far away third one...
      ... on several lines.
      EOS
    @parser.parse(doc)
    assert_equal nil, @parser.title
    assert_equal doc, @parser.description
  end

  def test_title_and_empty_desc
    doc = <<-EOS.strip_heredoc
      A title with many empty line for desc




      EOS
    @parser.parse(doc)
    assert_equal "A title with many empty line for desc", @parser.title
    assert_equal nil, @parser.description
  end

  def test_title_separated_by_desc_with_many_lines
    doc = <<-EOS.strip_heredoc
      A title with many empty line for desc




      The description finally...
      come.
      EOS
    @parser.parse(doc)
    assert_equal "A title with many empty line for desc", @parser.title
    assert_equal "The description finally...\ncome.\n", @parser.description
  end

  def test_title_with_no_newline
    doc = "a title"
    @parser.parse(doc)
    assert_equal "a title", @parser.title
    assert_equal nil, @parser.description
  end

end

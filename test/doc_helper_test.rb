require "test_helper"

class DocHelperTest < Test::Unit::TestCase
  def test_schema_title_use_doc_parser
    object = mock()
    object.extend(Respect::DocHelper)
    doc = "Hey!"
    object.stubs(:documentation).returns(doc)
    Respect::DocParser.any_instance.stubs(:parse).with(doc).returns(Respect::DocParser.new).at_least_once
    Respect::DocParser.any_instance.stubs(:title).returns("title").at_least_once
    assert_equal "title", object.title
  end

  def test_schema_description_use_doc_parser
    object = mock()
    object.extend(Respect::DocHelper)
    doc = "Hey!"
    object.stubs(:documentation).returns(doc)
    Respect::DocParser.any_instance.stubs(:parse).with(doc).returns(Respect::DocParser.new).at_least_once
    Respect::DocParser.any_instance.stubs(:description).returns("desc").at_least_once
    assert_equal "desc", object.description
  end

  def test_nil_title_and_description_if_nil_doc
    object = mock()
    object.extend(Respect::DocHelper)
    object.stubs(:documentation).returns(nil)
    assert_nil object.documentation
    assert_nil object.title
    assert_nil object.description
  end
end

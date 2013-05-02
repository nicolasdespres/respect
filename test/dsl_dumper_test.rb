require "test_helper"

class DslDumperTest < Test::Unit::TestCase
  def test_dump_nested_objects
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.object "o" do |s|
            s.integer "i"
          end
        end
      end
      EOF
    end
  end

  def test_dump_object_with_multiple_integer
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.integer "i1"
          s.integer "i2"
          s.integer "i3"
        end
      end
      EOF
    end
  end

  def test_dump_nested_object_with_multiple_integer
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.object "o1" do |s|
            s.integer "i1"
            s.integer "i2"
            s.integer "i3"
          end
          s.object "o2" do |s|
            s.integer "i1"
            s.integer "i2"
            s.integer "i3"
          end
          s.object "o3" do |s|
            s.integer "i1"
            s.integer "i2"
            s.integer "i3"
          end
        end
      end
      EOF
    end
  end

  def test_property_name_are_escaped
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.string "s\\""
        end
      end
      EOF
    end
  end

  def test_dump_terminal_statement
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.object do |s|
            s.#{statement} "property_name"
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_item
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.#{statement}
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_items
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.items do |s|
              s.#{statement}
              s.#{statement}
            end
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_extra_items
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.extra_items do |s|
              s.#{statement}
              s.#{statement}
            end
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_items_and_extra_items
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.items do |s|
              s.#{statement}
              s.#{statement}
              s.#{statement}
            end
            s.extra_items do |s|
              s.#{statement}
              s.#{statement}
              s.#{statement}
            end
          end
        end
        EOF
      end
    end
  end

  def test_dump_nested_array_with_item
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.array do |s|
          s.array do |s|
            s.array do |s|
              s.array do |s|
                s.array do |s|
                  s.integer
                end
              end
            end
          end
        end
      end
      EOF
    end
  end

  def test_dump_nested_array_with_items
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.array do |s|
          s.items do |s|
            s.integer
            s.array do |s|
              s.items do |s|
                s.integer
                s.array do |s|
                  s.integer
                end
              end
            end
          end
        end
      end
      EOF
    end
  end

  def test_dump_nested_array_with_extra_items
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.array do |s|
          s.extra_items do |s|
            s.integer
            s.array do |s|
              s.extra_items do |s|
                s.integer
                s.array do |s|
                  s.integer
                end
              end
            end
          end
        end
      end
      EOF
    end
  end

  def test_dump_nested_array_and_object
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.array do |s|
          s.object do |s|
            s.integer "i"
            s.array "a" do |s|
              s.object do |s|
                s.integer "i"
                s.array "a" do |s|
                  s.integer
                end
                s.string "s"
              end
            end
            s.string "s"
          end
        end
      end
      EOF
    end
  end

  def test_dump_terminal_schema
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.#{statement}
        end
        EOF
      end
    end
  end

  def test_dump_format_helper_statement
    FORMAT_HELPER_STATEMENTS_LIST.each do |statement|
      schema = Respect::Schema.define do |s|
        s.__send__(statement)
      end
      expected_result = <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.string :format => #{statement.inspect}
        end
      EOF
      assert_equal(expected_result,
        Respect::DslDumper.new(schema).dump,
        "dump for statement #{statement}")
    end
  end

  def test_dump_statement_with_no_names_and_several_options
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.integer :greater_than => 42, :equal_to => 51
      end
      EOF
    end
  end

  def test_dump_statement_with_name_and_several_options
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.integer "an_int", :greater_than => 42, :equal_to => 51
        end
      end
      EOF
    end
  end

  def test_dump_statement_with_name_and_no_options
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.integer "an_int"
        end
      end
      EOF
    end
  end

  def test_dump_primitive_statement_documentation
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.doc <<-EOS.strip_heredoc
            a title

            a description
            EOS
          s.#{statement}
        end
        EOF
      end
    end
  end

  def test_dump_primitive_statement_with_no_description
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.doc "a title"
          s.#{statement}
        end
        EOF
      end
    end
  end

  def test_dump_primitive_statement_with_no_title
    PRIMITIVE_STATEMENTS_LIST.each do |statement|
      assert_bijective_dump("dump statement #{statement}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.doc <<-EOS.strip_heredoc
            a long...
            ... description
            EOS
          s.#{statement}
        end
        EOF
      end
    end
  end

  def test_dump_object_documentation
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.doc <<-EOS.strip_heredoc
          a title

          a description
          EOS
        s.object do |s|
          s.integer "i"
          s.string "s"
        end
      end
      EOF
    end
  end

  def test_dump_array_documentation
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.doc <<-EOS.strip_heredoc
          a title

          a description
          EOS
        s.array do |s|
          s.integer
        end
      end
      EOF
    end
  end

  private

  def assert_bijective_dump(message = nil, &block)
    source = block.call
    schema = eval(source, block.binding,
      block.source_location.first, block.source_location[1] + 2)
    assert schema.is_a?(Respect::Schema), "is a schema"
    assert_equal(source, Respect::DslDumper.new(schema).dump, message)
  end
end

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

  def test_dump_terminal_command
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.object do |s|
            s.#{command} "property_name"
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_item
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.#{command}
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_items
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.items do |s|
              s.#{command}
              s.#{command}
            end
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_extra_items
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.extra_items do |s|
              s.#{command}
              s.#{command}
            end
          end
        end
        EOF
      end
    end
  end

  def test_dump_array_items_and_extra_items
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.array do |s|
            s.items do |s|
              s.#{command}
              s.#{command}
              s.#{command}
            end
            s.extra_items do |s|
              s.#{command}
              s.#{command}
              s.#{command}
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
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.#{command}
        end
        EOF
      end
    end
  end

  def test_dump_format_helper_command
    FORMAT_HELPER_COMMANDS_LIST.each do |command|
      schema = Respect::Schema.define do |s|
        s.__send__(command)
      end
      expected_result = <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.string :format => #{command.inspect}
        end
      EOF
      assert_equal(expected_result,
        Respect::DslDumper.new(schema).dump,
        "dump for command #{command}")
    end
  end

  def test_dump_command_with_no_names_and_several_options
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.integer :greater_than => 42, :equal_to => 51
      end
      EOF
    end
  end

  def test_dump_command_with_name_and_several_options
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

  def test_dump_command_with_name_and_no_options
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

  def test_dump_terminal_command_metadata
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.#{command} do |m|
            m.title "a title"
            m.description { "a description" }
          end
        end
        EOF
      end
    end
  end

  def test_dump_teminal_command_with_no_description
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.#{command} do |m|
            m.title "a title"
          end
        end
        EOF
      end
    end
  end

  def test_dump_teminal_command_with_no_title
    PRIMITIVE_COMMANDS_LIST.each do |command|
      assert_bijective_dump("dump command #{command}") do
        <<-EOF.strip_heredoc
        Respect::Schema.define do |s|
          s.#{command} do |m|
            m.description { "a description" }
          end
        end
        EOF
      end
    end
  end

  def test_dump_object_metadata
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.object do |s|
          s.metadata do |m|
            m.title "a title"
            m.description { "a description" }
          end
          s.integer "i"
          s.string "s"
        end
      end
      EOF
    end
  end

  def test_dump_array_metadata
    assert_bijective_dump do
      <<-EOF.strip_heredoc
      Respect::Schema.define do |s|
        s.array do |s|
          s.metadata do |m|
            m.title "a title"
            m.description { "a description" }
          end
          s.integer
        end
      end
      EOF
    end
  end

  # FIXME(Nicolas Despres): Make it works
  # def test_dump_description_as_heredoc
  #   assert_bijective_dump do
  #     <<-EOF.strip_heredoc
  #     Respect::Schema.define do |s|
  #       s.integer do |m|
  #         m.title "a title"
  #         m.description do
  #           <<-EOS.strip_heredoc
  #           This a long description...

  #           ...with blank line.
  #           EOS
  #         end
  #       end
  #     end
  #     EOF
  #   end
  # end

  private

  def assert_bijective_dump(message = nil, &block)
    source = block.call
    schema = eval(source, block.binding,
      block.source_location.first, block.source_location[1] + 2)
    assert schema.is_a?(Respect::Schema), "is a schema"
    assert_equal(source, Respect::DslDumper.new(schema).dump, message)
  end
end

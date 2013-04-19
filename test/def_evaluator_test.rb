require "test_helper"

class DefEvaluatorTest < Test::Unit::TestCase

  def setup
    @def_class = Class.new(Respect::BaseDef) do
      include Respect::BasicCommands
      def accept_name(name)
        name
      end
      def do_not_accept_name(arg1)
        arg1
      end
      def method_missing(symbol, *args, &block)
        [symbol, args, block]
      end
      def respond_to_missing?(symbol, include_all)
        symbol == :dynamic_method
      end
    end
    @def_target = @def_class.new
    @evaluator = Respect::DefEvaluator.new(@def_target)

    @def_class_no_name = @def_class.clone
    @def_class_no_name.send(:include, Respect::DefWithoutName)
    @def_target_no_name = @def_class_no_name.new
    @evaluator_no_name = Respect::DefEvaluator.new(@def_target_no_name)
  end

  def test_evaluator_target_must_be_dsl_object
    assert_raise(ArgumentError) do
      Respect::DefEvaluator.new(Class.new)
    end
  end

  def test_access_to_target
    assert(@def_target == @evaluator.target)
    assert(@def_class == @evaluator.target.class)
    @evaluator.eval do |e|
      assert(e == @evaluator)
      assert(e.target == @def_target)
      assert(e.target.class == @def_class)
    end
  end

  def test_nil_inserted_as_fake_name
    @evaluator_no_name.eval do |e|
      assert_nil e.accept_name
      assert_raise(ArgumentError) do
        e.accept_name "extra arg"
      end
      assert_raise(ArgumentError) do
        e.do_not_accept_name
      end
      assert_equal("arg1", e.do_not_accept_name("arg1"))
    end
  end

  def test_nothing_inserted_as_fake_name
    @evaluator.eval do |e|
      assert_equal("name", e.accept_name("name"))
      assert_raise(ArgumentError) do
        e.accept_name
      end
      assert_raise(ArgumentError) do
        e.accept_name "name", "extra arg"
      end
      assert_raise(ArgumentError) do
        e.do_not_accept_name
      end
      assert_equal("arg1", e.do_not_accept_name("arg1"))
      assert_raise(ArgumentError) do
        e.do_not_accept_name "arg1", "extra arg"
      end
    end
  end

  def test_rewrite_argument_error_message_values
    @evaluator_no_name.eval do |e|
      assert_argument_error_number(1, 0) do
        e.accept_name "extra arg"
      end
      assert_argument_error_number(0, 1) do
        e.do_not_accept_name
      end
    end
  end

  def test_block_must_take_one_arg
    assert_raise(ArgumentError) do
      s = Respect::DefEvaluator.new(@def_target).eval do |s, a|
      end
    end
    assert_raise(ArgumentError) do
      s = Respect::DefEvaluator.new(@def_target).eval do
      end
    end
  end

  def test_handle_target_dynamic_method
    # If the target accepts name, all arguments are always passed unchanged.
    @evaluator.eval do |e|
      assert_equal [:dynamic_method, [], nil], e.dynamic_method
      assert_equal [:dynamic_method, [1, 2], nil], e.dynamic_method(1, 2)
      assert_equal [:dynamic_method, [1, 2, 3], nil], e.dynamic_method(1, 2, 3)
    end
    # If the target does not accepts name, a fake name is always passed (we do not test whether the first
    # parameters is a name since we do not have access to the parameters list).
    @evaluator_no_name.eval do |e|
      assert_equal [:dynamic_method, [nil], nil], e.dynamic_method
      assert_equal [:dynamic_method, [nil, 1, 2], nil], e.dynamic_method(1, 2)
      assert_equal [:dynamic_method, [nil, 1, 2, 3], nil], e.dynamic_method(1, 2, 3)
    end
  end

  private

  def assert_argument_error_number(actual, expected, &block)
    begin
      block.call
      assert false
    rescue ArgumentError => err
      assert_match(/\(#{actual} for #{expected}\)/, err.message)
    end
  end
end

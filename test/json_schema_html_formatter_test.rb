require "test_helper"

class JSONSchemaHTMLFormatterTest < Test::Unit::TestCase
  def test_dump_simple_hash
    json_schema = {
      "type" => "integer",
      "required" => false,
    }
    output = ""
    Respect::JSONSchemaHTMLFormatter.new(json_schema).dump(output)
    expected = <<-EOS.strip_heredoc
      <div class=\"highlight\"><pre><span class=\"plain\">{</span>
        <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"integer\"</span><span class=\"plain\">,</span>
        <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">false</span>
      <span class=\"plain\">}</span></pre></div>
    EOS
    assert_equal expected, output
  end

  def test_dump_nested_hash
    json_schema = {
      "type" => "object",
      "properties" => {
        "circle" => {
          "type" => "object",
          "required" => true,
          "properties" => {
            "center" => {
              "type" => "object",
              "required" => true,
              "properties" => {
                "x" => {
                  "type" => "number",
                  "required" => true
                },
                "y" => {
                  "type" => "number",
                  "required" => true
                }
              }
            },
            "radius" => {
              "type" => "number",
              "required" => true,
              "minimum" => 0.0,
              "exclusiveMinimum" => true
            }
          }
        },
      },
    }
    output = ""
    Respect::JSONSchemaHTMLFormatter.new(json_schema).dump(output)
    expected = <<-EOS.strip_heredoc
      <div class=\"highlight\"><pre><span class=\"plain\">{</span>
        <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"object\"</span><span class=\"plain\">,</span>
        <span class=\"key\">\"properties\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
          <span class=\"key\">\"circle\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
            <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"object\"</span><span class=\"plain\">,</span>
            <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span><span class=\"plain\">,</span>
            <span class=\"key\">\"properties\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
              <span class=\"key\">\"center\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
                <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"object\"</span><span class=\"plain\">,</span>
                <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span><span class=\"plain\">,</span>
                <span class=\"key\">\"properties\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
                  <span class=\"key\">\"x\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
                    <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"number\"</span><span class=\"plain\">,</span>
                    <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span>
                  <span class=\"plain\">}</span><span class=\"plain\">,</span>
                  <span class=\"key\">\"y\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
                    <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"number\"</span><span class=\"plain\">,</span>
                    <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span>
                  <span class=\"plain\">}</span>
                <span class=\"plain\">}</span>
              <span class=\"plain\">}</span><span class=\"plain\">,</span>
              <span class=\"key\">\"radius\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
                <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"number\"</span><span class=\"plain\">,</span>
                <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span><span class=\"plain\">,</span>
                <span class=\"key\">\"minimum\"</span><span class=\"plain\">:</span> <span class=\"numeric\">0.0</span><span class=\"plain\">,</span>
                <span class=\"key\">\"exclusiveMinimum\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span>
              <span class=\"plain\">}</span>
            <span class=\"plain\">}</span>
          <span class=\"plain\">}</span>
        <span class=\"plain\">}</span>
      <span class=\"plain\">}</span></pre></div>
    EOS
    assert_equal expected, output
  end

  def test_dump_nested_array
    json_schema = {
      "type" => "array",
      "required" => true,
      "items" => [
        {
          "type" => "array",
          "items" => [
            { "type" => "number", },
            { "type" => "number", },
          ],
        },
      ]
    }
    output = ""
    Respect::JSONSchemaHTMLFormatter.new(json_schema).dump(output)
    expected = <<-EOS.strip_heredoc
      <div class=\"highlight\"><pre><span class=\"plain\">{</span>
        <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"array\"</span><span class=\"plain\">,</span>
        <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span><span class=\"plain\">,</span>
        <span class=\"key\">\"items\"</span><span class=\"plain\">:</span> <span class=\"plain\">[</span>
          <span class=\"plain\">{</span>
            <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"array\"</span><span class=\"plain\">,</span>
            <span class=\"key\">\"items\"</span><span class=\"plain\">:</span> <span class=\"plain\">[</span>
              <span class=\"plain\">{</span>
                <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"number\"</span>
              <span class=\"plain\">}</span><span class=\"plain\">,</span>
              <span class=\"plain\">{</span>
                <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"number\"</span>
              <span class=\"plain\">}</span>
            <span class=\"plain\">]</span>
          <span class=\"plain\">}</span>
        <span class=\"plain\">]</span>
      <span class=\"plain\">}</span></pre></div>
    EOS
    assert_equal expected, output
  end

  def test_doc_extraction
    json_schema = {
      "type" => "object",
      "properties" => {
        "param1" => {
          "type" => "integer",
          "title" => "A parameter",
          "description" => "An important parameter that should be equal to 42.\nYes really!.",
          "required" => true,
          "enum" => [
            42
          ]
        }
      }
    }
    output = ""
    Respect::JSONSchemaHTMLFormatter.new(json_schema).dump(output)
    expected = <<-EOS.strip_heredoc
      <div class=\"highlight\"><pre><span class=\"plain\">{</span>
        <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"object\"</span><span class=\"plain\">,</span>
        <span class=\"key\">\"properties\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
          <span class=\"comment\">// A parameter
          //
          // An important parameter that should be equal to 42.
          // Yes really!.</span>
          <span class=\"key\">\"param1\"</span><span class=\"plain\">:</span> <span class=\"plain\">{</span>
            <span class=\"key\">\"type\"</span><span class=\"plain\">:</span> <span class=\"string\">\"integer\"</span><span class=\"plain\">,</span>
            <span class=\"key\">\"required\"</span><span class=\"plain\">:</span> <span class=\"keyword\">true</span><span class=\"plain\">,</span>
            <span class=\"key\">\"enum\"</span><span class=\"plain\">:</span> <span class=\"plain\">[</span>
              <span class=\"numeric\">42</span>
            <span class=\"plain\">]</span>
          <span class=\"plain\">}</span>
        <span class=\"plain\">}</span>
      <span class=\"plain\">}</span></pre></div>
    EOS
    assert_equal expected, output
  end

end

# Welcome to Respect

_Respect_ is a DSL to concisely describe the structure of common data such as Hash and Array using
Ruby code. It comes with a validator, a sanitizer and dumpers to generate valid
[json-schema.org](http://json-schema.org/) compliant specifications. Although it was designed to
specify JSON schema, it can be used for any data represented as Hash and Array. It does not require
any JSON parser since it works only on data.

Respect is named after the contraction of _REST_ and _SPEC_. Indeed, it is first intended to be
used to specify REST API in the context of a Web application.

There is a plugin called [Respect for Rails](https://github.com/nicolasdespres/respect-rails) which
integrate this gem in Rails.

# Features

Already available:

* Compact Ruby DSL to specify your schema.
* Standard [json-schema.org](http://json-schema.org/) specification generator.
* Validator for JSON document or the like.
* Contextual validation error.
* Object sanitizer: turn plain string and integer values into real objects.
* Extensible API to add your custom validator and sanitizer.
* Extensible macro definition system to factor you schema definition code.

See the RELEASE_NOTES file for detailed feature listing.

# Take a Tour

_Respect_ comes with a compact Ruby DSL to specify the structure of a hash and/or an array.
Thus, it is ideal to specify JSON schema. I find it a way more concise than
[json-schema.org](http://json-schema.org/). And it is plain Ruby so you can rely on all great Ruby features
to factor your specification code.

For instance, this ruby code specify how one could structure a very simple user profile:

```ruby
schema = Respect::HashSchema.define do |s|
  s.string "name"
  s.integer "age", greater_than: 18
  s.string "homepage", format: :email
end
```

But you can still convert this specification to
[JSON Schema specification draft v3](http://tools.ietf.org/id/draft-zyp-json-schema-03.html)
easily so that all your customers can read and understand it:

```ruby
require 'json'
puts JSON.pretty_generate(schema.to_h)
```

prints

```json
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "required": true
    },
    "age": {
      "type": "integer",
      "required": true,
      "minimum": 18,
      "exclusiveMinimum": true
    },
    "email": {
      "type": "string",
      "required": true,
      "format": "email"
    }
  }
}
```

As you can see the Ruby specification is 4 times shorter than the JSON Schema specification...

You can also use this specification to validate JSON documents:

```ruby
schema.validate?({ "name" => "My name", "age" => 20, "email" => "me@example.com" })          #=> true
schema.validate?({ "name" => "My name", "age" => 15, "email" => "me@example.com" })          #=> false
```

When it fails to validate a document, you get descriptive error messages with contextual information:

```ruby
schema.last_error                #=> "15 is not greater than 18"
schema.last_error.message        #=> "15 is not greater than 18"
schema.last_error.context[0]     #=> "15 is not greater than 18"
schema.last_error.context[1]     #=> "in hash property `age'"
```

_Respect_ does not parse JSON document by default but it is easy to do so using one of the JSON parser available in Ruby:

```ruby
schema.validate?(JSON.parse('{ "name": "My name", "age": 20, "email": "me@example.com" }'))   #=> true
```

Once a JSON document has been validated, we often want to turn its basic strings and integers into real object like `URI`.
_Respect_ does that automatically for you for standard objects:

```ruby
schema = Respect::HashSchema.define do |s|
  s.uri "homepage"
end
object = { "homepage" => "http://example.com" }
schema.validate!(object)                            #=> true
object["homepage"].class                            #=> URI::HTTP
```

You can easily extend the sanitizer with your own object type. Let's assume you have an object type define like this:

```ruby
class Place
  def initialize(latitude, longitude)
    @latitude, @longitude = latitude, longitude
  end

  attr_reader :latitude, :longitude

  def ==(other)
    @latitude == other.latitude && @longitude == other.longitude
  end
end
```

Then you must extend the Schema hierarchy with the new schema for your custom type.
The `CompositeSchema` class assists you in this task so you just have to overwrite
two methods.

```ruby
module Respect
  class PlaceSchema < CompositeSchema
    # This method returns the schema specification for your custom type.
    def schema_definition
      Respect::HashSchema.define do |s|
        s.float "latitude"
        s.float "longitude"
      end
    end

    # The 'sanitize' method is called with the JSON document if the validation succeed.
    # The returned value will be inserted into the JSON document.
    def sanitize(object)
      Place.new(object[:latitude], object[:longitude])
    end
  end
end
```

Finally, you define the structure of your JSON document as usual. Note that you have
access to your custom schema via the `place` method.

```ruby
schema = Respect::HashSchema.define do |s|
  s.place "home"
end

object = {
  "home" => {
    "latitude" => "48.846559",
    "longitude" => "2.344519",
  }
}

schema.validate!(object)                              #=> true
object["home"].class                                  #=> Place
```

Sometimes you just want to extend the DSL with a new statement providing higher level feature than
the primitive `integer`, `string` or `float`, etc... For instance if you specify identifier
in your schema like this:

```ruby
Respect::HashSchema.define do |s|
  s.integer "article_id", greater_than: 0
  s.string "title"
  s.hash "author" do |s|
    s.integer "author_id", greater_than: 0
    s.string "name"
  end
end
```

In such case, you don't need a custom sanitizer. You just want to factor the definition of
identifier property. You can easily to it like this:

```ruby
module MyMacros
  def id(name, options = {})
    unless name.nil? || name =~ /_id$/
      name += "_id"
    end
    integer(name, { greater_than: 0 }.merge(options))
  end
end
Respect.extend_dsl_with(MyMacros)
```

Now you can rewrite the original schema this way:

```ruby
Respect::HashSchema.define do |s|
  s.id "article"
  s.string "title"
  s.hash "author" do |s|
    s.id "author"
    s.string "name"
  end
end
```

# Getting started

The easiest way to install _Respect_ is to add it to your `Gemfile`:

```ruby
gem "respect"
```

Then, after running the `bundle install` command, you can start to validate JSON document in your program like this:

```ruby
require 'respect'

schema = Respect::HashSchema.define do |s|
  s.string "name"
  s.integer "age", greater_than: 18
end

schema.validate?({ "name" => "John", "age" => 30 })
```

# JSON Schema implementation status

_Respect_ currently implements most of the features included in the
[JSON Schema specification draft v3](http://tools.ietf.org/id/draft-zyp-json-schema-03.html).

See the `STATUS_MATRIX` file included in this package for detailed information.

Although, the semantics of the schema definition DSL available in this library may change slightly from the
_JSON schema standard_, we have tried to keep it as close as possible. For instance the `strict` option of
hash schema is not presented in the standard. However, when a schema is dumped to its _JSON Schema_ version
the syntax and semantic have been followed. You should note that there is no "loader" available yet in this
library. In other word, you cannot instantiate a Schema class from a _JSON Schema_ string representation.

# Getting help

The easiest way to get help about how to use this library is to post your question on the
[Respect discussion group](FIXME). I will be glade to answer. I may have already answered the
same question so before you post your question take a bit of time to search the group.

You can also read these documents for further documentation:

* [Repect API reference documentation](FIXME)

# Compatibility

_Respect_ has been tested with:

* Ruby 1.9.3-p392 (should be compatible with all 1.9.x family)
* ActiveSupport 3.2.13

Note that **it does not depend on any JSON parsing library**. It works only on primitive Ruby data type. So,
any JSON parser returning normal basic types like `Hash`, `Array`, `String`, `Numeric`, `TrueClass`,
`FalseClass`, `NilClass`, should work.

# Feedback

I would love to hear what you think about this library. Feel free to post any comments/remarks on the
[Respect discussion group](FIXME).

# Contributing patches

I spent quite a lot of time writing this gem but there is still a lot of work to do. Whether it
is a bug-fix, a new feature, some code re-factoring, or documentation clarification, I will be
glade to merge your pull request on GitHub. You just have to create a branch from `master` and
send me a pull request.

# License

_Respect_ is released under the term of the [MIT License](http://opensource.org/licenses/MIT).
Copyright (c) 2013 Nicolas Despres.

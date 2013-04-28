# Welcome to Respect

_Respect_ is a JSON schema validation system providing a DSL to concisely write your schema. It also comes with a
validator, a sanitizer and dumpers to generate valid [json-schema.org](http://json-schema.org/) compliant specifications.

Respect is named after the contraction of _REST_ and _SPEC_. Indeed, it is first intended to be used to specify REST API
in the context of a Web application.

# Features

* Compact Ruby DSL to specify your JSON schema.
* Standard [json-schema.org](http://json-schema.org/) specification generator.
* JSON document validator.
* Contextual validation error.
* Document sanitizer: turn plain string and integer values into real objects.
* Extensible API to add your custom validator and sanitizer.

# Take a Tour!

_Respect_ comes with a compact Ruby DSL to specify your JSON schema.  I find it a way more concise than
[json-schema.org](http://json-schema.org/).  And it is plain Ruby so you can rely on all great Ruby features
to factor your specification code.

For instance, this ruby code specify how one could structure a very simple user profile:

```ruby
schema = Respect::ObjectSchema.define do |s|
  s.string "name"
  s.integer "age", greater_than: 18
  s.string "homepage", format: :email
end
```

But you can still convert this specification to
[JSON Schema specification draft v3](http://tools.ietf.org/id/draft-zyp-json-schema-03.html)
easily so that all your customers can read and understand it:

```ruby
puts JSON.pretty_generate(schema.to_json)
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

As you can see the Ruby specification is 5 lines of code whereas the JSON Schema specification is 20...

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
schema.last_error.context[1]     #=> "in object property `age'"
```

_Respect_ does not parse JSON document by default but it is easy to do so using one of the JSON decoder available in Ruby:

```ruby
schema.validate?(JSON.parse('{ "name": "My name", "age": 20, "email": "me@example.com" }'))   #=> true
```

Once a JSON document has been validated, we often want to turn its basic strings and integers into real object like `URI`.
_Respect_ does that automatically for you for standard objects:

```ruby
schema = Respect::ObjectSchema.define do |s|
  s.Uris "homepage"
end
doc = { "homepage" => "http://example.com" }
schema.validate!(doc)                            #=> true
doc["homepage"].class                            #=> URI::HTTP
```

You can easily extend the sanitizer with your own object type.

```ruby
# Let's assume you have an object type define like this
class Place
  def initialize(latitude, longitude)
    @latitude, @longitude = latitude, longitude
  end

  attr_reader :latitude, :longitude

  def ==(other)
    @latitude == other.latitude && @longitude == other.longitude
  end
end

module Respect
  # Then you must extend the Schema hierarchy with the new schema for you custom type.
  # The `CompositeSchema` class assist you in this task so you just have to overwrite
  # two methods.
  class PlaceSchema < CompositeSchema
    # The 'schema' method returns the schema specification for your custom type.
    def schema
      Respect::ObjectSchema.define do |s|
        s.float "latitude"
        s.float "longitude"
      end
    end

    # The 'sanitize' method is called with the JSON document if the validation succeed.
    # The returned value will be inserted into the JSON document.
    def sanitize(doc)
      Place.new(doc[:latitude], doc[:longitude])
    end
  end
end

# Define the structure of your JSON document as usual.
schema = Respect::ObjectSchema.define do |s|
  # Note that you have access to your custom schema via the "place" method.
  s.place "home"
end

doc = {
  "home" => {
    "latitude" => "48.846559",
    "longitude" => "2.344519",
  }
}

schema.validate!(doc)                              #=> true
doc["home"].class                                  #=> Place
```

# Getting started!

The easiest way to install _Respect_ is to add it to your `Gemfile`:

```ruby
gem "respect"
```

Then, install it on the command line:

```
$ bundle install
```

Finally, you can start using it in your program like this:

```ruby
require 'respect'

schema = Respect::ObjectSchema.define do |s|
  s.string "name"
  s.integer "age", greater_than: 18
end

schema.validate?({ "name" => "John", "age" => 30 })
```

# JSON Schema implementation status

_Respect_ currently implements most of the features included in the
[JSON Schema specification draft v3](http://tools.ietf.org/id/draft-zyp-json-schema-03.html).

See the `STATUS_MATRIX` file included in this package for detailed information.

# License

_Respect_ is released under the term of the [MIT License](http://opensource.org/licenses/MIT).
Copyright (c) 2013 Nicolas Despres.

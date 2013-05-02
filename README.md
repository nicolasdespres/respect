# Welcome to Respect

_Respect_ is a JSON schema validation system providing a DSL to concisely write your schema. It also comes with a
validator, a sanitizer and dumpers to generate valid [json-schema.org](http://json-schema.org/) compliant specifications.

Respect is named after the contraction of _REST_ and _SPEC_. Indeed, it is first intended to be used to specify REST API
in the context of a Web application.

There is a plugin called [Respect for Rails](https://github.com/nicolasdespres/respect-rails) which integrate this gem in Rails.

# Features

* Compact Ruby DSL to specify your JSON schema.
* Standard [json-schema.org](http://json-schema.org/) specification generator.
* JSON document validator.
* Contextual validation error.
* Document sanitizer: turn plain string and integer values into real objects.
* Extensible API to add your custom validator and sanitizer.
* Extensible macro definition system to factor you schema definition code.

# Take a Tour

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
schema.last_error.context[1]     #=> "in object property `age'"
```

_Respect_ does not parse JSON document by default but it is easy to do so using one of the JSON parser available in Ruby:

```ruby
schema.validate?(JSON.parse('{ "name": "My name", "age": 20, "email": "me@example.com" }'))   #=> true
```

Once a JSON document has been validated, we often want to turn its basic strings and integers into real object like `URI`.
_Respect_ does that automatically for you for standard objects:

```ruby
schema = Respect::ObjectSchema.define do |s|
  s.uri "homepage"
end
doc = { "homepage" => "http://example.com" }
schema.validate!(doc)                            #=> true
doc["homepage"].class                            #=> URI::HTTP
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
```

Finally, you define the structure of your JSON document as usual. Note that you have
access to your custom schema via the `place` method.

```ruby
schema = Respect::ObjectSchema.define do |s|
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

Sometimes you just want to extend the DSL with a new statement providing higher level feature than
the primitive `integer`, `string` or `float`, etc... For instance if you specify identifier
in your schema like this:

```ruby
Respect::ObjectSchema.define do |s|
  s.integer "article_id", greater_than: 0
  s.string "title"
  s.object "author" do |s|
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
Respect::ObjectSchema.define do |s|
  s.id "article"
  s.string "title"
  s.object "author" do |s|
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

Although, the semantics of the schema definition DSL available in this library may change slightly from the
_JSON schema standard_, we have tried to keep it as close as possible. For instance the `strict` option of
object schema is not presented in the standard. However, when a schema is dumped to its _JSON Schema_ version
the syntax and semantic have been followed. You should note that there is no "loader" available yet in this
library. In other word, you cannot instantiate a Schema class from a _JSON Schema_ string representation.

# Coming soon

Many other great features are planned for the next releases. Here a short list of what is coming soon:

* Non-experimental extensible validator API.
* More extensible DSL API: define your own definition class, create macros not based on core statements.
* More extensible Schema API: sub-class Schema not only CompositeSchema.
* A way to set options for nested schema in custom types.
* More extensible dumpers API.

And many more... see the issue tracker with tag FIXME for more information.

# Getting help

The easiest way to get help about how to use this library is to post your question on the
[Respect discussion group](FIXME). I will be glade to answer. I may have already answered the
same question so before you post your question take a bit of time to search the group.

You can also read these documents for further documentation:

* [Repect API reference documentation](FIXME)

# Feedback

I would love to hear what you think about this library. Feel free to post any comments/remarks on the
[Respect discussion group](FIXME).

# Reporting bugs

Even if I prefer patches, I also like bug reports. Feel free to create new issues in this project bug tracker on
GitHub. I will tag them. Before you start just a few reminders:

1. A bug that I can reproduce on my machine is a half-fixed bug. So please, include as much information as you can.
   The best would be to include a failing test or a small ruby script reproducing the bug. If you can't be sure to
   mention the version of Ruby you have used, th full backtrace of the exception if you add one, etc...
1. A documented and tested feature is a half-implemented features. Sometimes English and natural languages in general
   failed to describe your thought precisely. A failing test will mean exactly what you want.
1. Do not post question in the issue trackers. Use the [Respect discussion group](FIXME) instead.

# Contributing patches

I spent quite a lot of time writing this gem but there is still a lot of work to do. Whether it is a bug-fix,
a new feature, some code re-factoring, or documentation clarification, I will be glade to merge your pull request
on GitHub. Before you start a few reminders:

1. Every commits must have a comprehensive commit message.
1. Whenever you are fixing a bug or adding a new features, tests are required.
1. A bit of documentation so that others can understand your code.

Don't worry these rules are not strict. If you can't make it I will be glade to help.

# License

_Respect_ is released under the term of the [MIT License](http://opensource.org/licenses/MIT).
Copyright (c) 2013 Nicolas Despres.

#!/usr/bin/ruby -KU
# Example code coming from the README.md file.
# This file is cheap test for this code.
# WARNING: this code is duplicated from the README.md file so it may be not synchronized.

require 'respect'

schema = Respect::HashSchema.define do |s|
  s.string "name"
  s.integer "age", greater_than: 18
  s.string "email", format: :email
end

require 'json'
puts JSON.pretty_generate(schema.to_h)
#print
# {
#   "type": "object",
#   "properties": {
#     "name": {
#       "type": "string",
#       "required": true
#     },
#     "age": {
#       "type": "integer",
#       "required": true,
#       "minimum": 18,
#       "exclusiveMinimum": true
#     },
#     "email": {
#       "type": "string",
#       "required": true,
#       "format": "email"
#     }
#   }
# }

schema.validate?({ "name" => "My name", "age" => 20, "email" => "me@example.com" })          #=> true
schema.validate?({ "name" => "My name", "age" => 15, "email" => "me@example.com" })          #=> false

schema.last_error                #=> "15 is not greater than 18"
schema.last_error.message        #=> "15 is not greater than 18"
schema.last_error.context[0]     #=> "15 is not greater than 18"
schema.last_error.context[1]     #=> "in hash property `age'"

schema.validate?(JSON.parse('{ "name": "My name", "age": 20, "email": "me@example.com" }'))   #=> true

schema = Respect::HashSchema.define do |s|
  s.uri "homepage"
end
object = { "homepage" => "http://example.com" }
schema.validate!(object)                            #=> true
object["homepage"].class                            #=> URI::HTTP

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

Respect::HashSchema.define do |s|
  s.integer "article_id", greater_than: 0
  s.string "title"
  s.hash "author" do |s|
    s.integer "author_id", greater_than: 0
    s.string "name"
  end
end

module MyMacros
  def id(name, options = {})
    unless name.nil? || name == "id" || name =~ /_id$/
      name += "_id"
    end
    integer(name, { greater_than: 0 }.merge(options))
  end
end
Respect.extend_dsl_with(MyMacros)

Respect::HashSchema.define do |s|
  s.id "article"
  s.string "title"
  s.hash "author" do |s|
    s.id "author"
    s.string "name"
  end
end

require 'respect'

schema = Respect::HashSchema.define do |s|
  s.string "name"
  s.integer "age", greater_than: 18
end

schema.validate?({ "name" => "John", "age" => 30 })

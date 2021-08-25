[![Actions Status](https://github.com/petalmd/bright_serializer/workflows/Build/badge.svg)](https://github.com/petalmd/bright_serializer/actions?query=workflow%3ABuild)
[![Gem Version](https://badge.fury.io/rb/bright_serializer.svg)](https://badge.fury.io/rb/bright_serializer)
[![Coverage Status](https://coveralls.io/repos/github/petalmd/bright_serializer/badge.svg?branch=master)](https://coveralls.io/github/petalmd/bright_serializer?branch=master)

# BrightSerializer

This is a very light and fast gem to serialize object in a Ruby project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bright_serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bright_serializer

## Usage and features

### Basic

Create a class and include `BrightSerializer::Serializer`

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
  
  # With a block
  attribute :name do |object|
    "#{object.first_name} #{object.last_name}"
  end
  
  # With a block shorter
  attribute :created_at, &:to_s
end

AccountSerializer.new(Account.first).to_h
AccountSerializer.new(Account.first).to_json
```

### Params

You can pass params to your serializer. For example to have more context with the authenticated user.

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
  
  attribute :friend do |object, params|
    object.is_friend_with? params[:current_user]
  end
end

current_user = Account.find(authenticated_account_id)
AccountSerializer.new(Account.first, params: { current_user: current_user }).to_json
```

### Conditional Attributes

Attribute can be remove from serialization by passing a `proc` to the option `if`. If the proc return `true` the attibute 
 will be serialize. `object` and `params` or accessible. 

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
  
  attribute :email, if: -> { |object, params| params[:current_user].is_admin? }
end
```

### Transform keys

By default, keys or not transformed.

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  set_key_transform :underscore
end

set_key_transform :underscore # "first_name" => "first_name"
set_key_transform :camel # "first_name" => "FirstName"
set_key_transform :camel_lower # "first_name" => "firstName"
set_key_transform :dash # "first_name" => "first-name"
```

### Instance serializer fieldsets

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
end

# Only serialize first_name and last_name
AccountSerializer.new(Account.first, fields: [:first_name, :last_name]).to_json
```

### Relations

For now, relations or declared like any other attribute.

```ruby
class FriendSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
end

class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
  
  attribute :friends do |object|
    FriendSerializer.new(object.friends)
  end
end
```

### Sideload

Sometimes, the collection to serialize can have complex attributes and required some extra computation.
When `includes` are not enough `sideload` can use the collection to serialize to retrieve extra data that will be
accessible during the serialization.

```ruby
class AccountSerializer
 include BrightSerializer::Serializer
 attributes :id, :first_name, :last_name

 # sideload are passed as the third param of the block. To use a specific
 # `sideloader` call the method with the same name setted with `sideload`.
 attribute :friend_ids do |object, _params, sideloaders|
  sideloaders.friend_ids[object.id]
 end

 # Load the data and return in a format that can be used with `object`.
 # `params` is also accessible as the second param passed in the block.
 sideload :friend_ids do |objects, _params|
  Friend.where(account_id: objects.map(&:id))
        .pluck(:account_id, :friend_id)
        .each_with_object({}) do |(account_id, friend_id), result|
   result[account_id] ||= []
   result[account_id] << friend_id
  end
 end
end
```

### Entity

You can define the entity of your serializer to generate documentation with the option `entity`.
The feature was build to work with [grape-swagger](https://github.com/ruby-grape/grape-swagger). 
For more information about defining a model entity see the [Swagger documentation](https://swagger.io/specification/v2/?sbsearch=array%20response#schema-object).

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attribute :id, entity: { type: :string, description: 'The id of the account' }
  attribute :name

  attribute :friends,
    entity: { 
      type: :array, items: { ref: 'FriendSerializer' }, description: 'The list the account friends.'
     } do |object|
    FriendSerializer.new(object.friends)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## New release

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/petalmd/bright_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

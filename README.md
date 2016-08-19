# Proxima

Proxima is a REST Model for use with REST APIs. Proxima's goal is to be
flexible, so it refrains from imposing opinions about the remote api. The goal
is to allow a Rails application to model any remote REST resource regardless of
how the remote REST is implemented. Things like object shape and property names
can be completely remapped. Even subpaths can be putted out into attributes.

Proxima implements the entire Active Model interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'proxima'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proxima

## Usage

To use proxima first create an initializer. In the initializer create the Proxima::Api instances you need. One for each API you need to interact with. From there create your models using the APIs. Don't forget to set you base uri and attributes for each model.

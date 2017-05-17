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

To use Proxima you must first declare your APIs. You may create as many as you like, but for this example we'll just add one for the GitHub API. You can do this in an initializer file.

```ruby
# file: config/initializers/proxima.rb

GIT_HUB_API_V3 = Proxima::Api.new('https://api.github.com', {
  headers: {
    accept:        'application/vnd.github.v3+json'
    authorization: 'token OAUTH-TOKEN'
  }
})
```

Now that we've created our `GIT_HUB_API_V3` we can use it to create models.

```ruby
# file: app/models/user_repo.rb

class UserRepo < Proxima::Model
    api GIT_HUB_API_V3

    # First we must set our model's base uri
    base_uri "/user/repos"
    
    #then add the attributes we are intrested in
    attribute :id,               String,  'id'
    attribute :name,             String,  'name'
    attribute :full_name,        String,  'full_name'
    attribute :description,      String,  'description'
    attribute :private,          String,  'private'
    attribute :fork,             String,  'fork'
    attribute :url,              String,  'url'
    attribute :homepage,         String,  'homepage'
    attribute :forks_count,      Integer, 'forks_count'
    attribute :stargazers_count, Integer, 'stargazers_count'
    attribute :watchers_count,   Integer, 'watchers_count'
    
    # Note that any of the active model methods are avalible on proxima
    # models so feel free to add things such as validation.
    
    def useful_stats
        {
            forks:      self.forks_count,
            stargazers: self.stargazers_count,
            watchers:   self.watchers_count
        }
    end
end
```

These models can be used in your controllers once defined
```ruby
# file: app/controllers/user_repos_controller.rb

class UserReposController < ApplicationController
    def index
        @repo_stats = UserRepo.find().map({ |u| u.useful_stats })
    end
end
```

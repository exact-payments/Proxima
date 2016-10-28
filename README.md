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

    # First we must set our model's base uri
    base_uri "/user/repos"
    
    #then add the attributes we are intrested in
    attribute :id,               'id'
    attribute :name,             'name'
    attribute :full_name,        'full_name'
    attribute :description,      'description'
    attribute :private,          'private'
    attribute :fork,             'fork'
    attribute :url,              'url'
    attribute :homepage,         'homepage'
    attribute :forks_count,      'forks_count'
    attribute :stargazers_count, 'stargazers_count'
    attribute :watchers_count,   'watchers_count'
    
    # Note that any of the active model methods are avalible on proxima
    # models so feel free to add things such as validation.
    
    def useful_stats
        {
            forks:      forks_count,
            stargazers: stargazers_count,
            watchers:   watchers_count
        }
    end
end
```

These models can be used in your controllers once defined
```ruby
# file: app/controllers/user_repos_controller.rb

class UserReposController < ApplicationController
    def index
        @repos = UserRepo.find()
    end
end
```

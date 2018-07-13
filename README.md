# ActiveStorage::Imgur

[![Gem Version](https://badge.fury.io/rb/activestorage-imgur.svg)](https://badge.fury.io/rb/activestorage-imgur)
[![CircleCI](https://circleci.com/gh/yfxie/activestorage-imgur.svg?style=svg)](https://circleci.com/gh/yfxie/activestorage-imgur)

An ActiveStorage driver for storing `images` on [Imgur hosting](https://imgur.com/).


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'activestorage-imgur'
```

And then execute:
```bash
$ bundle
```

## Quick Start

1. generate a migration that creates the dependent table:
    ```
    # if you never use activestorage, run rails active_storage:install first. 
    
    rails g active_storage_imgur:install
    rails db:migrate
    ```
2. Set `config.active_storage.service` to `:imgur` in any of `config/environments/*.rb` files.
3. Set the imgur config in your `config/storage.yml`: 
    ```
    imgur:
      service: Imgur
      client_id: <%= ENV['IMGUR_CLIENT_ID'] %>
      client_secret: <%= ENV['IMGUR_CLIENT_SECRET'] %>
      access_token: <%= ENV['IMGUR_ACCESS_TOKEN'] %>
      refresh_token: <%= ENV['IMGUR_REFRESH_TOKEN'] %>
    ```

    for environment variables on the above, follow steps:
    
    1. sign an imgur account: [https://imgur.com/](https://imgur.com/)
    2. to create an imgur application visit: [https://api.imgur.com/oauth2/addclient](https://api.imgur.com/oauth2/addclient)
    3. you will get client_id and client_secret after creating an application.
    4. run `rails imgur:authorize CLIENT_ID='CLIENT_ID' CLIENT_SECRET='CLIENT_SECRET'` to get `access_token` and `refresh_token`.
 
3. Add attachment to your model just like explanation of [activestorage](http://edgeguides.rubyonrails.org/active_storage_overview.html):
    
    ```
    class User
      has_one_attached :avatar
      has_many_attached :photos
      ...
    end
    ```
    
    ```
    <%= form_for @user do |form| %>
      <% if @user.errors.any? %>
        <ul>
          <% @user.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
        </ul>
      <% end %>
      
      Avatar: <%= form.file_field :avatar %>
      Photo: <%= form.file_field :photos, multiple: true %>
      <%= form.submit %>
    <% end %>
    ```
    
    ```
    <%= image_tag user.avatar %>
    <%= image_tag user.photos.first.variant(resize: "100x100") %>
    ```
    
    for more detail usage like uploading, image displaying. see official documentations[activestorage](http://edgeguides.rubyonrails.org/active_storage_overview.html).


## Be careful

1. this gem has built-in validation to validate image file. 
   attachment can be nil, if it presents, it only accept image type.
   if your app only accept files with image types, it should be fine.
2. though imgur is free, it still has rate limits, if your application hit the daily limit, uploading function will probably be terminated.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

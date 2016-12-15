# Field Test

:maple_leaf: A/B testing for Rails

- Designed for web and email
- Seamlessly handles the transition from anonymous visitor to logged in user
- Results are stored in your database

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'field_test'
```

And run:

```sh
rails g field_test:install
```

And mount the dashboard in your `config/routes.rb`:

```ruby
mount FieldTest::Engine, at: "admin/field_test"
```

Be sure to [secure the dashboard](#security) in production.

## Getting Started

Add an experiment to `config/field_test.yml`.

```yml
experiments:
  button_color:
    variants:
      - red
      - green
      - blue
```

Refer to it in views, controllers, and mailers.

```ruby
button_color = field_test(:button_color)
```

When someone converts, record it with:

```ruby
field_test_converted(:button_color)
```

Get the results with:

```ruby
experiment = FieldTest::Experiment.find(:button_color)
experiment.results
```

When an experiment is over, specify a winner:

```yml
experiments:
  button_color:
    winner: red
```

All calls to `field_test` will now return the winner.

## Features

You can specify a variant with query parameters to make testing easier

```
http://localhost:3000/?field_test[button_color]=red
```

For mailers, you need to specify a participant:

```ruby
field_test(:button_color, participant: "test@example.org")
```

## Funnels

For advanced funnels, we recommend an analytics platform like [Ahoy](https://github.com/ankane/ahoy) or [Mixpanel](https://mixpanel.com/).

You can pass experiments and variants as properties.

## Security

#### Basic Authentication

Set the following variables in your environment or an initializer.

```ruby
ENV["FIELD_TEST_USERNAME"] = "link"
ENV["FIELD_TEST_PASSWORD"] = "hyrule"
```

#### Devise

```ruby
authenticate :user, -> (user) { user.admin? } do
  mount FieldTest::Engine, at: "admin/field_test"
end
```

## TODO

- Add confidence to results
- Add [Bayesian confidence](http://www.evanmiller.org/bayesian-ab-testing.html) to results
- Exclude bots
- User interface

## History

View the [changelog](https://github.com/ankane/field_test/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/field_test/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/field_test/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

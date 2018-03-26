# Field Test

:maple_leaf: A/B testing for Rails

- Designed for web and email
- Comes with a [handy dashboard](https://fieldtest.dokkuapp.com/)
- Seamlessly handles the transition from anonymous visitor to logged in user

Uses [Bayesian statistics](https://www.evanmiller.org/bayesian-ab-testing.html) to evaluate results so you don’t need to choose a sample size ahead of time.

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "field_test"
```

Run:

```sh
rails g field_test:install
```

And mount the dashboard in your `config/routes.rb`:

```ruby
mount FieldTest::Engine, at: "field_test"
```

Be sure to [secure the dashboard](#security) in production.

![Screenshot](https://ankane.github.io/field_test/screenshot6.png)

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

When an experiment is over, specify a winner:

```yml
experiments:
  button_color:
    winner: green
```

All calls to `field_test` will now return the winner, and metrics will stop being recorded.

## Features

You can specify a variant with query parameters to make testing easier

```
?field_test[button_color]=green
```

Assign a specific variant to a user with:

```ruby
experiment = FieldTest::Experiment.find(:button_color)
experiment.variant(participant, variant: "green")
```

You can also change a user’s variant from the dashboard.

## Config

By default, bots are returned the first variant and excluded from metrics. Change this with:

```yml
exclude:
  bots: false
```

Keep track of when experiments started and ended. Use any format `Time.parse` accepts. Variants assigned outside this window are not included in metrics.

```yml
experiments:
  button_color:
    started_at: Dec 1, 2016 8 am PST
    ended_at: Dec 8, 2016 2 pm PST
```

Add a friendlier name and description with:

```yml
experiments:
  button_color:
    name: Buttons!
    description: >
      Different button colors
      for the landing page.
```

By default, variants are given the same probability of being selected. Change this with:

```yml
experiments:
  button_color:
    variants:
      - red
      - blue
    weights:
      - 85
      - 15
```

If the dashboard gets slow, you can make it faster with:

```yml
cache: true
```

This will use the Rails cache to speed up winning probability calculations.

## Funnels

You can set multiple goals for an experiment to track conversions at different parts of the funnel. First, run:

```sh
rails g field_test:events
```

And add to your config:

```yml
experiments:
  button_color:
    goals:
      - signed_up
      - ordered
```

Specify a goal during conversion with:

```ruby
field_test_converted(:button_color, goal: "ordered")
```

The results for all goals will appear on the dashboard.

## Analytics Platforms

You can also send experiment data to analytics platforms like [Google Analytics](https://www.google.com/analytics/), [Mixpanel](https://mixpanel.com/), and [Ahoy](https://github.com/ankane/ahoy). Use:

```ruby
field_test_experiments
```

to get all experiments and variants for a participant and pass them as properties.

## Security

#### Devise

```ruby
authenticate :user, -> (user) { user.admin? } do
  mount FieldTest::Engine, at: "field_test"
end
```

#### Basic Authentication

Set the following variables in your environment or an initializer.

```ruby
ENV["FIELD_TEST_USERNAME"] = "moonrise"
ENV["FIELD_TEST_PASSWORD"] = "kingdom"
```

## Credits

A huge thanks to [Evan Miller](https://www.evanmiller.org/) for deriving the Bayesian formulas.

## TODO

- Code samples for analytics platforms

## History

View the [changelog](https://github.com/ankane/field_test/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/field_test/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/field_test/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

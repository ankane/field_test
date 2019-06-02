# Field Test

:maple_leaf: A/B testing for Rails

- Designed for web and email
- Comes with a [handy dashboard](https://fieldtest.dokkuapp.com/)
- Seamlessly handles the transition from anonymous visitor to logged in user

Uses [Bayesian statistics](https://www.evanmiller.org/bayesian-ab-testing.html) to evaluate results so you don’t need to choose a sample size ahead of time.

[![Build Status](https://travis-ci.org/ankane/field_test.svg?branch=master)](https://travis-ci.org/ankane/field_test)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "field_test"
```

Run:

```sh
rails generate field_test:install
```

And mount the dashboard in your `config/routes.rb`:

```ruby
mount FieldTest::Engine, at: "field_test"
```

Be sure to [secure the dashboard](#dashboard-security) in production.

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

## Participants

Any model or string can be a participant in an experiment.

For web requests, Field Test uses `current_user` (if it exists) and an anonymous visitor id to determine the participant. Set you own participant with:

```ruby
class ApplicationController < ActionController::Base
  def field_test_participant
    current_company
  end
end
```

For mailers, it tries `@user` then `params[:user]` by default. Set your own with:

```ruby
class ApplicationMailer < ActionMailer::Base
  def field_test_participant
    @company
  end
end
```

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

Cookies [master]

```yml
cookies: false
```

If the dashboard gets slow, you can make it faster with:

```yml
cache: true
```

This will use the Rails cache to speed up winning probability calculations.

By default, the dashboard rounds all calculated percentages to the nearest integer. Change this with: [master]

```yml
precision: 1
```

## Multiple Goals

You can set multiple goals for an experiment to track conversions at different parts of the funnel. First, run:

```sh
rails generate field_test:events
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

You can also send experiment data to analytics platforms like [Segment](https://segment.com), [Amplitude](https://amplitude.com), and [Ahoy](https://github.com/ankane/ahoy). Use:

```ruby
field_test_experiments
```

to get all experiments and variants for a participant and pass them as properties.

### Ahoy

You can configure Field Test to use Ahoy's visitor token instead of creating it's own:

```ruby
class ApplicationController < ActionController::Base
  def field_test_participant
    [ahoy.user, ahoy.visitor_token]
  end
end
```

## Dashboard Security

#### Devise

```ruby
authenticate :user, ->(user) { user.admin? } do
  mount FieldTest::Engine, at: "field_test"
end
```

#### Basic Authentication

Set the following variables in your environment or an initializer.

```ruby
ENV["FIELD_TEST_USERNAME"] = "moonrise"
ENV["FIELD_TEST_PASSWORD"] = "kingdom"
```

## Reference

Associate models with field test memberships:

```ruby
class User < ApplicationRecord
  has_many :field_test_memberships, class_name: "FieldTest::Membership", as: :participant
end
```

And use:

```ruby
user.field_test_memberships
```

## Upgrading

### 0.3.0

Upgrade the gem and add to `config/field_test.yml`:

```yml
legacy_participants: true
```

Also, if you use Field Test in emails, know that the default way participants are determined has changed. Restore the previous way with:

```ruby
class ApplicationMailer < ActionMailer::Base
  def field_test_participant
    message.to.first
  end
end
```

We also recommend upgrading participants when you have time.

#### Upgrading Participants

Field Test 0.3.0 splits the `field_test_memberships.participant` column into `participant_type` and `participant_id`.

To upgrade without downtime, create a migration:

```sh
rails generate migration upgrade_field_test_participants
```

with:

```ruby
class UpgradeFieldTestParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :field_test_memberships, :participant_type, :string
    add_column :field_test_memberships, :participant_id, :string

    add_index :field_test_memberships, [:participant_type, :participant_id, :experiment], unique: true, name: "index_field_test_memberships_on_participant_and_experiment"
  end
end
```

After you run it, writes will go to both the old and new sets of columns.

Next, backfill data:

```ruby
FieldTest::Membership.where(participant_id: nil).find_each do |membership|
  participant = membership.participant

  if participant.include?(":")
    participant_type, _, participant_id = participant.rpartition(":")
    participant_type = nil if participant_type == "cookie" # legacy
  else
    participant_id = participant
  end

  membership.update!(
    participant_type: participant_type,
    participant_id: participant_id
  )
end
```

Finally, remove `legacy_participants: true` from the config file. Once you confirm it’s working, drop the `participant` column (you can rename it first just to be extra safe).

## Credits

A huge thanks to [Evan Miller](https://www.evanmiller.org/) for deriving the Bayesian formulas.

## History

View the [changelog](https://github.com/ankane/field_test/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/field_test/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/field_test/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

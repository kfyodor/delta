# Δ (Delta) [![Build Status](https://travis-ci.org/konukhov/delta.svg?branch=master)](https://travis-ci.org/konukhov/delta)

Yet another changes tracker/auditor for Rails' ActiveRecord.

+ Tracks associations. Yes, it tracks associations!
+ Model changes are stored as an append-only log of immutalbe diffs (deltas).
+ Each delta contains information about an action (add, remove, change), what was changed, who changed it, and a serialized json payload of the changed value.
+ This library is designed for easy output/streaming to whatever destination you want.
+ Adapters. As this library is in early alpha, only ActiveRecord adapter is available. HTTP, ActiveJob, Mongo, Redis and Kafka (maybe) adapters will be available later.

*THIS LIBRARY IS IN EARLY DEVELOPMENT STAGE*. There WILL be breaking changes until 0.1 release.

## Installation

Add `delta` to your Gemfile

```ruby
  gem 'delta', github: 'konukhov/delta'
```

Then generate a migration (or, if you're non-Rails user, copy it manually from lib/generators).

```sh
  bundle install
  bundle exec rails g delta:create_talbe
```

## Usage

Docs, examples and roadmap will be available later.

See couple of raw examples and use cases below.

```ruby

class Order < ActiveRecord::Base
  has_many :line_items
  has_many :items, through: :line_items

  track_deltas :address, :promo_code, :items
end

order = Order.create(address: "Some address", items: [item1])
order.update address1: "New address", promo_code: "promo"
order.items << item2
```

After this `order.deltas` will be looking like this:

```ruby
[
  {
    id: 1,
    user: <User:...>, # if updated from controller with current_user
    model: <Order:...>,
    object: { # There's always an array
      [{
        name: "address",
        action: "C", # "C" == change, "A" == add, "R" == remove
        timestamp: 1441335511,
        object: "New address"
      },
      {
        name: "promo_code",
        action: "C",
        timestamp: 1441335511,
        object: "promo"
      }]
    }
  },
  {
    id: 2,
    user: <User:...>,
    model: <Order:...>,
    object: {
      [{
        name: "items",
        action: "A"
        timestamp: 1441335543,
        object: { "id" => 1 } # associations are serialized like this by default
      }]
    }
  }
]
```

For more complicated use cases use `track_deltas_on`. Those use cases include:
+ Including more fields in serialized associations.
+ Tracking associations changes.
+ You want to track only added associations.

```ruby
class Company < ActiveRecord::Base
  has_many :employments
  has_many :employees, through: :employments
  belongs_to :user

  track_deltas_on :name

  track_deltas_on :employments, serialize: [:position, :salary],
                                notify: true, # Track association changes.
                                              # Could also be an association
                                              # name, like `notify: :company`.
                                only: []      # `only` option means which
                                              # actions (add, remove for
                                              # associations) to track.

  track_deltas_on :employees,   serialize: [:first_name, :last_name]
end

company = Company.create(name: "My company")
company.employees << employee # Created delta with serialized employee.

Employment
  .where(company: company, employee: employee)
  .first
  .update(position: "Engineer") # Created delta for company with serialized employemnt.
```

Caveats:
+ For now Delta tracks only model updates.
+ Tracks association changes only if associaion has_one or belongs_to model.
+ Be careful with `has_many :through` associations since there're usually 2 objects being added - an associated model and a through model. Do not track both.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/konukhov/delta. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Similar libs / inspiration

+ https://github.com/airblade/paper_trail
+ https://github.com/collectiveidea/audited


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

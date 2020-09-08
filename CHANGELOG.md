## 0.4.1 (2020-09-07)

- Use `datetime` type in migration

## 0.4.0 (2020-08-04)

- Fixed CSRF vulnerability with non-session based authentication - [more info](https://github.com/ankane/field_test/issues/28)
- Fixed cache key for requests

## 0.3.2 (2020-04-16)

- Added support for excluding IP addresses

## 0.3.1 (2019-07-01)

- Added `closed` and `keep_variant`
- Added `field_test_upgrade_memberships` method
- Fixed API controller error
- Fixed bug where conversions were recorded after winner

Security

- Fixed arbitrary variants via query parameters - [more info](https://github.com/ankane/field_test/issues/17)

## 0.3.0 (2019-06-02)

- Added support for native apps
- Added `cookies` option
- Added `precision` option
- Fixed bug in results with multiple goals
- Fixed issue where metrics disappeared from dashboard when moving to multiple goals
- Dropped support for Rails < 5

Breaking changes

- Split out participant id and type
- Changed participant logic for emails

## 0.2.4 (2019-01-03)

- Fixed `PG::AmbiguousColumn` error

## 0.2.3 (2018-01-28)

- Fixed participant reporting for multiple goals

## 0.2.2 (2017-05-01)

- Added support for Rails 5.1

## 0.2.1 (2016-12-18)

- Added support for multiple goals

## 0.2.0 (2016-12-17)

- Better web UI
- Removed `cookie:` prefix for unknown participants

## 0.1.2 (2016-12-17)

- Exclude bots
- Mailer improvements

## 0.1.1 (2016-12-15)

- Added basic web UI

## 0.1.0 (2016-12-14)

- First release

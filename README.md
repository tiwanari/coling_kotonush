# Kotonush: Understanding Concepts Based on Values behind Social Media
- **This is a snapshot of the front-end system for [COLING 16 System Demonstrations](http://coling2016.anlp.jp/), an international conference.**
- **This has not been refactored and will not be maintained.**
- Please see [the back-end system](https://github.com/tiwanari/coling_order_concept).


author: Tatsuya Iwanari, Kohei Ohara


## Usage

```
bundle install
bundle exec rake bower:install
bundle exec rails server
```

## .env
We have `.env` to keep variables.

The list is like this;
```
BASIC_AUTH_USERNAME
BASIC_AUTH_PASSWORD
SEARCH_SCRIPT_URL
PREFIX_SCRIPT_URL
```

Please specify the proper values for your environment.

YAML Like a Pro
===============

YAML (YAML Ain't Markup Language) is a cross-programming-language data serialization language whose primary focus is Human Friendliness. This generally means less funny characters like ('`{}`, `[]`, `"`, etc), so that the data is easier to read and write. These characters _are_ used, but YAML tries hard to make them needed as little as possible; more for harder cases, less so for simple things.

While the YAML language and data model was made deep enough to handle very complex needs of serialization, like object marshalling and stream processing, YAML most commonly gets used as a cheap and easy config file format. As one of the 3 original language designers, I can point out that while we didn't see YAML as a particulary excellent format for the config use case, it does tend to appeal to people for that. This is probably because of:

* Low need for special characters
* Readily available in most programming languages
* Ability to scale up to more complex needs over time
* The name is fun to say ;)

These days I see YAML popping up in almost every imaginable type of project and framework; big and small, Open Source and Enterprise. I've sat through dozens of talks at conferences, where YAML shows up somewhere. It is never given any more special attention than a mouse or keyboard. I've heard big names like Mark Shuttleworth of Canonical, mention in passing that all the data of his latest project was import / exportable in YAML.

While this makes a lowly hacker like me grin from ear to ear, its sad to see the same common mistakes made over and over. "Mistake" is not quite the right word; the YAML files I see in the world are not _wrong_, they just aren't _right_!  People tend to use extra syntax when they don't need it, or not write YAML in the most clean and elegant way. This leads to a cargo-cult, copy / paste effect where the same _not-so-beautiful_ things happen over and over.

In this article, I'd like to show you a few simple things that will make you "YAML like a Pro". I'll look at a couple of common use cases in the wild: the YAML used for [Travis CI](https://travis-ci.org/), and the YAML used by the Private PaaS framework [Stackato](http://stackato.com/). I'm showing these because I personally see them all the time, but the advice here is applicable to anything using YAML as a human input.

## Don't Indent a Sequence inside a Mapping

**Travis CI** is a wonderful Continuous Integration service that uses YAML for its user interface. Instructions for how a project should be tested can succinctly be encoded in YAML, and since the service needs to work the same for lots of languages, YAML is a good choice. The file is always called `.travis.yml`.

In YAML, a hash or dictionary is called a **Mapping** and an array or list is called a **Sequence**. Many people don't realize that a sequence under a mapping doesn't need extra indentation. Let's look at the `.travis.yml` file of a popular project on [GitHub](https://github.com/), [factory_girl](https://github.com/thoughtbot/factory_girl/blob/master/.travis.yml).

    rvm:
      - 1.9.3
      - 2.0.0
      - 2.1.0
      - jruby-19mode
    before_install:
      - gem update --system
    install: "bundle install"
    script: "bundle exec rake spec:unit spec:acceptance features"
    jdk:
      - openjdk6
    gemfile:
      - gemfiles/3.1.gemfile
      - gemfiles/3.2.gemfile
      - gemfiles/4.0.gemfile
      - gemfiles/4.1.gemfile
    branches:
      only:
        - master

This is perfectly valid YAML, but it can be more perfect! Every line that has a dash as its first visible character, has 2 extra spaces in front of it. ie It can be done this way:

    rvm:
    - 1.9.3
    - 2.0.0
    - 2.1.0
    - jruby-19mode
    before_install:
    - gem update --system

The reason is that YAML counts the dash+space as indentation, and when done that way it looks really nice.

This brings up 2 higher level YAML concepts. First, always use 2 character indentation. YAML accepts any number, but 2 spaces is always best, and it's the way YAML is dumped canonically. That leads to the second concept... when in doubt, look at how your YAML **dumper** outputs YAML. It is almost always the best way. (There's an exception to this, where humans can do a little better that I'll cover in a moment).

## Don't Over-quote your Strings

YAML has 5 styles of writing string data. The 3 most common styles are plain (unquoted), single quoted, and double quoted. They all have different useful properties. Sometimes quotes are needed around a string, but usually they are not, especially for config strings. People tend to use quotes when they are not certain. While this might be safe and easy, why not learn the simple rules and Keep YAML Tidy?

In the `travis.yml` file above, **none** of the double quotes used are needed. I'll guess that the author thought that strings with spaces in them should be quoted. This isn't the case. Let's review when quotes **are** needed.

Without going into the quoting semantics of double vs single, let's see when **plain** style just won't work. Here are the basics:

* Any string that **starts** with a YAML syntax character
Characters like one of `!#&*>|?{}[],'"` and also strings that start with a dash followed by a space. Once YAML realizes from the first character that the data is a plain scalar, any of those characters can be used. (Unless it breaks the next rule.)
* Any strings that contain a colon+space, or space+pound
This is YAML syntax for key/value separator or comment start. YAML allows for just a colon or pound to be used if a space is not next to them. That supports stuff like:
* Strings that begin or end with whitespace characters
This is **very** rare in config files.

## Do Split Your Long Strings

Here's a real YAML Pro Tip. All 3 of the scalar styles above (plain, single, double) let you split strings on a single space character (just like in HTML). The newline character is parsed as a space. Let's see how to use this to good effect.

[ActiveState](http://www.activestate.com/)'s Stackato product uses a simple YAML file to tell a PaaS cluster what a given application needs to run successfully. Let's look at a sample `stackato.yml` [file](https://github.com/Stackato-Apps/drupal-pressflow/blob/35e474b53d19fb52c50be6533692477b8352938d/stackato.yml).

Here's an abbreviated version:

    name: drupal-pressflow
    framework: php
    mem: 256M
    services:
        ${name}-db: mysql
        ${name}-fs: filesystem
    hooks:
        post-staging:
            # First we get drush and put it in the app root (more secure).
            - curl -sfS http://ftp.drupal.org/files/projects/drush-7.x-5.1.tar.gz | tar xzf -
            # This does the full install.
            - "- $STACKATO_APP_ROOT/drush/drush -r $HOME site-install -y --db-url=$DATABASE_URL --account-name=admin --account-pass=passwd --site-name=Stackato --locale=en-US"

Here we see the over-indenting and some ugly long lines. Let's make it shiny:

    name: drupal-pressflow
    framework: php
    mem: 256M
    services:
      ${name}-db: mysql
      ${name}-fs: filesystem
    hooks:
      post-staging:
      # First we get drush and put it in the app root (more secure).
      - curl -sfS http://ftp.drupal.org/files/projects/drush-7.x-5.1.tar.gz |
        tar xzf -
      # This does the full install.
      - "- $STACKATO_APP_ROOT/drush/drush
           -r $HOME site-install -y
           --db-url=$DATABASE_URL
           --account-name=admin
           --account-pass=passwd
           --site-name=Stackato
           --locale=en-US"

This YAML loads exactly the same, but look at the difference in readability! This is the case where humans can format YAML better than computers.

## Beyond Configuration

If you just do these things, YAML will be 90% better world wide! I'll leave you with a few more fun things that you might not know about YAML. Without full explanation, try to grok the following YAML document. If you are not sure what's going on, write a little script in your language of choice to load it as YAML and dump it as JSON.

    Single line sequence-in-sequence:
      good:
      - - - foo
        - bar
      bad:
        -
          -
            - foo
          - bar
    Any YAML can be a YAML string, by using literal style:
      this: |
        foo:
          bar: baz
      is the same as: "foo:\n  bar: baz\n"
    Quote escaping:
      double: " backslash \"escaping\" for double quotes "
      single: ' two chars ''escaping'' for single quotes '
    Flow style for small lists or dicts:
      colors: [red, white, blue]  # Like JSON without all the double quotes
      fred: {sex: male, age: 42}
    Looks like confused JSON:
      set notation: {foo, bar, baz}
      ordered map: [ one: 1, two: 2, three: 3]
    Sets as map keys:   # Dice rolls.
      [1, 6]: 3
      [3, 4]: 5

Finally, remember that YAML (1.2) is a complete superset of JSON. That means that a proper YAML loader should be able to load any JSON correctly. This is interesting, because YAML was invented 4 years before JSON. It just happened that JSON only had a 3 or 4 edge cases that were not valid YAML 1.1, so we made a few tiny adjustments to "fix" this in YAML 1.2.

I hope you found this this information interesting and useful. Help out the cause by spreading the word. Stop by `#yaml` or `#stackato` on irc.freenode.net if you have questions or just want to chat.

# Author

Ingy döt Net helped create YAML with Clark Evans and Oren Ben-Kiki. He also helped ActiveState create Stackato. He is working on next generation YAML tools, and an upcoming short book on YAML.

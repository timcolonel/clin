# Clin
[![Gem](https://img.shields.io/gem/v/clin.svg?style=flat-square)](http://rubygems.org/gems/clin)
[![Build Status](https://travis-ci.org/timcolonel/clin.svg?branch=master&style=flat-square)](https://travis-ci.org/timcolonel/clin)
[![Test Coverage](https://codeclimate.com/github/timcolonel/clin/badges/coverage.svg?style=flat-square)](https://codeclimate.com/github/timcolonel/clin/coverage)
[![Code Climate](https://codeclimate.com/github/timcolonel/clin/badges/gpa.svg?style=flat-square)](https://codeclimate.com/github/timcolonel/clin)
[![Inline docs](http://inch-ci.org/github/timcolonel/clin.svg?branch=master&style=flat-square)](http://inch-ci.org/github/timcolonel/clin)

Clin is Command Line Interface library that provide an clean api for complex command configuration.
The way Clin is design allow a command defined by the user to be called via the command line as well as directly in the code without any additional configuration
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clin

Then add the following in you ruby script.
```ruby
require 'clin'
```
## Usage

The [examples](examples/) folder contains various use case of Clin.

### Define a command
To define a command you must create a new class that inherit `Clin::Command`:

```ruby
class DisplayCommand < Clin::Command
  def run
     
  end
end
```

#### Specify arguments
To specify what argument your command takes use the `.arguments` method.
Clin will then automatically extract the arguments when parsing and pass them when creating the object.
You can after access the arguments with @params
```ruby
class DisplayCommand < Clin::Command
  arguments 'display <message>'
  
  def run
    puts "Display message: #{params[:message}"
  end
end
```

Then calling `DisplayCommand.parse('display "Hello World!"').run` will print `Display message: Hello World!`

#### Specify options
You can also specify options using the `.option` method.
```ruby
class DisplayCommand < Clin::Command
  arguments 'display <message>'
  option :times, 'Display the message n times'
  
  def run
    params[:times] ||= 1
    params[:times].times.each do 
        puts "Display message: #{params[:message}"
    end
  end
end
```

### Dispatch to the right command
For complex command line interface you might need several different commands(e.g. git add, git commit,etc.)
Define each command as shown previously then use the CommandDispatcher to choose the right command.
By default the dispatcher is going to try all the loaded commands(All subclasses of Clin::Commands)
but it can be filter.
```ruby
# Suppose Git::Add and Git::Commit are Clin::Command.
Clin::CommandDispatcher.parse('commit -m "initial commit") #=> Git::Commit<params: {message: "initial commit"}>
```

To limit filter the usage:
```ruby
# Suppose Git::Add, Git::Commit, Git::Push are Clin::Command.
dispatcher = Clin::CommandDispatcher.new(Git::Commit, Git::Push)
dispatcher.parse('commit add -A") #=> Will show the help as no command match.
dispatcher.parse('commit -m "initial commit") #=> Git::Commit<params: {message: "initial commit"}>
```
## Contributing

1. Fork it ( https://github.com/timcolonel/clin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

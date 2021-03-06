# SimpleAcl [![Gem Version](https://badge.fury.io/rb/simple_acl.png)](http://badge.fury.io/rb/simple_acl) [![Build Status](https://travis-ci.org/ifeelgoods/simple_acl.png?branch=master)](https://travis-ci.org/ifeelgoods/simple_acl) [![Coverage Status](https://coveralls.io/repos/ifeelgoods/simple_acl/badge.png?branch=master)](https://coveralls.io/r/ifeelgoods/simple_acl?branch=master) [![Code Climate](https://codeclimate.com/github/ifeelgoods/simple_acl.png)](https://codeclimate.com/github/ifeelgoods/simple_acl)

This gem eases the implementation of ACL in Ruby (especially Rails).

You should be able to use it everywhere you can execute the `do_acl` method before any protected methods.

All access are refused is the only default rule.

## Use case

For example, you're building a powerful API with multiple models behind one RESTful controller.

In this case the ressource accessed is not the model but the controller. That's why ACL should be defined at 
controller level in this case.

SimpleAcl's goal is to be a perfect tool to perform ACL at this level.

## Installation

Add this line to your application's Gemfile:

    gem 'simple_acl'

And then execute:

    $ bundle install

## Usage with Ruby on Rails

Include the main module in your controller:

`include SimpleAcl`

SimpleAcl need 3 variables:
- the action : by default `params[:action]` if available, nil otherwise
- the role : by default `current_role` if available, nil otherwise
- optional values for custom assertion : by default `params` if available, nil otherwise

You can manually define these by using following instance methods:
* `acl_current_role=`
* `acl_action=`
* `acl_values=`

Use the following before_filter to check ACL before the
execution of the code in the action.

```ruby
  before_filter :do_acl
```

When the access is refused to a given role, an `ExceptionUnauthorized`
exception will be raised.
Catch it to render/do whatever you want in this case (example with Rails):

```ruby
rescue_from ExceptionUnauthorized do
  # render 403
end
```

### Define yours ACL

To configure the ability of a role you can use:

* `acl_user`
* `acl_admin`
* `acl_guest`

Or the basic method `acl_role` with which you need to specify the role.

The key `privileges` must be a hash of assertions.
The key `filters` must be a hash of params filters
The key `inherit` must be the symbol of previous defined role.

Example:

```ruby
  acl_user privileges: {
      index: true,
      show: true,
      show_from_adserver_affiliate_id: true
  }

  acl_admin inherit: :user
```

```ruby
    acl_role(:guest,
              privileges: {
                show: true
              }
    )
```

### Define assertions in your ACL

An assertion has to return `TrueClass` or `FalseClass`.
(other values will have same effect than a `FalseClass`)

You can also use lambda to write advanced assertion.
You can use the variable `values` to the lambda.

Example:

```ruby
  acl_guest privileges: {
      show: lambda{|values| YourModel.find(values[:id]).guest_access?}
  }

```

If you have values containing `params` and your user model `current_user`

```ruby
  acl_user privileges: {
      update: lambda{|values| values[:current_user].profile_id == values[:params][:id]}
  }

```

### Define filters for your roles

A filter is a list of allowed tokens for a given parameter. It assume the parameter is a comma delimited string.
A typical use case for this feature is to accept a prameter that provide a list of options. You want to control which options are available for each role.

Example

```ruby
  acl_user privileges: { show: true },
           filters: { features: [ 'opt1', 'opt2', 'opt3'] }

```

The filter above will parse the parameter 'features' and remove all token that are not one of the following `opt1`,`opt2`,`opt3`

a role can inherit filters from its parent. You can overide an inherited filter by redefining it. You can take advantage of the special value below.

* `:all` : Accept any value. It allow to remove an inherited filter
* `:none` : Reject any value

Example

```ruby

  acl_user privileges: { show: true },
           filters: { features: [ 'opt1', 'opt2', 'opt3'] }

  acl_guest inherit: :user, filters: { features: :none }

  acl_admin inherit: :user, filters: { features: :all }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Inspired from `racl-rails` and `racl`.
https://github.com/ifeelgoods/racl/
https://github.com/ifeelgoods/racl-rails/


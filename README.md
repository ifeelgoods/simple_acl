# SimpleAcl

This gem eases the implementation of ACL in Ruby (especially Rails).

All access are refused is only rule by default.

## Installation

Add this line to your application's Gemfile:

    gem 'simple_acl'

And then execute:

    $ bundle install

## Usage

You need to include the main module:

`include SimpleAcl`

SimpleAcl need 3 variables:
- the action : by default use `params[:action]` if available, nil otherwise
- the role : by default use method `current_role` if available, nil otherwise
- optional values for custom assertion : by default use `params` if available, nil otherwise

You can manually define these by using following methods in the controller:
`acl_current_role=` `acl_action=` `acl_values=`

Use the following before_filter to check ACL before the
execution of the code in the action.

```ruby
  before_filter :do_acl
```

## Configuration

To configure the ability of a role you can use:

`acl_user, acl_admin, acl_guest`

or the basic method `acl_role` with which you need to specify the role.

The key `privileges` must be a hash of assertions.
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
    acl_role(:guest, show: true)
```

If the role trying to access to the resource is not allowed a ExceptionUnauthorized
exception will be raised.
Catch it to render/do whatever you want in this case:

```ruby
rescue_from ExceptionUnauthorized do
  # render 403
end
```

In an initializers, you can specify the role you want to use.
(defaults are :admin, :user, :guest)

```
SimpleAcl::Configuration.authorized_roles = [:admin, :user]

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Inspired from `racl-rails` and `racl`
https://github.com/ifeelgoods/racl/
https://github.com/ifeelgoods/racl-rails/
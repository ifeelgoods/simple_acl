## SimpleAcl 1.0.2 ##

* remove the need to specify roles used with `SimpleAcl::Configuration.authorized_roles=`

* remove current_role from parameters passed in
the lambda, as it is useless

## SimpleAcl 1.0.1 ##

* Fix possibility to define a custom action with `acl_action=`

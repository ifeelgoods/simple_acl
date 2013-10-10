require 'simple_acl/acl'
require 'simple_acl/exceptions'

module SimpleAcl
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def acl
      @acl ||= Acl.new
    end

    def acl_user(privileges)
      role_acl(:user, privileges)
    end

    def acl_admin(privileges)
      role_acl(:admin, privileges)
    end

    def acl_guest(privileges)
      role_acl(:guest, privileges)
    end

    def role_acl(role, privileges)
      acl.configuration.add_role(role, privileges)
    end

  end

  # @param values used for custom lambda assertion
  def acl_values=(values)
    Thread.current[:acl_values] = values
  end

  def acl_values
    Thread.current[:acl_values] ||= defined?(params) ? params : nil
  end

  # @param current_role used for the assertion
  def acl_current_role=(current_role)
    Thread.current[:acl_current_role] = current_role
  end

  def acl_current_role
    Thread.current[:acl_current_role] ||= defined?(current_role) ? current_role : nil
  end

  # @param action used for the assertion
  def acl_action=(action)
    Thread.current[:acl_action] = action
  end

  def acl_action
    Thread.current[:acl_action] ||= (defined?(params) && params.is_a?(Hash)) ? params[:action] : nil
  end

  # @return True is success, raise ExceptionUnauthorized otherwise
  def do_acl
    return Acl.unauthorized unless self.class.acl

    begin
      self.class.acl.check_acl(acl_current_role, acl_action, acl_values)
    ensure
      # in case of Thread,current is not cleaned
      Thread.current[:acl_action] = nil
      Thread.current[:acl_current_role] = nil
      Thread.current[:acl_values] = nil
    end
  end
end
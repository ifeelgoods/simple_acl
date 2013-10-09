require 'simple_acl/configuration'

module SimpleAcl
  class Acl

    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
    end

    def check_acl(current_role, action, values)

      return self.class.unauthorized unless configuration && current_role

      role_privileges = configuration.acl_privileges[current_role.to_sym]

      return self.class.unauthorized unless role_privileges

      assertion = role_privileges[action.to_sym]

      self.class.assert(assertion, current_role, values)
    end

    def self.assert(assertion, current_role, values)

      return authorized if assertion.class == TrueClass

      if assertion.class == Proc && assertion.lambda?
        assertion_result = assertion.call(current_role, values)
        return assert(assertion_result, current_role, values)
      end

      unauthorized
    end

    def self.unauthorized
      raise ExceptionUnauthorized
    end

    def self.authorized
      true
    end

  end
end

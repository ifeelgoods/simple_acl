require 'simple_acl/configuration'

module SimpleAcl
  class Acl

    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
    end

    def get_acl(action)
      configuration.acl_privileges.keys.select{|k| configuration.acl_privileges[k][action] }
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
        assertion_result = assertion.call(values)
        return assert(assertion_result, current_role, values)
      end

      unauthorized
    end

    def filter_params(role, params)
      filters = configuration.acl_filters[role.to_sym] || {}
      filters.each do |key,value|
        if params.has_key?(key)
          params[key] = filter(params[key], value)
        end
      end
    end

    def self.unauthorized
      raise ExceptionUnauthorized
    end

    def self.authorized
      true
    end

    private

    def filter(values, accepted_values)
      if accepted_values == :all
        values
      elsif accepted_values == :none
        ''
      elsif values == 'all'
        accepted_values.join(',')
      else
        (values.split(',') & accepted_values).join(',')
      end
    end

  end
end

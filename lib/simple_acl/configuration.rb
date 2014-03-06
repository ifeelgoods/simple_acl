module SimpleAcl
  class Configuration

    attr_reader :acl_privileges
    attr_reader :acl_filters

    def initialize
      @acl_privileges = {}
      @acl_filters = {}
    end

    def add_role(role, privileges)
      check_keys(privileges)

      @acl_privileges[role] = (@acl_privileges[privileges[:inherit]] || {}).merge(privileges[:privileges] || {})
      acl_filters[role] = (acl_filters[privileges[:inherit]] || {}).merge(privileges[:filters] || {})

      check_set_up(@acl_privileges[role])

      deep_freeze!(@acl_privileges[role])
    end

    private

    # check defined keys in privileges
    def check_keys(privileges)
      privileges.keys.each do |configuration_key|
        raise ExceptionConfiguration, "Unknow configuration key #{configuration_key}" unless [:privileges, :inherit, :filters].include?(configuration_key)
      end
      raise ExceptionConfiguration, 'Inherit specified is not defined previously' if privileges[:inherit] && !@acl_privileges[privileges[:inherit]]
    end

    # check of the set up
    def check_set_up(privileges)
      privileges.keys.each{|action| check_assertion(privileges[action]) }
    end

    def check_assertion(assertion)
      return if assertion.class == Proc && assertion.lambda?
      raise ExceptionConfiguration, "Not usable assertion type : #{assertion.class}" unless [TrueClass, FalseClass].include?(assertion.class)
    end

    # do a recursive freeze on Array and Hash
    def deep_freeze!(option)
      option.freeze

      case option.class
        when Hash
          option.each{|k, v| deep_freeze(option[k]) }
        when Array
          option.each{|v| deep_freeze(v) }
        else
      end
    end

  end
end

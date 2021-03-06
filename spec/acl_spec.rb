require 'spec_helper'

describe SimpleAcl::Acl do
  let(:role_1) {
    {privileges: {create: true}}
  }
  let(:role_2) {
    {privileges: {create: false}}
  }
  let(:role_4) {
    {inherit: :role_1}
  }
  let(:acl_base_instance) { SimpleAcl::Acl.new }

  describe "#check_acl" do
    subject { acl.check_acl(current_role, action, values) }

    context "role_1 has create privileges, role_2 has not create priviliges, role_3 has no acl configuration" do
      let(:acl) {
        acl_base_instance.configuration.add_role(:role_1, role_1)
        acl_base_instance.configuration.add_role(:role_2, role_2)
        acl_base_instance.configuration.add_role(:role_4, role_4)
        acl_base_instance
      }
      let(:action) { :create }
      let(:values) { 'dummy' }

      context "with role1" do
        let(:current_role) { :role_1 }

        it "role_1 can create" do
          expect(subject).to be_true
        end
      end

      context "with role4" do
        let(:current_role) { :role_4 }

        it "role_4 can create" do
          expect(subject).to be_true
        end
      end

      context "with role2" do
        let(:current_role) { :role_2 }

        it "role_2 cannot create" do
          expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context "with role3" do
        let(:current_role) { :role_3 }

        it "role_3 cannot create" do
          expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end
    end

    context "role_1 has a custom assertion on create, role_2 has not create priviliges, role_3 has no acl configuration" do
      let(:acl) {
        acl_base_instance.configuration.add_role(:role_1,
                                                 {privileges:
                                                    {
                                                      create: lambda { |values| values[:id] == 99 }
                                                    }
                                                 }
        )
        acl_base_instance.configuration.add_role(:role_2, role_2)
        acl_base_instance.configuration.add_role(:role_4, role_4)
        acl_base_instance
      }
      let(:action) { :create }
      let(:values) { {id: 99} }

      context "with value id == 99" do

        context "with role1" do
          let(:current_role) { :role_1 }

          it "role_1 can create" do
            expect(subject).to be_true
          end
        end

        context "with role4" do
          let(:current_role) { :role_4 }

          it "role_4 can create" do
            expect(subject).to be_true
          end
        end

        context "with role2" do
          let(:current_role) { :role_2 }

          it "role_2 cannot create" do
            expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end

        context "with role3" do
          let(:current_role) { :role_3 }

          it "role_3 cannot create" do
            expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end
      end

      context "with value id != 99" do

        context "with role1" do
          let(:current_role) { :role_1 }

          it "role_1 can create" do
            expect(subject).to be_true
          end
        end

        context "with role4" do
          let(:current_role) { :role_4 }

          it "role_4 can create" do
            expect(subject).to be_true
          end
        end

        context "with role2" do
          let(:current_role) { :role_2 }

          it "role_2 cannot create" do
            expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end

        context "with role3" do
          let(:current_role) { :role_5 }

          it "role_3 cannot create" do
            expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
          end
        end
      end
    end

  end

  describe "#assert" do
    subject { SimpleAcl::Acl.assert(assertion, current_role, values) }

    context "assertion is true" do
      let(:assertion) { true }
      let(:current_role) { 'dummy' }
      let(:values) { 'dummy' }

      it "return true" do
        expect(subject).to be_true
      end
    end

    context "assertion is false" do
      let(:assertion) { false }
      let(:current_role) { 'dummy' }
      let(:values) { 'dummy' }

      it "return false" do
        expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
      end
    end

    context "assertion is nil" do
      let(:assertion) { nil }
      let(:current_role) { 'dummy' }
      let(:values) { 'dummy' }

      it "return false" do
        expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
      end
    end

    context "assertion is dummy" do
      let(:assertion) { 'dummy' }
      let(:current_role) { 'dummy' }
      let(:values) { 'dummy' }

      it "return false" do
        expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
      end
    end

    context "assertion is a Proc but not lambda" do
      let(:assertion) {
        Proc.new { return true }
      }
      let(:current_role) { 'dummy' }
      let(:values) { 'dummy' }

      it "return false" do
        expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
      end
    end

    context "assertion is a lambda true" do
      let(:assertion) {
        lambda { |values| true }
      }
      let(:current_role) { 'dummy' }
      let(:values) { 'dummy' }

      it "return true" do
        expect(subject).to be_true
      end
    end

    context "assertion is a lambda using current_role and values" do
      let(:assertion) {
        lambda { |values| values[:id] != 5 }
      }
      let(:current_role) { 'dummy' }

      context "with right value" do
        let(:values) { {id: 10} }

        it "return true" do
          expect(subject).to be_true
        end
      end
      context "with wrong value" do
        let(:values) { {id: 5} }

        it "return false" do
          expect { subject }.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end
    end
  end

  describe "#filter_params" do

    context "when a filter list is defined" do
      let(:acl) do
        acl_base_instance.configuration.add_role(:role_1, filters: {expand: ['option1', 'option2']})
        acl_base_instance
      end
      it "keep specified expand" do
        params = { expand: 'option1' }
        acl.filter_params(:role_1, params)
        expect(params).to eq({expand: 'option1'})
      end
      it "remove other expand" do
        params = { expand: 'unknow,option1'}
        acl.filter_params(:role_1, params)
        expect(params).to eq({expand: 'option1'})
      end
      it "keep all expand" do
        params = { expand: 'all' }
        acl.filter_params(:role_1, params)
        expect(params).to eq({expand: 'option1,option2'})
      end
      it "works when the expected param is missing" do
        params = { action: 'index' }
        acl.filter_params(:role_1, params)
        expect(params).to eq({action:  'index'})
      end
    end

    context "when a filter list is no defined" do
      let(:acl) do
        acl_base_instance.configuration.add_role(:role_1, privileges: { index: true})
        acl_base_instance
      end
      it "does not filter parameters" do
        params = { expand: 'param1,param2'}
        acl.filter_params(:role_1, params)
        expect(params).to eq({expand: 'param1,param2'})
      end
    end

    context "inheriting from another role" do
      let(:acl) do
        acl_base_instance.configuration.add_role(:role_1, filters: {expand: ['option1', 'option2']})
        acl_base_instance.configuration.add_role(:role_2, inherit: :role_1)
        acl_base_instance
      end

      it "inherit filters" do
        params = { expand: 'unknow,option1'}
        acl.filter_params(:role_2, params)
        expect(params).to eq({expand: 'option1'})
      end
    end

    context "keep all values" do
      let(:acl) do
        acl_base_instance.configuration.add_role(:role_1, filters: {expand: ['option1', 'option2']})
        acl_base_instance.configuration.add_role(:role_2, inherit: :role_1, filters: {expand: :all})
        acl_base_instance
      end

      it "keep all values" do
        params = { expand: 'param1,param2'}
        acl.filter_params(:role_2, params)
        expect(params).to eq({expand: 'param1,param2'})
      end
    end

    context "rejecting all values" do
      let(:acl) do
        acl_base_instance.configuration.add_role(:role_1, filters: {expand: :none})
        acl_base_instance
      end

      it "reject all values" do
        params = { expand: 'param1,param2,none'}
        acl.filter_params(:role_1, params)
        expect(params).to eq({expand: ''})
      end
    end
  end

end

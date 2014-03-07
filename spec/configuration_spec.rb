require 'spec_helper'

describe SimpleAcl::Configuration do

  let(:configuration) { SimpleAcl::Configuration.new }

  describe "#add_role" do

    context "when the role does not exists" do
      it "should set acl privileges" do
        configuration.add_role(:role_1, privileges: { create: true})
        expect(configuration.acl_privileges[:role_1][:create]).to be_true
      end
      it "should set filters params" do
        configuration.add_role(:role_1, filters: { expand: ['option1'] })
        expect(configuration.acl_filters[:role_1][:expand]).to eq(['option1'])
      end
    end

    context "when the role exist" do
      before do
        configuration.add_role(:role_1, privileges: { create: true}, filters: { extras: [ 'option1']})
      end
      it "should override the acl privileges" do
        configuration.add_role(:role_1, privileges: { index: true} )
        expect(configuration.acl_privileges[:role_1]).to eq(index: true)
        expect(configuration.acl_filters[:role_1]).to eq({})
      end
      it "should override the acl filters" do
        configuration.add_role(:role_1, filters: { expand: ['option2']} )
        expect(configuration.acl_filters[:role_1]).to eq({ expand: ['option2']})
        expect(configuration.acl_privileges[:role_1]).to eq({})
      end
    end

    context "inherit from an existing role" do
      before do
        configuration.add_role(:role_1, privileges: { create: true, update: true}, filters: { extras: [ 'option1']})
      end

      it "inherit undefined acl" do
        configuration.add_role(:role_2, inherit: :role_1, privileges: { index: true} )
        expect(configuration.acl_privileges[:role_2]).to eq(index: true, create: true, update: true)
      end
      it "override existing acl" do
        configuration.add_role(:role_2, inherit: :role_1, privileges: { create: false } )
        expect(configuration.acl_privileges[:role_2]).to eq(create: false, update: true)
      end
      it "inherit undefined filter" do
        configuration.add_role(:role_2, inherit: :role_1, filters: { expand: ['option2'] } )
        expect(configuration.acl_filters[:role_2]).to eq(extras: ['option1'], expand: ['option2'])
      end
      it "override existing filter" do
        configuration.add_role(:role_2, inherit: :role_1, filters: { extras: ['option2'] } )
        expect(configuration.acl_filters[:role_2]).to eq(extras: ['option2'])
      end
    end

    context "inherit from an non existing role" do
     it "raise a configuration error" do
       expect do
        configuration.add_role(:role_2, inherit: :unknow_role, privileges: { index: true} )
       end.to raise_exception(SimpleAcl::ExceptionConfiguration)
     end
    end

    context "with a bad key confguration" do
      it "raise a configuration error" do
       expect do
        configuration.add_role(:role_1, bad_key: true )
       end.to raise_exception(SimpleAcl::ExceptionConfiguration)
      end
    end
  end
end

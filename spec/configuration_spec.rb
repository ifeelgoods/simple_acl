require 'spec_helper'

describe SimpleAcl::Configuration do

  let(:configuration_base) { SimpleAcl::Configuration.new }

  describe "add_role" do
    let(:privileges) {
      {privileges: {create: true}}
    }
    subject { configuration_base.add_role(:role_1, privileges) }

    context "is not in the authorized list" do
      before do
        SimpleAcl::Configuration.authorized_roles = []
      end
      it "raise an ExceptionConfiguration" do
        expect { subject }.to raise_error(SimpleAcl::ExceptionConfiguration)
      end
    end

    context "is authorized" do
      before do
        SimpleAcl::Configuration.authorized_roles += [:role_1]
      end

      it "succeed" do
        expect { subject }.to_not raise_exception
      end
    end

    context "unknow key configuration" do
      let(:privileges) {
        {badkey: {create: true}}
      }
      it "raise an ExceptionConfiguration" do
        expect { subject }.to raise_error(SimpleAcl::ExceptionConfiguration)
      end
    end

    describe 'using inherited configuration' do
      before(:all) do
        SimpleAcl::Configuration.authorized_roles += [:role_2]
      end

      before do
        @configuration = configuration_base
        @configuration.add_role(:role_1, privileges)
      end

      subject {
        @configuration.add_role(:role_2, {inherit: :role_1, privileges: {update: false}})
      }
      context 'with existing previous role' do
        let(:privileges) {
          {privileges: {create: true, update: true}}
        }

        it 'should succeed' do
          expect { subject }.to_not raise_exception
        end

        it 'role_2 should contain config of role_1' do
          subject
          expect(@configuration.acl_privileges[:role_2][:create]).to eq(@configuration.acl_privileges[:role_1][:create])
        end

        it 'role_2 should override inherited config' do
          subject
          expect(@configuration.acl_privileges[:role_2][:update]).to_not eq(@configuration.acl_privileges[:role_1][:create])
          expect(@configuration.acl_privileges[:role_2][:update]).to eq(false)
        end
      end

      context 'with unknown previous role' do
        subject {
          @configuration.add_role(:role_2, {inherit: :role_4, privileges: {update: false}})
        }

        it 'should raise an exception' do
          expect { subject }.to raise_error(SimpleAcl::ExceptionConfiguration)
        end
      end
    end
  end
end
require 'spec_helper'

describe SimpleAcl do

  before(:all) do
    SimpleAcl::Configuration.authorized_roles = [:user, :guest, :admin]
    class WhatEver < Struct.new(:params, :current_role)
      include SimpleAcl
    end
  end

  describe 'do_acl' do
    before do
      WhatEver.acl_user(privileges: {create: true})
      WhatEver.acl_admin({privileges: {update: true}, inherit: :user})
      @whatEver = WhatEver.new(params, current_role)
    end

    subject{@whatEver.do_acl}

    context 'access to create ressource' do
      let(:params){{action: :create}}

      context 'with guest' do
        let(:current_role){:guest}

        it 'refuse access' do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context 'with user' do
        let(:current_role){:user}

        it 'allow access' do
          expect(subject).to be_true
        end
      end

      context 'with admin' do
        let(:current_role){:admin}

        it 'allow access' do
          expect(subject).to be_true
        end
      end
    end

    context 'access to update ressource' do
      let(:params){{action: :update}}

      context 'with guest' do
        let(:current_role){:guest}

        it 'refuse access' do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context 'with user' do
        let(:current_role){:user}

        it 'refuse access' do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context 'with admin' do
        let(:current_role){:admin}

        it 'allow access' do
          expect(subject).to be_true
        end
      end
    end
  end


end
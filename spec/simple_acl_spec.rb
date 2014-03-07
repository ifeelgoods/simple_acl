require 'spec_helper'

describe SimpleAcl do

  before(:all) do
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


    context 'with an action and role defined manually and without params' do
      before(:all) do
        class WhatEver2
          include SimpleAcl
        end

        WhatEver.acl_user(privileges: {create: true})
        WhatEver.acl_admin({privileges: {update: true}, inherit: :user})

        @whatEver = WhatEver.new
      end

      before do
        @whatEver.acl_action = :update
      end

      subject{@whatEver.do_acl}

      context 'with guest' do
        before do
          @whatEver.acl_current_role = :guest
        end

        it 'refuse access' do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context 'with user' do
        before do
          @whatEver.acl_current_role = :user
        end

        it 'refuse access' do
          expect{subject}.to raise_error(SimpleAcl::ExceptionUnauthorized)
        end
      end

      context 'with admin' do
        before do
          @whatEver.acl_current_role = :admin
        end

        it 'allow access' do
          expect(subject).to be_true
        end
    end
  end

  describe "#expand filtering" do
    before do
      WhatEver.acl_user(privileges: {show: true}, filters: {expand: ['option1', 'option2']})
      WhatEver.acl_admin(inherit: :user)
      @whatEver = WhatEver.new(params, current_role)
    end

    subject{@whatEver.do_acl}

    context "with filters defined on current role" do
      let(:current_role) { :user }
      let(:params) {{ action: :show, expand: 'option1,other'}}
      it "keep only allowed expand" do
        subject
        expect(params[:expand]).to eq('option1')
      end
    end

    context "with filters defined on inherited role" do
      let(:current_role) { :admin }
      let(:params) {{ action: :show, expand: 'option1,other'}}
      it "inherit allowed expand" do
        subject
        expect(params[:expand]).to eq('option1')
      end
    end

  end

end

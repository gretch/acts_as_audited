require 'spec_helper'

class AuditsController < ActionController::Base
  def audit
    @company = Company.create
    render :nothing => true
  end

  def update_user
    current_user.update_attributes( :password => 'foo')
    render :nothing => true
  end

  private

  attr_accessor :current_user
  attr_accessor :custom_user
end

describe AuditsController do
  include RSpec::Rails::ControllerExampleGroup

  before(:each) do
    AuditSweeper.current_user_method = :current_user
  end

  let( :user ) { create_user }

  describe "POST audit" do

    it "should audit user" do
      controller.send(:current_user=, user)

      expect {
        post :audit
      }.to change( Audit, :count )

      assigns(:company).audits.last.user.should == user
    end

    it "should support custom users for sweepers" do
      controller.send(:custom_user=, user)
      AuditSweeper.current_user_method = :custom_user

      expect {
        post :audit
      }.to change( Audit, :count )

      assigns(:company).audits.last.user.should == user
    end
  end

  describe "POST update_user" do

    it "should not save blank audits" do
      controller.send(:current_user=, user)

      expect {
        post :update_user
      }.to_not change( Audit, :count )
    end
  end
end

require 'vmc'
require "harness/user_helper"

module BVT::Harness
  class User
    include BVT::Harness::UserHelper

    attr_reader :client, :log, :namespace, :target

    def initialize(expect_admin = false, user_email = nil, passwd = nil)
      get_test_property
      @user = user_email ? user_email : get_user_email(expect_admin)
      @passwd = passwd ? passwd : get_user_passwd(expect_admin)
      @target = "http://api.#{get_target}"

      @log = get_logger(LOGGER_LEVEL)
      @namespace = get_namespace
      login
      check_privilege(expect_admin)
    end

    def delete_user(user_email)
      @log.debug "delete_user: Admin User = #{@user}, delete user = #{user_email}"
      response = @client.delete_user(user_email)
      raise RuntimeError,
            "Failed to delete user, return code should be 204, get response = #{response}" if response.first != 204
    end

    def create_user(user_email, passwd)
      @log.debug "add_user: Admin User = #{@user}, create user = #{user_email}"
      response = @client.add_user(user_email, passwd)
      raise RuntimeError,
            "Failed to add user, return code should be 204, get response = #{response}" if response.first != 204
    end

    def list_users
      @log.debug "list_users: Admin User = #{@user}"
      response = @client.users
      raise RuntimeError, "Failed to list users, response should not be nil" if response.nil?
      response
    end

    def change_passwd(new_passwd)
      @log.debug "change_passwd: User = #{@user}, Old passwd = #{@passwd}, new passwd = #{new_passwd}"
      response = @client.change_password(new_passwd)
      raise RuntimeError,
            "Fail to change passsword for user = #{@user}, response should not be nil" if response.nil?
      @passwd = new_passwd
    end

    def login
      @log.debug "Login in, target: #{@target}, user = #{@user}, psswd = #{@passwd}"
      @client = VMC::Client.new(@target)
      begin
        @client.login(@user, @passwd)
      rescue
        @log.error "Fail to login in, target: #{@target}, user = #{@user}, psswd = #{@passwd}"
        raise "Cannot login target environment.
Target = '#{@target}'
Test User = '#{@user}'
Test Pwd = '#{@passwd}'"
      end
      # TBD - ABS: This is a hack around the 1 sec granularity of our token time stamp
      sleep(1)
    end

    def logout
      pending '#TODO: Implement logout method'
    end

    private
    def admin?
      begin
        # Make sure that RuntimeError 'Operation not permitted' is caught for the non-admin user
        # when running the vmc 'users' command
        @client.users
        @is_admin = true
      rescue RuntimeError => e
        @is_admin = false
      end
      @is_admin
    end

    def check_privilege(expect_admin = false)
      expect_privilege = expect_admin ? "admin user" : "normal user"
      actual_privilege = admin? ? "admin user" : "normal user"

      if actual_privilege == expect_privilege
        @log.debug "run bvt as #{expect_privilege}"
      else
        raise RuntimeError, "user type does not match.
Expected User Privilege: #{expect_privilege}
Actual User Privilege: #{actual_privilege}"
      end
    end
  end
end


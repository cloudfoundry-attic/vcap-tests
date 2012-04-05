require "cfoundry"

module BVT::Harness
  class User
    attr_reader :email, :passwd

    def initialize(user, client)
      @user = user
      @email = @user.email
      @client = client
      @log = @client.log
    end

    def inspect
      "#<BVT::Harness::User '#@email'>"
    end

    def create(passwd)
      @log.info("Create User: #{@email} via Admin User: #{@client.email}")
      begin
        @client.register(@email, passwd)
        @passwd = passwd
      rescue
        @log.error("Failed to create user: #{@email}")
        raise RuntimeError, "Failed to create user: #{@email}"
      end
    end

    def delete
      @log.info("Delete User: #{@email} via Admin User:#{@client.email}")
      begin
        @user.delete!
      rescue Exception => e
        @log.error("Failed to delete user")
        raise RuntimeError, "Failed to delete user.\n#{e.to_s}"
      end
    end

    def change_passwd(new_passwd)
      @log.info "Change User: #{@email} password, new passwd = #{new_passwd}"
      begin
        @user.password = new_passwd
        @user.update!
      rescue
        @log.error("Fail to change password for user: #{@email}")
        raise RuntimeError,
              "Fail to change passsword for user = #{@email}"
      end
    end
  end
end


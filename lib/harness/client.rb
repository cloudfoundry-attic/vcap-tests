require "cfoundry"
require "vcap/logging"

module BVT::Harness
  class Client
    attr_reader :log, :namespace, :target, :email

    def initialize(expect_admin = false, email = nil, passwd = nil)
      get_test_property
      @email = email ? email : get_login_email(expect_admin)
      @passwd = passwd ? passwd : get_login_passwd(expect_admin)
      @target = "http://api.#{get_target}"

      @log = get_logger(LOGGER_LEVEL)
      @namespace = get_namespace
      login
      check_privilege(expect_admin)
    end

    def login
      @log.debug("Login in, target: #{@target}, email = #{@email}, pssswd = #{@passwd}")
      @client = CFoundry::Client.new(@target)
      begin
        @client.login(@email, @passwd)
      rescue
        @log.error "Fail to login in, target: #{@target}, user: #{@email}, passwd = #{@passwd}"
        raise "Cannot login target environment. target = '#{@target}', user: '#{@email}', passwd: '#{@passwd}'"
      end
      # TBD - ABS: This is a hack around the 1 sec granularity of our token time stamp
      sleep(1)
    end

    def logout
      @log.debug "logout, target: #{@target}, email = #{@email}, pssswd = #{@passwd}"
      @client = nil
    end

    def info
      @log.debug "get target info, target: #{@target}"
      @client.info
    end

    def register(email, password)
      @log.debug("Register user: #{email}")
      BVT::Harness::User.new(@client.register(email, password), self)
    end

    def system_frameworks
      @log.debug "get system frameworks, target: #{@target}"
      info = @client.info
      info["frameworks"] || {}
    end

    def system_runtimes
      @log.debug "get system runtimes, target: #{@target}"
      @client.system_runtimes
    end

    def system_services
      @log.debug "get system services, target: #{@target}"
      @client.system_services
    end

    def app(name)
      BVT::Harness::App.new(@client.app(name), self)
    end

    def apps
      @client.apps.collect {|app| BVT::Harness::App.new(app, self)}
    end

    def services
      @client.services.collect {|service| BVT::Harness::Service.new(service, self)}
    end

    def service(name)
      BVT::Harness::Service.new(@client.service(name), self)
    end

    def users
      begin
        @log.debug("Get Users for target: #{@client.target}, login email: #{@email}")
        users = @client.users.collect {|user| BVT::Harness::User.new(user, self)}
      rescue Exception => e
        @log.error("Fail to list users for target: #{@client.target}, login email: #{@email}")
        raise RuntimeError, "Fail to list users for target: #{@client.target}, login email: #{@email}\n#{e.to_s}"
      end
    end

    def user(email)
      BVT::Harness::User.new(@client.user(email), self)
    end

    private

    def get_logger(level = :error)
      config = {:level => level, :file => VCAP_BVT_LOG_FILE}
      VCAP::Logging.setup_from_config(config)
      VCAP::Logging.logger(File.basename($0))
    end

    # generate random string as prefix for one test example
    def get_namespace
      "t#{rand(2**32).to_s(36)}-"
    end

    def get_login_email(expected_admin = false)
      expected_admin ? @config["admin"]["email"] : @config["user"]["email"]
    end

    def get_login_passwd(expected_admin = false)
      expected_admin ? @config["admin"]["passwd"] : @config["user"]["passwd"]
    end

    def get_target
      @config["target"]
    end

    def get_test_property
      # TODO:
      config_file = File.join(VCAP_BVT_HOME, "config.yml")
      begin
        @config = File.open(config_file) do |f|
          YAML.load(f)
        end
      rescue => e
        puts "Could not read configuration file:  #{e}"
        exit
      end
    end

    def check_privilege(expect_admin = false)
      expect_privilege = expect_admin ? "admin user" : "normal user"
      actual_privilege = admin? ? "admin user" : "normal user"

      if actual_privilege == expect_privilege
        @log.info "run bvt as #{expect_privilege}"
      else
        @log.error "user type does not match. Expected User Privilege: #{expect_privilege}" +
                       " Actual User Privilege: #{actual_privilege}"
        raise RuntimeError, "user type does not match.\nExpected User Privilege: #{expect_privilege}" +
            " Actual User Privilege: #{actual_privilege}"
      end
    end

    def admin?
      user = @client.user(@email)
      user.manifest
      user.admin?
    end
  end
end




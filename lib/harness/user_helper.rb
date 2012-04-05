require "yaml"
require "logger"

module BVT::Harness
  module UserHelper

    def get_user_email(expected_admin = false)
      expected_admin ? @config["admin"]["email"] : @config["user"]["email"]
    end

    def get_user_passwd(expected_admin = false)
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

    def get_logger(level=:error)
      log = Logger.new("#{VCAP_BVT_HOME}/bvt.log", shift_size = 10 * 1024 * 1024)
      log.level = case level
                    when :error then Logger::ERROR
                    when :info then Logger::INFO
                    when :debug then Logger::DEBUG
                    else Logger::ERROR
                  end
      log
    end

    # generate random string as prefix for one test example
    def get_namespace
      "t#{rand(2**32).to_s(36)}_"
    end
  end
end

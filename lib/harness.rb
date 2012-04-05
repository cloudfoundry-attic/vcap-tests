
module BVT
  module Harness
    VCAP_BVT_HOME = File.join(ENV['HOME'], '.bvt')
    VCAP_BVT_CONFIG_FILE = File.join(VCAP_BVT_HOME, "config.yml")
    VCAP_BVT_LOG_FILE = File.join(VCAP_BVT_HOME, "bvt.log")
    LOGGER_LEVEL = :debug
  end
end

require "harness/user_helper"
require "harness/color_helper"
require "harness/rake_helper"

require "harness/client"
require "harness/app"
require "harness/service"
require "harness/user"

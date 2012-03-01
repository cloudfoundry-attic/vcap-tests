require "set"
require "interact"
require 'vmc'

module Bvt
  class ParallelRunner
    include Interactive

    ABORT_ON_EXCEPTION = false
    CONFIG_DEFAULT_PATH = File.expand_path("~/.bvt_parallel_config.yml")
    DEFAULT_N_USERS = "10"
    DEFAULT_USER_TEMPLATE = "vcap_tester{n}@vmware.com"
    DEFAULT_USER_PASSWORD = "tester"

    class Task
      attr_accessor :scenario, :env, :start_time

      def initialize(scenario, env = {})
        @scenario = scenario
        @env = env
      end
    end

    attr_accessor :failed_tasks

    def initialize(io, log)
      @io = io
      @lock = Mutex.new
      @queue = Queue.new
      @failed_tasks = {}
      @active_tasks = Set.new
      @target = ENV["VCAP_BVT_TARGET"]
      @config_path = ENV["BVT_USERS_CONFIG"] || CONFIG_DEFAULT_PATH
      @log = log

      config_users

      Thread.new do
        loop do
          sleep(10)
          @lock.synchronize do
            @io.puts "======================================"
            @io.puts "Currently running #{@active_tasks.size} tasks"
            @active_tasks.each do |task|
              @io.puts "#{task.scenario} running for #{(Time.now - task.start_time).round} seconds"
            end
            @io.puts "======================================\n\n"
          end
        end
      end
    end

    def config_users
      get_config

      if !@config[@target]
        puts "No information about given VCAP target"
        @config.merge!(generate_config)
        save_config
      end

      users = @config[@target]["users"]
      n_users = users["count"].to_i
      puts green("Number of users: #{n_users}")
      user_template = users["template"]
      @password = users["password"].to_s

      users = []
      n_users.times do |i|
        users << user_template.sub(/\{[^\}]*\}/, (i+1).to_s)
      end

      @users = users

    end

    def generate_config
      if !ask("Do you want to register users and save config file?", :default => true)
        raise "Can't proceed without configuration"
      end

      @target = @target || ask("VCAP target")

      vcap_target = "http://api.#{@target}" unless @target =~ /^http/
      puts "Connecting to #{vcap_target}"
      client = VMC::Client.new(vcap_target)

      admin_user = ask("Admin username")
      admin_passwd = ask("Admin password", :echo => "*")

      puts "Logging as admin"
      begin
        token = client.login(admin_user, admin_passwd)
      rescue
        raise "Can't login"
      end
      # check that the user is admin
      begin
        client.users
      rescue
        raise "This user is not an admin"
      end

      n_users = ask_and_validate("Number of users you want to register " +
                                 "(suggested: 10 for dev, 20 for stagging)",
                                 "^[0-9]+$",
                                 DEFAULT_N_USERS
                                 )
      user_template = ask_and_validate("Username email template (use {n} in the username)",
                                       "{[^}]*}",
                                       DEFAULT_USER_TEMPLATE
                                       )
      passwd = ask("User password", :default => DEFAULT_USER_PASSWORD)

      # registering users
      n_users.to_i.times do |i|
        username = user_template.sub(/\{[^\}]*\}/, (i+1).to_s)
        puts "Registering user #{username}"
        client.add_user(username, passwd)
      end

      config = {}
      config[@target] = {}
      config[@target]["users"] = {}
      config[@target]["users"]["count"] = n_users.to_i
      config[@target]["users"]["template"] = user_template
      config[@target]["users"]["password"] = passwd

      config
    end

    def get_config
      if File.exists?(@config_path)
        config_file = File.expand_path(@config_path, Dir.pwd)
        puts "Using config file #{config_file}"
        @config = YAML.load_file(config_file)
        raise "Invalid config file format" unless @config.is_a?(Hash)
      else
        puts "Can't find config file at #{@config_path}"
        @config = {}
      end
    end

    def save_config
      File.open(@config_path, "w") { |f| f.write YAML.dump(@config) }
      puts "Config file written to #{@config_path}"
    end

    def ask_and_validate(question, pattern, default = nil)
      res = ask(question, :default => default)
      while res !~ /#{pattern}/
        puts "Incorrect input"
        res = ask(question, :default => default)
      end
      res
    end

    def add_task(scenario, env)
      @queue << Task.new(scenario, env)
    end

    def run_tasks
      Thread.abort_on_exception = ABORT_ON_EXCEPTION
      threads = []

      @users.each do |user|
        threads << Thread.new do
          until @queue.empty?
            task = @queue.pop

            @lock.synchronize do
              @active_tasks << task
            end

            task_output = run_task(task, user)

            @lock.synchronize do
              @io.puts(task_output)
              @active_tasks.delete(task)

              if task_output =~ /Failing Scenarios:/
                @failed_tasks[task.scenario] = task_output
                raise Exception if ABORT_ON_EXCEPTION
              end
              # sleep 1 second
              sleep 1
            end
          end
        end
      end

      threads.each { |t| t.join }
    end

    def cleanup
      @queue.clear
      @users.each do |user|
        add_task("features/cleanup.feature", "BVT_CLEAN_ALL" => "yes")
      end
      run_tasks
    end

    def run_task(task, user)
      cmd = [] # Preparing command for popen

      env_extras = {
        "BVT_CLEAN_NAMESPACE" => "yes",
        "VCAP_BVT_USER" => user,
        "VCAP_BVT_USER_PASSWD" => @password
      }

      cmd << ENV.to_hash.merge(task.env.merge(env_extras))
      cmd += ["bundle", "exec", "cucumber", "-e", "hooks.rb", "--color", task.scenario]
      cmd

      output = ""

      @lock.synchronize do
        @io.puts "Started #{yellow(task.scenario)} as #{user}"
        task.start_time = Time.now
      end

      IO.popen(cmd, :err => [:child, :out]) do |io|
        output << io.read
      end

      print "."
      @log.puts(output)
    end

  end
end

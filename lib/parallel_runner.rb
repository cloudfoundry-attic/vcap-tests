require "set"

module Bvt
  class ParallelRunner

    ABORT_ON_EXCEPTION = false

    class Task
      attr_accessor :scenario, :env, :start_time

      def initialize(scenario, env = {})
        @scenario = scenario
        @env = env
      end
    end

    attr_accessor :failed_tasks

    def initialize(users, password, io)
      @users = users
      @io = io
      @lock = Mutex.new
      @password = password
      @queue = Queue.new
      @failed_tasks = []
      @active_tasks = Set.new

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
                @failed_tasks << task
                raise Exception if ABORT_ON_EXCEPTION
              end
            end
          end
        end
      end

      threads.each { |t| t.join }
    end

    def cleanup
      @queue.clear
      @users.each do |user|
        add_task("features/cleanup.feature", "CLEAN_ALL" => "yes")
      end
      run_tasks
    end

    def run_task(task, user)
      cmd = [] # Preparing command for popen

      env_extras = {
        "CLEAN_NAMESPACE" => "yes",
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

      output
    end

  end
end

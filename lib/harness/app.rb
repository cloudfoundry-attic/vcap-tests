require "cfoundry"

module BVT::Harness
  class App

    def initialize(app, client)
      @app = app
      @client = client
      @log = @client.log
    end

    # manifest example
    #
    #{"path"=>"/Users/name/src/vcap/tests/assets/sinatra/app_sinatra_service",
    # "name"=>"app-sinatra-service",
    # "instances"=>1,
    # "uris"=>["app-sinatra-service.appcloud24.dev.mozycloud.com"],
    # "staging"=>{"framework"=>"sinatra", "runtime"=>"ruby19"},
    # "resources"=>{"memory"=>64}
    #}
    #
    def push(manifest)
      check_framework(manifest['staging']['framework'])
      check_runtime(manifest['staging']['runtime'])

      if @app.exists?
        @app.upload(manifest['path'])
        restart
        return
      end

      @app.total_instances = manifest['instances']
      @app.urls = manifest['uris']
      @app.framework = manifest['staging']['framework']
      @app.runtime = manifest['staging']['runtime']
      @app.memory = manifest['resources']['memory']

      @log.info "Push App: #{manifest['name']}"
      @app.create!
      begin
        @app.upload(manifest['path'])
      rescue
        @log.error "Upload App: #{manifest['name']} failed."
        raise RuntimeError, "Upload App: #{manifest['name']} failed."
      end

      start
    end

    def delete
      @log.debug "delete app. App name: #{@app.name}"
      @app.delete!
    end

    def restart
      stop
      start
    end

    def stop
      unless @app.exists?
        @log.error "Application: #{@app.name} does not exist!"
        raise RuntimeError "Application: #{@app.name} does not exist!"
      end

      unless @app.stopped?
        @log.info "Stop Application: #{@app.name}"
        @app.stop!
      end
    end

    def start
      unless @app.exists?
        @log.error "Application: #{@app.name} does not exist!"
        raise RuntimeError "Application: #{@app.name} does not exist!"
      end

      unless @app.running?
        @log.info "Start Application: #{@app.name}"
        @app.start!
      end
      check_application
    end

    private

    APP_CHECK_LIMIT = 60

    def check_application
      seconds = 0
      until @app.healthy?
        sleep 1
        seconds += 1
        if seconds == APP_CHECK_LIMIT
          @log.error "Application: #{@app.name} cannot be started in #{APP_CHECK_LIMIT} seconds"
          raise RuntimeError, "Application: #{@app.name} cannot be started in #{APP_CHECK_LIMIT} seconds"
        end
      end
    end

    def check_framework(framework)
      match = false
      @client.system_frameworks.each do |name, _|
        if name =~ /#{framework}/
          match = true
          break
        end
      end
      pending("Framework: #{framework} is not available on target: #{@client.target}") unless match
    end

    def check_runtime(runtime)
      match = false
      @client.system_runtimes.each do |name, _|
        if name =~ /#{runtime}/
          match = true
          break
        end
      end
      pending("Runtime: #{runtime} is not available on target: #{@client.target}") unless match
    end
  end
end

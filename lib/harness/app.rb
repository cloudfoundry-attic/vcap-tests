require "cfoundry"

module BVT::Harness
  class App
    attr_reader :name

    def initialize(app, client)
      @app = app
      @name = @app.name
      @client = client
      @log = @client.log
    end

    def inspect
      "#<BVT::Harness::App '#@name'>"
    end

    # manifest example
    #
    #{"path"=>"/Users/name/src/vcap/tests/assets/sinatra/app_sinatra_service",
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
      @app.urls = manifest['uris'].collect {|uri| @client.namespace + uri}
      @app.framework = manifest['staging']['framework']
      @app.runtime = manifest['staging']['runtime']
      @app.memory = manifest['resources']['memory']

      @log.info "Push App: #{@app.name}"
      @log.debug("Push App: #{@app.name}, Manifest: #{manifest}")
      begin
        @app.create!
        @app.upload(manifest['path'])
      rescue
        @log.error("Push App: #{@app.name} failed. Manifest: #{manifest}")
        raise RuntimeError, "Push App: #{@app.name} failed. Manifest: #{manifest}"
      end

      start
    end

    def delete
      @log.info("Delete App: #{@app.name}")
      begin
        @app.delete!
      rescue
        @log.error "Delete App: #{@app.name} failed. "
        raise RuntimeError, "Delete App: #{@app.name} failed."
      end
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
        @log.info "Stop App: #{@app.name}"
        begin
          @app.stop!
        rescue
          @log.error "Stop App: #{@app.name} failed. "
          raise RuntimeError, "Stop App: #{@app.name} failed."
        end
      end
    end

    def start
      unless @app.exists?
        @log.error "Application: #{@app.name} does not exist!"
        raise RuntimeError "Application: #{@app.name} does not exist!"
      end

      unless @app.running?
        @log.info "Start App: #{@app.name}"
        begin
          @app.start!
        rescue
          @log.error "Start App: #{@app.name} failed. "
          raise RuntimeError, "Start App: #{@app.name} failed."
        end
      end
      check_application
    end

    def bind(service_name)
      unless @client.services.collect(&:name).include?(service_name)
        @log.error("Fail to find service: #{service_name}")
        raise RuntimeError, "Fail to find service: #{service_name}"
      end
      begin
        @log.info("Application: #{@app.name} bind Service: #{service_name}")
        @app.bind(service_name)
      rescue
        @log.error("Fail to bind Service: #{service_name} to Application: #{@app.name}")
        raise RuntimeError, "Fail to bind Service: #{service_name} to Application: #{@app.name}"
      end
    end

    def unbind(service_name)
      unless @app.services.include?(service_name)
        @log.error("Fail to find service: #{service_name} binding to application: #{@app.name}")
        raise RuntimeError, "Fail to find service: #{service_name} binding to application: #{@app.name}"
      end

      begin
        @log.info("Application: #{@app.name} unbind Service: #{service_name}")
        @app.unbind(service_name)
      rescue
        @log.error("Fail to unbind service: #{service_name} for application: #{@app.name}")
        raise RuntimeError, "Fail to unbind service: #{service_name} for application: #{@app.name}"
      end
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
      ## TODO: read frameworks from profile.yml to improve performance

      match = false
      @client.system_frameworks.each do |name, _|
        if name =~ /#{framework}/
          match = true
          break
        end
      end
      unless match
        @log.error("Framework: #{framework} is not available on target: #{@client.target}")
        pending("Framework: #{framework} is not available on target: #{@client.target}")
      end

    end

    def check_runtime(runtime)
      ## TODO: read runtimes from profile.yml to improve performance

      match = false
      @client.system_runtimes.each do |name, _|
        if name =~ /#{runtime}/
          match = true
          break
        end
      end
      unless match
        @log.error("Runtime: #{runtime} is not available on target: #{@client.target}")
        pending("Runtime: #{runtime} is not available on target: #{@client.target}")
      end
    end
  end
end

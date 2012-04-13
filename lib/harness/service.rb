require "cfoundry"

module BVT::Harness
  class Service
    attr_reader :name

    def initialize(service, client)
      @service = service
      @client = client
      @log = @client.log
      @name = @service.name
    end

    def inspect
      "#<BVT::Harness::Service '#@name'>"
    end
    # service manifest example
    #{"vendor"=>"mysql", "version"=>"5.1"}
    def create(vendor_manifest)
      match = false

      ## TODO: read services from profile.yml to improve performance
      @client.system_services.each do |type, vendors|
        vendors.each do |vendor, versions|
          versions.each do |version, _|
            if vendor =~ /#{vendor_manifest['vendor']}/ && version =~ /#{vendor_manifest['version']}/
              match = true
              @service.type = type
              @service.vendor = vendor
              @service.version = version
              # TODO: only free service plan is supported
              @service.tier = "free"
              break
            end
          end
          break if match
        end
      end

      unless match
        @log.error("Service: #{vendor_manifest['vendor']} #{vendor_manifest['version']} " +
                       "is not available on target: #{@client.target}")
        pending("Service: #{vendor_manifest['vendor']} #{vendor_manifest['version']} " +
                  "is not available on target: #{@client.target}")
      end

      @log.info("Create Service (#{@service.vendor} #{@service.version}): #{@service.name}")
      begin
        @service.create!
      rescue Exception => e
        @log.error("Fail to create service (#{@service.vendor} #{@service.version}): #{@service.name}")
        raise RuntimeError, "Fail to create service (#{@service.vendor} #{@service.version}): #{@service.name}\n#{e.to_s}"
      end
    end

    def delete
      if @service.exists?
        @log.info("Delete Service (#{@service.vendor} #{@service.version}): #{@service.name}")
        begin
          @service.delete!
        rescue Exception => e
          @log.error("Fail to delete service (#{@service.vendor} #{@service.version}): #{@service.name}")
          raise RuntimeError, "Fail to delete service (#{@service.vendor} #{@service.version}): #{@service.name}\n#{e.to_s}"
        end
      end
    end
  end
end

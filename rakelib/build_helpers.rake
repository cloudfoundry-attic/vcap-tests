require('erb') unless defined?(ERB)

# Helper class for generating a set of component config files
# based on a CI 'profile'.
#
# Puts core component yaml files in ci-working-dir/config
# Puts staging manifest files in ci-working-dir/manifests
class BuildTemplate
  attr_reader :profile_dir

  def initialize(profile_dir)
    @profile_dir = profile_dir
  end

  # Write out a set of config files based on the selected profiles.
  # The output goes in the ci working directory.
  # Returns two arrays; the pidfiles for the primary components, and
  # the pidfiles for the service gateways and nodes.
  # These are useful separately because they are stopped in a specific order.
  def generate
    each_core_component do |erb_template, destination_yaml|
      process_template(erb_template, destination_yaml)
    end
    each_service do |erb_template, destination_yaml|
      process_template(erb_template, destination_yaml)
    end
    generate_staging_manifests
    generate_startup_script
    generate_service_startup_script
    return component_pid_paths, component_pid_paths(true)
  end

  # Yields each pairing of source erb template and destination path
  # to the given block.
  def each_core_component
    CoreComponents.components.each do |component|
      next if component =~ /^services/
      erb = File.join(profile_dir, "#{component}.yml.erb")
      dst = File.join(BuildConfig.config_dir, "#{component}.yml")
      yield erb, dst
    end
  end

  # Each service component has two config files, and therefore
  # yields twice to the given block.
  def each_service
    CoreComponents.components.each do |component|
      next unless component =~ /^services/
      prefix = File.basename(component)
      # Create a working directory for the service while we are here.
      FileUtils.mkdir_p File.join(BuildConfig.working_dir, component)
      %w[_node _gateway].each do |suffix|
        svc = "#{prefix}#{suffix}"
        erb = File.join(profile_dir, component, "#{svc}.yml.erb")
        dst = File.join(BuildConfig.config_dir, "#{svc}.yml")
        yield erb, dst
      end
    end
  end

  # an array of paths to the .yml files that were generated.
  def generated_files
    @generated_files ||= []
  end

  # Don't call this until you've generated the config YAML files.
  # Returns an array of all the pidfiles used by the generated components.
  # By default, excludes service pids; call component_pid_paths(true) to return these.
  def component_pid_paths(services = false)
    paths = []
    generated_files.each do |path|
      config = YAML.load_file(path)
      next unless pid_file = config['pid']

      if for_service?(path)
        if services
          paths.push(pid_file)
        end
      elsif !services
        paths.push(pid_file)
      end
    end
    paths
  end

  def for_service?(path)
    path =~ /_gateway|_node/
  end

  # If the third argument is false, don't add the generated file
  # to the list that we will examine for pid files and such.
  def process_template(erb, yaml_file, remember = true)
    config = BuildConfig # templates should say config.something
    data = File.read(erb)
    template = ERB.new(data, nil, "%")
    output = template.result(binding)
    output_dir = File.dirname(yaml_file)
    FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
    File.open(yaml_file, 'w') do |f|
      f.write(output)
    end
    generated_files.push(yaml_file) if remember
  end

  def generate_staging_manifests
    template_dir = File.join(profile_dir, 'manifests')
    Dir["#{template_dir}/*.yml.erb"].each do |erb|
      type = File.basename(erb, '.yml.erb')
      dest = File.join(BuildConfig.manifest_dir, "#{type}.yml")
      process_template(erb, dest, false)
    end
  end

  def generate_startup_script
    script = <<-START
#!/bin/sh
cd #{CoreComponents.root}
export BUNDLE_PATH=#{BuildConfig.bundle_path}
#{start_command_for 'router'}
#{start_command_for 'dea'}
#{start_command_for 'health_manager'}
sleep 5
#{start_command_for 'cloud_controller'}
START

    File.open(BuildConfig.startup_script, 'w') do |fh|
      fh.print(script)
    end
    FileUtils.chmod(0755, BuildConfig.startup_script)
  end

  def generate_service_startup_script
    script = <<-START
#!/bin/sh
cd #{CoreComponents.root}
export BUNDLE_PATH=#{BuildConfig.bundle_path}
#{start_command_for 'redis_node'}
#{start_command_for 'mysql_node'}
#{start_command_for 'mongodb_node'}
#{start_command_for 'neo4j_node'}
#{start_command_for 'redis_gateway'}
#{start_command_for 'mysql_gateway'}
#{start_command_for 'mongodb_gateway'}
#{start_command_for 'neo4j_gateway'}
START

    File.open(BuildConfig.service_startup_script, 'w') do |fh|
      fh.print(script)
    end
    FileUtils.chmod(0755, BuildConfig.service_startup_script)
  end

  # Returns a string like bin/cloud_controller -c whatever.yml 2>&1
  def start_command_for(name)
    config = File.join(BuildConfig.config_dir, "#{name}.yml")
    log    = File.join(BuildConfig.log_dir, "#{name}.log")
    script = case name
             when /_node|_gateway/
               "bin/services/#{name}"
             else
               "bin/#{name}"
             end
    "#{script} -c #{config} >> #{log} 2>> #{log} &"
  end
end


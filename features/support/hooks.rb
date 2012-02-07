# All cucumber hooks should be put in this file
# Cucumber generates threads for each hook,
# that can overlap with parallel task, and tests may fail
# Parallel task does not use hooks, it cleans apps from current namespace
# The best way is to put last task as the last step of scenario, not as hook

After do
  AppCloudHelper.instance.cleanup
end

After("@creates_simple_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_APP
end

After("@creates_simple_app2") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_APP2
end

After("@creates_simple_app3") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_APP3
end

After("@creates_tiny_java_app") do
  AppCloudHelper.instance.delete_app_internal TINY_JAVA_APP
end

After("@creates_simple_db_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_DB_APP
end

After("@creates_redis_lb_app") do
  AppCloudHelper.instance.delete_app_internal REDIS_LB_APP
end

After("@creates_env_test_app") do
  AppCloudHelper.instance.delete_app_internal ENV_TEST_APP
end

After("@creates_broken_app") do
  AppCloudHelper.instance.delete_app_internal BROKEN_APP
end

After("@creates_rails3_app") do
  AppCloudHelper.instance.delete_app_internal RAILS3_APP
end

After("@creates_jpa_app") do
  AppCloudHelper.instance.delete_app_internal JPA_APP
end

After("@creates_hibernate_app") do
  AppCloudHelper.instance.delete_app_internal HIBERNATE_APP
end

After("@creates_dbrails_app") do
  AppCloudHelper.instance.delete_app_internal DBRAILS_APP
end

After("@creates_dbrails_broken_app") do
  AppCloudHelper.instance.delete_app_internal DBRAILS_BROKEN_APP
end

After("@creates_grails_app") do
  AppCloudHelper.instance.delete_app_internal GRAILS_APP
end

After("@creates_roo_app") do
  AppCloudHelper.instance.delete_app_internal ROO_APP
end

After("@creates_mochiweb_app") do
    AppCloudHelper.instance.delete_app_internal SIMPLE_ERLANG_APP
end

After("@creates_simple_lift_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_LIFT_APP
end

After("@creates_lift_db_app") do
  AppCloudHelper.instance.delete_app_internal LIFT_DB_APP
end

After("@creates_tomcat_version_check_app") do
  AppCloudHelper.instance.delete_app_internal TOMCAT_VERSION_CHECK_APP
end

After("@creates_neo4j_app") do
  AppCloudHelper.instance.delete_app_internal NEO4J_APP
end

After("@creates_wsgi_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_PYTHON_APP
end

After("@creates_wsgi_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_PYTHON_APP
end

After("@creates_django_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_DJANGO_APP
end

After("@creates_simple_php_app") do
  AppCloudHelper.instance.delete_app_internal SIMPLE_PHP_APP
end

After("@creates_spring_env_app") do
  AppCloudHelper.instance.delete_app_internal SPRING_ENV_APP
end

After("@creates_auto_reconfig_test_app") do
  AppCloudHelper.instance.delete_app_internal AUTO_RECONFIG_TEST_APP
end

After("@creates_auto_reconfig_missing_deps_test_app") do
  AppCloudHelper.instance.delete_app_internal AUTO_RECONFIG_MISSING_DEPS_TEST_APP
end

After("@creates_java_app_with_delay") do
  AppCloudHelper.instance.delete_app_internal JAVA_APP_WITH_STARTUP_DELAY
end

at_exit do
  AppCloudHelper.instance.cleanup
end

# autostaging

After("@creates_services") do |scenario|
  delete_app_services
end

After("@creates_jpa_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_hibernate_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_hibernate_postgresql_adapter") do |scenario|
  delete_app_services_check
end

After("@creates_grails_db_adapter") do |scenario|
  delete_app_services_check
end

After("@creates_roo_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_rails3_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_dbrails_db_adapter") do |scenario|
  delete_app_services
end

After("@creates_dbrails_broken_db_adapter") do |scenario|
  delete_app_services
end

# atmos

After("@creates_atmos_app") do |scenario|
  delete_app @app, @token if @app
end

After("@creates_atmos_service") do |scenario|
  delete_service @atmos_service[:name] if @atmos_service
end

# lift

After("@creates_lift_db_adapter") do |scenario|
  delete_app_services
end

# neo4j

After("@creates_neo4j_service") do |scenario|
  delete_app_services if @neo4j_service
end

# appcloud_performance

After("@lb_check") do |scenario|
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  services = app_info[:services]
  delete_services services if services.length.to_i > 0

  if(scenario.failed?)
    if @counters != nil
      puts "The scenario failed due to unexpected load balance distribution from the router"
      puts "The following hash shows the per-instance counts along with the target and allowable deviation"
      pp @counters
      puts "target: #{@perf_target}, allowable deviation: #{@perf_slop}"
    end
  end
end

# look at for env_test cleanup
After("@env_test_check") do |scenario|
  app_info = get_app_status @app, @token
  app_info.should_not == nil
  services = app_info[:services]
  delete_services services if services.length.to_i > 0

  if(scenario.failed?)
     puts "The scenario failed #{scenario}"
  end
end

# service broker

After("@creates_simple_kv_app") do |scenario|
  AppCloudHelper.instance.delete_app_internal SIMPLE_KV_APP
end


After("@creates_brokered_service_app") do |scenario|
  AppCloudHelper.instance.delete_app_internal BROKERED_SERVICE_APP
end

After("@creates_brokered_service") do |scenario|
  delete_brokered_services if @brokered_service
end

# spring_env_steps

After("@creates_spring_env_app") do |scenario|
  delete_app_services
end

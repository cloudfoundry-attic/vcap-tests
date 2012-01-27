namespace :uaa do
  task :run do
    sh "bundle exec cucumber --tags ~@bvt_upgrade features/uaa.feature"
  end
end

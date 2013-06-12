require "bundler/capistrano"
require "./script/setup"

set :stages, CONFIG[:deploy][:targets].collect { |target| target[:name] }
set :default_stage, "lab-dev"
require 'capistrano/ext/multistage'

set  :user, "deploy"

set :rvm_type, :system
require "rvm/capistrano"

desc "Echo the server's login env for deploy user"
task :env_server do
  run "echo *** SERVER IP: `wget -qO- http://instance-data/latest/meta-data/public-ipv4`"
  run "env"
end

desc "ls server"
task :ls_server do
  run "cd /var/www/app"
  run "ls -als"
end

def server_config_settings_yml
  # TODO: This wont work all the time....
  server = find_servers_for_task(current_task).first
  puts server.host
  {
    "production" => {
      :hostname => ENV['LAB_HOST'] || server.host || "lab.dev.concord.org"
    }
  }.to_yaml
end

namespace :deploy do

  desc "restart the Rack application"
  task :restart do
    run "mkdir -p /var/www/app/tmp"
    run "touch /var/www/app/tmp/restart.txt"
  end

  desc "checkout branch and force reset to origin/branch"
  task :checkout do
    run "cd /var/www/app; git fetch --all"
    run "cd /var/www/app; git checkout #{branch}"
    run "cd /var/www/app; git reset --hard origin/#{branch}"
  end

  desc "update Ruby Gems with bundle install"
  task :bundle_install do
    run "cd /var/www/app; bundle install --binstubs"
  end

  desc "update server"
  task :update do
    checkout
    bundle_install
    run "cd /var/www/app; make clean-public; make"
    restart
  end

  desc "clean and update server"
  task :clean_and_update do
    checkout
    bundle_install
    run "cd /var/www/app; make clean; make"
    restart
  end

  desc "clean and rebuild jars in public/jnlp dir on server"
  task :update_jnlps do
    checkout
    run "cd /var/www/app; make jnlp-all"
    restart
  end

  desc "clean and update server and recreate jar resources"
  task :clean_and_update_all do
    clean_and_update
    update_jnlps
  end

  desc "setup server"
  task :setup do
    checkout
    run "cd /var/www/app; bundle install --binstubs"
    run "cd /var/www/app; cp config/config.sample.yml config/config.yml"
    clean_and_update_all
  end

  desc "display last commit on deployed server"
  task :status do
    run "cd /var/www/app; git log -1"
  end

  desc "create symbolic link from old urls to root dir"
  task :create_symbolic_links do
    run "cd /var/www/app; make symbolic-links"
  end
end

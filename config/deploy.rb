require 'capistrano/ext/multistage'

set :application, "zapdaggit"
set :repository,  "https://svn.ubikorp.com/zapdaggit/trunk"

# uses multistage support
# see config/deploy/STAGE.rb for stage-specific variables
# (app/web/db roles, deploy_to location)

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
#set :deploy_to, "/usr/local/www/apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

#role :app, "rhinox.zerosum.org"
#role :web, "rhinox.zerosum.org"
#role :db,  "rhinox.zerosum.org", :primary => true

set :user, "deploy"
set :group, "dev"
set :runner, "root"

namespace :deploy do
  task :after_update_code, :roles => [:app] do
    db_config = "#{shared_path}/config/database.yml.production"
    run <<-CMD
      cp #{db_config} #{release_path}/config/database.yml 
    CMD
    link_shared_assets
  end

  desc "Disable requests to the application, show maintenance page."
  web.task :disable, :roles => :web do
    run "cp #{current_path}/public/maintenance.html #{shared_path}/system/maintenance.html"
  end

  desc "Re-enable the web server by deleting any maintenance file."
  web.task :enable, :roles => :web do
    run "rm #{shared_path}/system/maintenance.html"
  end

  desc "Restart mongrel servers"
  task :restart, :roles => [:web] do
    sudo "/usr/local/bin/mongrel_rails cluster::restart -C #{current_path}/config/mongrel_cluster.yml"
  end

  desc "Link shared assets"
  task :link_shared_assets do
    run <<-CMD
      rm -rf #{release_path}/public/images/art &&
      rm -rf #{release_path}/public/images/logos &&
      ln -s #{shared_path}/assets/art #{release_path}/public/images/art &&
      ln -s #{shared_path}/assets/logos #{release_path}/public/images/logos &&
      ln -s #{shared_path}/assets/news #{release_path}/public/news
    CMD
  end
end

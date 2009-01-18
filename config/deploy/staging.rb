set :deploy_to, "/usr/local/www/apps/#{application}"

role :app, "rhinox.zerosum.org"
role :web, "rhinox.zerosum.org"
role :db,  "rhinox.zerosum.org", :primary => true

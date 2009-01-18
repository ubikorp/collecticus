set :application, "collecticus"
set :deploy_to, "/var/www/apps/#{application}"

role :app, "digdug.collectic.us"
role :web, "digdug.collectic.us"
role :db,  "digdug.collectic.us", :primary => true

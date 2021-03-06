require 'paratrooper'

  namespace :deploy do
    desc 'Deploy app in staging environment'
    task :staging do
      deployment = Paratrooper::Deploy.new("text-notify-staging", tag: 'staging')

     deployment.deploy
    end

    desc 'Deploy app in production environment'
    task :production do
      deployment = Paratrooper::Deploy.new("text-notify") do |deploy|
       deploy.tag              = 'production'
       deploy.match_tag        = 'staging'
      end
      
      deployment.deploy
    end

    desc 'Deploy app in production environment and skip staging'
    task :skip_staging do
      deployment = Paratrooper::Deploy.new("text-notify") do |deploy|
       deploy.tag              = 'production'
      end
      
      deployment.deploy
    end

    
 end
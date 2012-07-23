set :domain, "licensing.lichfield-001.vm.brightbox.net"
set :application, "licensing"
set :deploy_to, "/home/rails/#{application}"

set :user, "rails"
set :use_sudo, false

ssh_options[:forward_agent] = true

set :scm, :git
set :scm_passphrase, "pooandwee"
set :repository,  "git@github.com:Lichfield-District-Council/Licensing.git"
set :branch, 'master'
set :git_shallow_clone, 1

#set :repository, "."
#set :scm, :none
#set :deploy_via, :copy

role :web, domain
role :app, domain
role :db,  domain, :primary => true

#set :deploy_via, :copy

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  # Assumes you are using Passenger
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images css).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
end

after 'deploy:update_code', 'deploy:symlink_db'

namespace :deploy do
  desc "Symlinks the database.rb"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.rb #{release_path}/config/database.rb"
  end
end
namespace :backup do
  desc 'Backs up the configuration file(s) on the specified node(s)'
  task :config do
    config = @config
    backup = config['backup']['config']
    unless File.exists? backup['name']
      on "#{backup['host']}" do |host|
        as user: backup['user'] do
          SSHKit::Backend::Netssh.config.pty = true
          execute("cd #{backup['root']} && zip -r #{backup['name']} . #{backup['files'].map{ |f| '-i ' + f }.join(' ')}")
          execute("cd #{backup['root']} && mv #{backup['name']} /tmp/")
          download!("/tmp/#{backup['name']}", ".")
          execute("rm /tmp/#{backup['name']}")
        end
      end
    end
  end

  desc 'Do a sql dump of the database'
  task :database do
    config = @config
    backup = config['backup']['database']
    unless File.exists? backup['name']
      on "#{backup['host']}" do |host|
        as user: backup['user'] do
          SSHKit::Backend::Netssh.config.pty = true
          execute("mysqldump --user='#{backup['db_user']}' --password='#{backup['db_pass']}' #{backup['db_name']} | zip > #{backup['name']}")
          download!("#{backup['name']}", ".")
          execute("rm #{backup['name']}")
        end
      end
    end
  end

  desc 'Backs up the application configuration file(s) on the specified node(s)'
  task :public do
    config = @config
    backup = config['backup']['public']
    unless File.exists? backup['name']
      on "#{backup['host']}" do |host|
        as user: backup['user'] do
          SSHKit::Backend::Netssh.config.pty = true
          execute("cd #{backup['root']} && zip -r #{backup['name']} . #{backup['files'].map{ |f| '-i ' + f }.join(' ')}")
          execute("cd #{backup['root']} && mv #{backup['name']} /tmp/")
          download!("/tmp/#{backup['name']}", ".")
          execute("rm /tmp/#{backup['name']}")
        end
      end
    end
  end
end


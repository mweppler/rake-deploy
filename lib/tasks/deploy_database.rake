namespace :db do
  desc 'Deploy the contents from the projects db migrations directory'
  task :migrate do
    config = @config
    deploy_type = 'database'
    timestamp = @timestamp

    app_name = config['app_name']
    deploy_tmp_dir = sprintf(config['deploy_tmp_dir'], app_name, timestamp)
    arch_name = "#{app_name}-#{timestamp}.zip"

    # Create local archive file
    Dir.chdir "#{deploy_tmp_dir}"
    run_locally do
      if test("[ -f #{arch_name} ]")
        raise "File archive already exists: #{deploy_tmp_dir}/#{arch_name}"
      end
    end
    Dir.chdir "#{deploy_tmp_dir}/#{app_name}/#{config[deploy_type]['local_root']}"
    run_locally do
      execute("zip -r #{arch_name} *")
      execute("mv #{arch_name} #{deploy_tmp_dir}/")
    end

    # Change back to base directory
    Dir.chdir "#{deploy_tmp_dir}"

    # Deploy to node
    on config[deploy_type]['nodes'].keys do |host|
      host_settings = config[deploy_type]['nodes'][host]
      deployer = host_settings['deployer']
      as user: deployer do
        SSHKit::Backend::Netssh.config.pty = true

        # Upload the app, unzip & symlink to current release
        upload!(arch_name, "/tmp")
        execute("sudo mkdir -p /tmp/#{timestamp}")
        execute("sudo mv /tmp/#{arch_name} /tmp/#{timestamp}/")
        execute("sudo unzip /tmp/#{timestamp}/#{arch_name} -d /tmp/#{timestamp}")
        execute("sudo rm /tmp/#{timestamp}/#{arch_name}")
        output = capture("mysql --user=#{host_settings['db_user']} --password=#{host_settings['db_pass']} #{host_settings['db_name']} --execute=\"SELECT * FROM schema_migrations\"")
        migrations = output.gsub("\t", '_').split("\n").map { |migration| migration + '.sql' }
        migrations.shift # remove header
        migrations.each do |migration|
          if test("[ -f /tmp/#{timestamp}/#{migration} ]")
            capture("sudo rm /tmp/#{timestamp}/#{migration}")
          end
        end
        #puts capture("for migration in `ls /tmp/#{timestamp}`; do echo /tmp/#{timestamp}/$migration; done")
        execute("for migration in `ls /tmp/#{timestamp}`; do mysql --user=#{host_settings['db_user']} --password=#{host_settings['db_pass']} #{host_settings['db_name']} < /tmp/#{timestamp}/$migration; done")
        execute("sudo rm -rf /tmp/#{timestamp}")
      end
    end

    # Remove local archive file
    run_locally do
      execute("rm #{arch_name}")
    end
  end

  desc 'Rollback database `n` steps'
  task :rollback do|t, args|
    steps = ENV['steps'] || 1
    puts "rollback #{steps} step(s)"
  end
end


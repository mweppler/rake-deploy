namespace :deploy do
  desc 'Deploy the contents from the projects public directory'
  task :public do
    config = @config
    deploy_type = 'application'
    timestamp = @timestamp

    app_name = config['app_name']
    config_files = config['backup']['public']['files']
    app_dirs = config[deploy_type]['app_dirs']
    ignore_files = config[deploy_type]['ignore_files']
    shared_dir  = config[deploy_type]['shared_dir']
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
      execute("zip -r #{arch_name} . -i #{app_dirs.map{ |d| "\"#{d}/*\"" }.join(' ')} #{ignore_files.map{ |f| '-x ' + f }.join(' ')}")
      execute("mv #{arch_name} ../")
    end

    # Change back to base directory
    Dir.chdir "#{deploy_tmp_dir}"

    # Deploy to node
    on config[deploy_type]['nodes'].keys do |host|
      host_settings = config[deploy_type]['nodes'][host]
      deployer = host_settings['deployer']
      as user: deployer do
        SSHKit::Backend::Netssh.config.pty = true

        doc_root = "#{host_settings['doc_root']}/#{config['app_name']}"

        # Make sure the project environment has been setup on this node
        if test("[ ! -d #{doc_root} ]")
          raise "Directory structure does not exist: #{host}:#{doc_root}"
        end

        if test("[ -d #{doc_root}/releases/#{timestamp} ]")
          raise "A release with this timestamp already exists: #{host}:#{doc_root}/releases/#{timestamp}"
        end

        # TOOD: Handle failure by reverting to the previous release

        # Remove previous symlinked config files
        if test("[ -h #{doc_root}/releases/current ]")
          execute("sudo rm #{doc_root}/releases/current")
        end

        # Upload the app, unzip & symlink to current release
        upload!(arch_name, "/tmp")
        execute("sudo mv /tmp/#{arch_name} #{doc_root}/releases/")
        execute("sudo mkdir -p #{doc_root}/releases/#{timestamp}")
        execute("sudo unzip #{doc_root}/releases/#{arch_name} -d #{doc_root}/releases/#{timestamp}")
        execute("sudo rm #{doc_root}/releases/#{arch_name}")
        execute("sudo ln -s #{doc_root}/releases/#{timestamp} #{doc_root}/releases/current")

        # Symlink config files
        config_files.each do |config_file|
          execute("sudo ln -s #{doc_root}/shared/config/#{config_file} #{doc_root}/releases/current/public/#{config_file}")
        end

        # Symlink images
        execute("sudo ln -s #{shared_dir}/images/headshots #{doc_root}/releases/#{timestamp}/public/images/headshots")
        execute("sudo ln -s #{shared_dir}/images/panos #{doc_root}/releases/#{timestamp}/public/images/panos")

        # Change files permissions
        perms = host_settings['perms']
        execute("sudo chown -R #{perms['web_owner']}:#{perms['web_group']} #{doc_root}")
        execute("sudo chmod -R ug+#{perms['web_perms']} #{doc_root}")
      end
    end

    # Remove local archive file
    run_locally do
      execute("rm #{arch_name}")
    end
  end
end


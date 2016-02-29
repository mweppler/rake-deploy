namespace :setup do
  desc 'Sets up the configuration deployment environment on the specified node(s)'
  task :config do
    config = @config
    deploy_type = 'configuration'
    on config[deploy_type]['nodes'].keys do |host|
      host_settings = config[deploy_type]['nodes'][host]
      deployer = host_settings['deployer']
      puts "on host: #{host}"
      as user: deployer do
        SSHKit::Backend::Netssh.config.pty = true
        doc_root = "#{host_settings['doc_root']}/#{config['app_name']}"
        #if File.exists? File.join(doc_root, '.rake-deploy-setup')
        #end
        #unless setup_complete
        #end

        #if test("[ -d #{doc_root} ]")
          #puts "skip directory creation"
        #end

        execute("sudo mkdir -p #{doc_root}/{releases,shared/{config,log,tmp/{pids,sockets}}}")
        execute("sudo touch #{doc_root}/releases/current")
        upload!("#{config['backup']['config']['name']}", "/tmp")
        execute("sudo mv /tmp/#{config['backup']['config']['name']} #{doc_root}/shared/config/")
        execute("sudo unzip -f #{doc_root}/shared/config/#{config['backup']['config']['name']} -d #{doc_root}/shared/config")
        execute("sudo rm #{doc_root}/shared/config/#{config['backup']['config']['name']}")

        perms = host_settings['perms']
        # Change files permissions
        execute("sudo chown -R #{perms['web_owner']}:#{perms['web_group']} #{doc_root}")
        execute("sudo chmod -R ug+#{perms['web_perms']} #{doc_root}")
      end
    end
  end

  desc 'Sets up the application deployment environment on the specified node(s)'
  task :public do
    config = @config
    deploy_type = 'application'
    on config[deploy_type]['nodes'].keys do |host|
      host_settings = config[deploy_type]['nodes'][host]
      deployer = host_settings['deployer']
      as user: deployer do
        SSHKit::Backend::Netssh.config.pty = true

        doc_root = "#{host_settings['doc_root']}/#{config['app_name']}"

        #if test("[ -d #{doc_root} ]")
          #puts "skip directory creation"
        #end

        execute("sudo mkdir -p #{doc_root}/{releases,shared/{config,log,tmp/{pids,sockets}}}")
        execute("sudo touch #{doc_root}/releases/current")
        upload!("#{config['backup']['public']['name']}", "/tmp")
        execute("sudo mv /tmp/#{config['backup']['public']['name']} #{doc_root}/shared/config/")
        execute("sudo unzip -f #{doc_root}/shared/config/#{config['backup']['public']['name']} -d #{doc_root}/shared/config")
        execute("sudo rm #{doc_root}/shared/config/#{config['backup']['public']['name']}")

        perms = host_settings['perms']
        # Change files permissions
        execute("sudo chown -R #{perms['web_owner']}:#{perms['web_group']} #{doc_root}")
        execute("sudo chmod -R ug+#{perms['web_perms']} #{doc_root}")
      end
    end
  end
end


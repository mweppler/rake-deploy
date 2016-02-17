namespace :destroy do
  desc 'Destroys the config deployment environment on the specified node(s)'
  task :config do
    config = @config
    deploy_type = 'configuration'
    on config[deploy_type]['nodes'].keys do |host|
      host_settings = config[deploy_type]['nodes'][host]
      deployer = host_settings['deployer']
      as user: deployer do
        SSHKit::Backend::Netssh.config.pty = true

        doc_root = "#{host_settings['doc_root']}/#{config['app_name']}"
        execute("sudo rm -rf #{doc_root}")
      end
    end
  end

  desc 'Destroys the public deployment environment on the specified node(s)'
  task :public do
    config = @config
    deploy_type = 'application'
    on config[deploy_type]['nodes'].keys do |host|
      host_settings = config[deploy_type]['nodes'][host]
      deployer = host_settings['deployer']
      as user: deployer do
        SSHKit::Backend::Netssh.config.pty = true

        doc_root = "#{host_settings['doc_root']}/#{config['app_name']}"
        execute("sudo rm -rf #{doc_root}")
      end
    end
  end
end


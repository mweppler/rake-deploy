namespace :deploy do
  desc 'Setup the environment for deployment'
  task :common do
    config = @config
    timestamp = @timestamp
    app_name = config['app_name']
    deploy_tmp_dir = sprintf(config['deploy_tmp_dir'], app_name, timestamp)

    host    = config['repo_info']['host']
    org     = config['repo_info']['org']
    project = config['repo_info']['project']
    proto   = config['repo_info']['protocol']
    token   = config['repo_info']['token']
    user    = config['repo_info']['user']

    github_clone = "git clone #{proto}://#{user}:#{token}@#{host}/#{org}/#{project}.git #{app_name}"

    run_locally do
      execute("mkdir -p #{deploy_tmp_dir}")
    end

    Dir.chdir deploy_tmp_dir

    checkout_branch = "cd #{app_name} && git checkout #{config['repo_info']['branch']}"

    run_locally do
      if test("[ ! -d #{deploy_tmp_dir}/#{app_name} ]")
        execute(github_clone)
        execute(checkout_branch)
      end
    end
  end
end


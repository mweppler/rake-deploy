require 'sshkit'
require 'sshkit/dsl'
require 'yaml'

require_relative 'lib/emailer'

Rake.add_rakelib 'lib/tasks'

# ssh = 'ssh -i ~/.ssh/key.pem deployer@node'
# crontab = '0 0 * * * {node_app_root}/{app_name}/releases/current/bin/some_command > {node_app_root}/{app_name}/releases/current/log/cron.`date +"\%Y\%m\%d"`.log 2>&1'
#
# Assumptions:
#   * sudo visudo has `Defaults requiretty` commented out & `Defaults visibilepw` line not commented out (or added)
#
#     #Defaults    requiretty
#     Defaults   visiblepw
#
#   * deployer has password-less sudo for the necessary commands
#       deployer ALL=(ALL)       NOPASSWD: ALL
#
#   * .ssh/config file exists and password less login for deployer@app_nodes
#       $ ssh-keygen -t rsa -C "deployer"
#
#       Host app_node_1
#       HostName app_node_1.domain.com
#       User deployer
#       IdentityFile ~/.ssh/deployer_rsa
#       PreferredAuthentications publickey
#
#   * app_nodes:~/.ssh/authorized_keys exists with the public key for deployer
#       $ vi ~/.ssh/authorized_keys
#       ssh-rsa ... deployer
#
#   * app_nodes have set the httpd.conf document root to {node_app_root}/{app_name}/releases/current

@config = YAML.load_file("./config.yml")
@timestamp = Time.now.strftime('%Y%m%d%H%M%S%Z')
#@timestamp = '20151208153223PST'

task 'backup:both'   => ['backup:config', 'backup:public']
task 'db:migrate'    => ['deploy:common']
task 'deploy:all'    => ['db:migrate', 'deploy:config', 'deploy:public']
task 'deploy:both'   => ['deploy:config', 'deploy:public']
task 'deploy:config' => ['deploy:common']
task 'deploy:public' => ['deploy:common']
task 'destroy:both'  => ['destroy:config', 'destroy:public']
task 'setup:both'    => ['setup:config', 'setup:public']


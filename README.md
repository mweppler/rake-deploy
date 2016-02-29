# Rake Deploy

## Setup

### Install Ruby and Bundler

    curl -O https://gist.githubusercontent.com/mweppler/9681d81ca856739331cd/raw/243cc5deca94d430ed9f0140817abdf0f9e99aff/install_ruby.sh

    sudo bash install_ruby.sh

    gem install bundler

    bundle install

    rake -t

### Deploy Environment setup

Create an ssh key for password-less login

    ssh-keygen -t rsa -C "deployer"

On the remote host edit the sudoers file

    visudo

    Defaults    requiretty
    Defaults:deployer    !requiretty
    Defaults   !visiblepw
    deployer ALL=(ALL)       NOPASSWD: ALL

Next add the deployer users public key to the `~/.ssh/authorized_keys` file

    vi ~/.ssh/authorized_keys

    ssh-rsa ... deployer

Next edit the `httpd.conf` file. The document root should be `{node_app_root}/{app_name}/releases/current`, and the `...` should be `...`

Now, back on the local host, edit the `.ssh/config` file

    Host app_node_1
    HostName app_node_1.domain.com
    User deployer
    IdentityFile ~/.ssh/deployer_rsa
    PreferredAuthentications publickey

### Misc

    ssh = 'ssh -i ~/.ssh/key.pem deployer@node'

    crontab = '0 0 * * * {node_app_root}/{app_name}/releases/current/bin/some_command > {node_app_root}/{app_name}/releases/current/log/cron.`date +"\%Y\%m\%d"`.log 2>&1'


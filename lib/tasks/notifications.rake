namespace :n do
  desc 'Notify on...'
  task :df do
    config = @config
    options = OpenStruct.new
    options.attachment = config['email']['attachment']
    options.email_conf = ''
    options.from = config['email']['from']
    options.rcpt = config['email']['rcpt'][0]
    options.subject = config['email']['subject']
    options.message = 'This is a test'
    options.message = config['email']['message']
    #options.message_file = config['email']['message_file']
    emailer = Emailer.new
    emailer.options = options
    emailer.prepare_email
    emailer.prepare_server_conf(config['email']['server'])
    emailer.send_email
    #regex = /(Filesystem\s+)(1K-blocks\s+)(Used\s+)(Available\s+)(Use%\s+)(Mounted on\s*)/
    #regex = /(Filesystem\s+)(512-blocks\s+)(Used\s+)(Available\s+)(Capacity\s+)(iused\s+)(ifree\s+)(%iused\s+)(Mounted on\s*)/
    #disk = "/"
    #command = "df -a"
    #on config['app_nodes'][0] do |host|
      #as user: config['deployer'] do
        #SSHKit::Backend::Netssh.config.pty = true

        #output = capture("#{command} #{disk}")
        #lines = output.split("\n")
        #header = lines.shift
        #require 'pry'
        #binding.pry
        #puts output
      #end
    #end
  end
end


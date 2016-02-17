#!/usr/bin/env ruby

# http://ruby-doc.org/stdlib-1.9.3/libdoc/net/smtp/rdoc/Net/SMTP.html

require 'digest/md5'
require 'mime/types'
require 'net/smtp'
require 'optparse'
require 'ostruct'
require 'yaml'

class Emailer
  attr_accessor :email, :message, :options, :server

  def parse_options(args)
    @options = OpenStruct.new
    # Wheres the config directory?
    if File.directory? File.join(Dir.pwd, 'config')
      config_directory = File.join(Dir.pwd, 'config')
    else
      config_directory = File.join(Dir.pwd)
    end
    @options.email_conf = File.join(config_directory, 'emailer_conf.yml')
    opt_parse = OptionParser.new do |opts|
      opts.banner = "Usage: emailer.rb [options]"
      opts.on('-a', '--attachment [FILE]', 'Attach a file: "~/john_doe.vcf"') do |file|
        @options.attachment = file
      end
      opts.on('-c', '--conf [FILE]', 'Configuration file [optional], defaults to ./config/emailer_conf.yml or ./emailer_conf.yml') do |file|
        @options.email_conf = file
      end
      opts.on('-f', '--from [FROM]', 'From address: "John Doe, john.doe@anonymous.com"') do |from|
        @options.from = from
      end
      opts.on('-r', '--rcpt [RCPT]', 'Recipient address: "Jane Doe, jane.doe@anonymous.com"') do |rcpt|
        @options.rcpt = rcpt
      end
      opts.on('-s', '--subject [SUBJECT]', 'The message subject: "Just touching base..."') do |subject|
        @options.subject = subject
      end
      opts.on('-m', '--message [MESSAGE]', 'The message: "Give me a call when you have a few minutes."') do |message|
        @options.message = message
      end
      opts.on('--message-file [FILE]', 'Use an existing text file as message body: "~/my_message.txt"') do |file|
        @options.message_file = file
      end
      opts.on_tail('-h', '--help', 'Display this screen') do
        puts opts
        exit 0
      end
    end
    begin
      opt_parse.parse!(args)
    rescue OptionParser::InvalidOption
      puts "emailer: #{$!.message}"
      puts "emailer: try 'emailer.rb --help' for more information"
      exit 1
    end
  end

  def prepare_email
    @email = OpenStruct.new
    @email.from = @options.from[@options.from.index(',') + 1..-1].strip
    @email.from_alias = @options.from[0..@options.from.index(',') - 1].strip
    @email.rcpt = @options.rcpt[@options.rcpt.index(',') + 1..-1].strip
    @email.rcpt_alias = @options.rcpt[0..@options.rcpt.index(',') - 1].strip
    @email.subject = @options.subject.strip
    # TODO: Test this...
    @email.message = @options.message + "\n" unless @options.message.nil?
    unless @options.message_file.nil? || !File.exists?(@options.message_file)
      File.open(@options.message_file, 'r') { |f| @email.message << f.readline }
    end
    unless @options.attachment.nil? || !File.exists?(@options.attachment)
      attachment = File.read(@options.attachment)
      encoded_attachment = [attachment].pack('m')
    end
    boundary = Digest::MD5.hexdigest(Time.now.to_s)
    content_type = MIME::Types.type_for(@options.attachment)
    @message = <<MESSAGE
From: #{@email.from_alias} <#{@email.from}>
To: #{@email.rcpt_alias} <#{@email.rcpt}>
Subject: #{@email.subject}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{boundary}
--#{boundary}
Content-Type: text/plain
Content-Transfer-Encoding: 8bit

#{@email.message}
--#{boundary}
Content-Type: #{content_type}; name=\"#{File.basename @options.attachment}\"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="#{File.basename @options.attachment}"

#{encoded_attachment}
--#{boundary}--
MESSAGE
  end

  def prepare_server_conf(server = {})
    server = YAML::load(File.open(@options.email_conf)) if File.exists?(@options.email_conf)
    @server = OpenStruct.new
    @server.host = server['host']
    @server.port = server['port'] || 25
    @server.fqdn = server['fqdn']
    @server.user = server['user']
    @server.pass = server['pass']
    @server.type = server['type'] || 'plain'
  end

  def send_email
    begin
      net_smtp = Net::SMTP.new(@server.host, @server.port)
      #net_smtp.enable_ssl if @server.enable_encryption
      net_smtp.enable_starttls if @server.enable_encryption
      #net_smtp.enable_starttls_auto if @server.enable_encryption
      #net_smtp.enable_tls if @server.enable_encryption
      #net_smtp.starttls = :auto if @server.enable_encryption
      #net_smtp.starttls = :always if @server.enable_encryption
      require 'pry'
      binding.pry
      net_smtp.starttls(@server.fqdn, @server.user, @server.pass, @server.type.to_sym) do |smtp|
      #Net::SMTP.start(@server.host, @server.port, @server.fqdn, @server.user, @server.pass, @server.type.to_sym) do |smtp|
        smtp.send_message @message, @email.from, @email.rcpt
      end
    rescue Exception => e
      puts "Exception: #{e} #{e.message}"
    end
  end
end

if __FILE__ == $0
  emailer = Emailer.new
  emailer.parse_options(ARGV)
  emailer.prepare_email
  emailer.prepare_server_conf
  emailer.send_email
  exit 0
end


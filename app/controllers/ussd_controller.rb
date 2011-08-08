class UssdController < ApplicationController
  def index
    @servers = {
      "ussd-vodafone-chennai-rotn" => [
        'ussd-vodafone-renderer-1',
        'ussd-vodafone-renderer-2',
        'ussd-vodafone-renderer-3',
        'smscd',
        'ussd'
      ]
    }
  end

  def start
    render :text => execute_command(params["service_name"],'start')
  end

  def stop
    render :text => execute_command(params["service_name"],'stop')
  end

  def log
  end

  def execute_command(service,action)
    servers = {
      "ussd-vodafone-chennai-rotn" => {
        'ussd-vodafone-renderer-1' => {"start" => 'ls', "stop" => 'ls'},
        'ussd-vodafone-renderer-2' => {"start" => 'ls', "stop" => 'ls'},
        'ussd-vodafone-renderer-3' => {"start" => 'ls', "stop" => 'ls'},
        'smscd' => {"start" => 'pwd', "stop" => 'pwd', "options" => ["tunnel"]},
        'ussd' => {"start" => 'pwd', "stop" => 'pwd'}
      }
    }
    response = ''
 
   Net::SSH.start('123.238.41.13', 'mobme',:port=> 22,:password => 'mobme123') do |ssh|
      service_details = servers["ussd-vodafone-chennai-rotn"][service]
      commands = []

      if service_details["options"] and service_details["options"].include? "tunnel"
        ssh.forward.remote(3128,"localhost",3128)
        commands << "export http_proxy=http://localhost:3128"
      end
      commands << service_details[action]

      begin
        Timeout.timeout(30) { execute_in_shell( ssh, commands ) }
        response = 'Done'
      rescue => e
        response = "Error #{e.message}"
      end
    end
    return response
  end

#http://stackoverflow.com/questions/5051782/ruby-net-ssh-login-shell
  def execute_in_shell( ssh, commands )
    channel = ssh.open_channel do |channel|
      channel.exec "bash -l" do |new_channel, success|
        new_channel.on_data do |second_channel, data|
          puts "#{data}"
        end

        commands.each do |command|
          new_channel.send_data "#{command}\n"
        end

        #exit or shell will hang indefinitely
        new_channel.send_data "exit\n"
      end
    end
    channel.wait
  end

end

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
    Net::SSH.start('localhost', 'neeraj',:port=> 22,:password => 'neeraj123') do |ssh|
      service_details = servers["ussd-vodafone-chennai-rotn"][service]
      command = service_details[action]
      shell = ssh.shell.open
      if service_details["options"].include? "tunnel"
        ssh.forward.remote_to( 3128, 'localhost', 3128 )
        shell.send_data "export http_proxy=http://localhost:3128/\n"
      end
      
      puts command
      begin
        Timeout.timeout(10) { shell.send_data command }
        response = 'Done'
      rescue
        response = 'Error'
      end
    end
    return response
  end

end

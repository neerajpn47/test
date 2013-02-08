class UssdController < ApplicationController
  def index
    @servers = service_list
  end

  def start
    render :text => execute_command(params["server_name"], params["service_name"], 'start')
  end

  def stop
    render :text => execute_command(params["server_name"], params["service_name"], 'stop')
  end

  def log
  end

  def execute_command(server, service, action)
    response = ''
    server_details = server_details_for[server]
    
    Net::SSH.start(server_details["ip"], server_details["username"], :port=> server_details["port"], :password => server_details["password"]) do |ssh|
      service_type = service_list[server][service][:type]
      service_details = service_types[service_type]
      commands = []
      
      if service_details["options"] and service_details["options"].include? "tunnel"
        ssh.forward.remote(3128,"localhost",3128)
        commands << "export http_proxy=http://localhost:3128"
      end
      
      commands << service_details[action]
      password = server_details_for[server]["password"] if service_details[action].include? "sudo"
            
      begin
        Timeout.timeout(60) { execute_in_shell( ssh, commands, password ) }
        response = 'Done'
      rescue => e
        response = "Error #{e.message}"
      end
    end
    return response
  end

#http://stackoverflow.com/questions/5051782/ruby-net-ssh-login-shell
  def execute_in_shell( ssh, commands , password = nil)
    channel = ssh.open_channel do |channel|
      channel.on_close do 
        puts "Channel closing"
      end

      channel.request_pty do |ch, success|
        puts success ? "psuedo shell started" : "shell failure: sudo won't work"
        channel.exec "bash -l" do |bash, success|
          bash.on_data do |response_channel, data|
            print data
            command = next_command( data, commands, password )
            response_channel.send_data "#{command}\n" if command
          end
        end
      end
    end
    channel.wait
  end
  
  def next_command( data, commands, password )
    if data.include? "[sudo]"
      password
    elsif data[-2] == "$"
      commands.delete_at 0 || "exit"
    end
  end


#Have to move to configuration file
  def service_types
    { 
      "renderer" => {"start" => "ls", "stop" => "ls"},
      "smscd" => {"start" => "sudo /etc/init.d/smscd start", "stop" => "sudo /etc/init.d/smscd stop", "options" => "tunnel"},
      "ussd" => {"start" => "ls", "stop" => "ls"}
    }
  end

  def service_list
    {
      "ussd-vodafone-chennai-rotn" => 
      {
        "renderer-1" => {:server_name => "renderer-vodafone-chennai-rotn", :message => "USSD Renderer running on server one", :type => "renderer"},
        "renderer-2" => {:server_name => "renderer-vodafone-chennai-rotn-2", :message => "USSD Renderer running on server two", :type => "renderer"},
        "renderer-3" => {:server_name => "renderer-vodafone-chennai-rotn-3", :message => "USSD Renderer running on server three", :type => "renderer"},
        "smscd" => {:server_name => "ussd-vodafone-chennai-rotn", :message => "smscd service running on ussd server ", :type => "smscd"},
        "ussd" => {:server_name => "ussd-vodafone-chennai-rotn", :message => "USSD service running on ussd server", :type => "ussd"}
      }
    }
  end

  def server_details_for
    { 
      "ussd" => 
      {
        "ip" => "localhost",
        "port" => 22,
        "username" => "test",
        "password" => "test123" 
      }
    }
  end

end

class UssdController < ApplicationController
  def index
    @services = {
      "ussd-vodafone-chennai-rotn" => {
        :rederer_1 => [
                       'ussd-vodafone-renderer-1',
                       'ussd-vodafone-renderer-2',
                       'ussd-vodafone-renderer-3'
                      ],
        :smscd => ['smscd'],
        :ussd => ['ussd']
      }
    }
  end

  def start
  end

  def stop
  end

  def log
  end

end

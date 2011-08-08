require 'spec_helper'

describe UssdController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'start'" do
    it "should be successful" do
      get 'start'
      response.should be_success
    end
  end

  describe "GET 'stop'" do
    it "should be successful" do
      get 'stop'
      response.should be_success
    end
  end

  describe "GET 'log'" do
    it "should be successful" do
      get 'log'
      response.should be_success
    end
  end

end

require 'domain_service'
require 'test/unit'
require 'rack/test'

set :environment, :test

class DomainServiceTest < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
  
  def test_domain_is_valid_and_cached
    domains = [{:name=>'forniol.com',:response=>'WORKS'},
               {:name=>'forniol.cat',:response =>'WORKS'},
               {:name=>'forniol.net',:response =>'FAIL' },
               {:name=>'gmail.com',:response   =>'WORKS'},
               {:name=>'google.com',:response  =>'WORKS'},
               {:name=>'forniol.org',:response =>'FAIL' },
               {:name=>'beerapid.com',:response=>'FAIL' },
               {:name=>'beemailer',:response   =>'NOT A VALID DOMAIN: beemailer' },
               {:name=>'ricard@forniol.cat', :response  =>'WORKS'}]
    domains.each do |domain|
      puts "/validate/#{domain[:name]}"
      get "/validate/#{domain[:name]}"
      assert last_response.ok?
      assert_equal domain[:response], last_response.body
    end
  end
end
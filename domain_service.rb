require 'rubygems'
require 'sinatra'
require 'haml'
require 'net/dns/resolver'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'yaml'

config = YAML.load_file('config/database.yml')
#p config[Sinatra::Application.environment.to_s]

DataMapper.setup(:default, config[Sinatra::Application.environment.to_s])
 

#DataMapper.setup(:default, :adapter => 'mysql',:user => 'root', :database => 'cache_domains',:socket => '/opt/local/var/run/mysql5/mysqld.sock')
#DataMapper.setup(:default, "appengine://auto") #Not working yet
class DomainCache
  include DataMapper::Resource

  property :id,         Serial
  property :domain,      String
  property :is_valid,      Boolean
  property :created_at, DateTime

  validates_is_unique :domain
end

#DataMapper.auto_migrate!
get '/' do
  redirect('/help')
end

get '/help' do
  haml :help
end

get '/validate/?:domain_name?' do |domain|
  fail
  case is_cached(domain)
  when true then
    works if @domain_cache.is_valid
  when false then
    if @domain
      cache_domain
      works if Net::DNS::Resolver.start(@domain, Net::DNS::MX).answer.size > 0
      @cache.save if @cache
    else
      @status = "NOT A VALID DOMAIN: #{domain}"
    end
  else
    @status = "NO DOMAIN NAME PASSED"
  end
  @status
end
get '/cached/?:domain_name?' do |domain|
  case is_cached(domain)
  when true then
    "YES"
  when false then
    "NO"
  else
    "NO DOMAIN NAME PASSED"
  end
end

get '/environment/?' do
  Sinatra::Application.environment.to_s
end
def fail
  @status = "FAIL"
end
def is_cached domain
  response = nil
  unless domain.nil?
    @domain = validate_domain_or_email domain
    response = false
    if @domain
      @domain_cache = DomainCache.first(:domain => @domain)
      response = true if @domain_cache
    end
  end
  response
end
def cache_domain
  @cache = DomainCache.new(:domain => @domain, :is_valid => false, :created_at => Time.now) if @domain
end

def works
  if @domain
    @status = "WORKS"
    @cache.is_valid = true if @cache
  else
    fail
  end
end

def validate_domain_or_email string
  domain_regex = /^([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}$/
  mail_regex = /^([0-9a-zA-Z]+[-._+&amp;])*[0-9a-zA-Z]+@(([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6})$/
  case false
    when domain_regex.match(string).nil? then
      @domain = string
    when mail_regex.match(string).nil? then
      @domain = mail_regex.match(string)[2]
    else
      nil
  end
end

__END__

@@ help
!!! Strict
%html
  %head  
    %title="Help"
  %body 
    %p Hi;

    %p These are the instructions to use this webservice.

    %p There are two basic commands used by URL.

    %h2 Validate
    %p This command validates the existance of a mail exchange (MX) record for given domain or email address.
    %blockquote 
      ='/validate/domain_name'
      %br/
      ='/validate/email_address'

    %h2 Cached
    %p This command queries the database in order to show if a domain name has been cached.
    %blockquote
      ='/cached/domain_name'
      %br/
      ='/cached/email_address'
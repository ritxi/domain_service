desc "Install gems that this app depends on. May need to be run with sudo."
task :install_dependencies do
  dependencies = {
    "sinatra"         => "0.9.4",
    "dm-core"         => "0.10.0",
    "dm-timestamps"   => "0.10.0",
    "dm-validations"  => "0.10.0",
    "do_mysql"        => "0.10.0",
    "net-dns"        => "0.5.3",
    "haml"            => "2.2.10"
    "thin"            => "any"
  }
  dependencies.each do |gem_name, version|
    puts "#{gem_name} #{version}"
    version = ''
    version = "--version #{version}" unless version == 'any'
    system "gem install #{gem_name} "
  end
end

desc "Execute test"
task :test do
  
end

appdir = Dir.pwd
namespace :thin do  
  desc "Stop The Application"
  task :stop do
    puts "Stopping The Application..."
    Dir.new("#{appdir}/tmp/pids").each do |file| 
      Thread.new do               
        prefix = file.to_s
        if prefix[0, 4] == 'thin'
          str  = "thin stop -P#{appdir}/tmp/pids/#{file} > /dev/null" 
          puts "Stopping server on port #{file[/\d+/]}..." 
          system(str)
        end
      end
    end
  end
  desc "Start The Application"
  task :start do
    unless ENV.include?("environment")
      ENV['environment'] = 'development'
      puts "Using development environment"
    end
    
    Thread.new do
      puts "Starting server/s"
      system "cat config/config_#{ENV['environment']}.yml > config/config.yml;
       cat config/config_common.yml >> config/config.yml;
       thin -C config/config.yml start > /dev/null"
      puts "Servers have been started"
    end
  end
  desc "Restart The Application"
  task :restart do
    Thread.new do
      puts "Restarting servers"
      system "thin -C config/config.yml restart > /dev/null"
      puts "Servers have been restarted"
    end
    puts ""
  end
end
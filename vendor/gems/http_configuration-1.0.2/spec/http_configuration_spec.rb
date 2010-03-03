require 'rubygems'
require 'spec'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'http_configuration'))

describe "Net::HTTP::Configuration" do
  
  it "should set the default configuration options" do
    config = Net::HTTP::Configuration.new(:proxy_host => 'localhost', :proxy_port => 8080, :no_proxy => ['local1', 'local2'])
    config[:proxy_host].should == 'localhost'
    config[:proxy_port].should == 8080
    config[:no_proxy].should == ['local1', 'local2']
  end
  
  it "should be able to get the proxy from the environment" do
    ENV.should_receive(:[]).with('HTTP_PROXY').and_return('localhost:80')
    ENV.should_receive(:[]).with('NO_PROXY').and_return('.local1, .local2')
    config = Net::HTTP::Configuration.new(:proxy => :environment)
    config[:proxy_host].should == 'localhost'
    config[:proxy_port].should == 80
    config[:proxy_user].should == nil
    config[:proxy_password].should == nil
    config[:no_proxy].should == ['.local1', '.local2']
  end
  
  it "should be able to parse the no_proxy option" do
    Net::HTTP::Configuration.new(:no_proxy => 'host')[:no_proxy].should == ['host']
    Net::HTTP::Configuration.new(:no_proxy => 'host1, host2')[:no_proxy].should == ['host1', 'host2']
    Net::HTTP::Configuration.new(:no_proxy => ['host3', 'host4'])[:no_proxy].should == ['host3', 'host4']
  end
  
  it "should be able to parse a proxy with user and password" do
    config = Net::HTTP::Configuration.new(:proxy => 'http://user:password@proxy.local:9000', :no_proxy => '.local1, .local2')
    config[:proxy_host].should == 'proxy.local'
    config[:proxy_port].should == 9000
    config[:proxy_user].should == 'user'
    config[:proxy_password].should == 'password'
    config[:no_proxy].should == ['.local1', '.local2']
    config[:proxy].should == nil
  end
  
  it "should be able to clear the proxy" do
    config = Net::HTTP::Configuration.new(:proxy => :none)
    config[:proxy_host].should == nil
    config[:proxy_port].should == nil
    config[:proxy_user].should == nil
    config[:proxy_password].should == nil
  end
  
  it "should be able to set a global configuration" do
    Net::HTTP::Configuration.set_global(:proxy_host => 'localhost', :proxy_port => 8080, :read_timeout => 5)
    Net::HTTP::Configuration.global[:proxy_host].should == 'localhost'
    Net::HTTP::Configuration.global[:proxy_port].should == 8080
    Net::HTTP::Configuration.global[:read_timeout].should == 5
    Net::HTTP::Configuration.set_global(nil)
    Net::HTTP::Configuration.global.should == nil
  end
  
  it "should be able to apply a configuration to a block" do
    Net::HTTP::Configuration.set_global(nil)
    config = Net::HTTP::Configuration.new(:proxy_host => "proxy#{rand(1000)}", :read_timeout => 30)
    retval = config.apply(:read_timeout => 5) do
      Net::HTTP::Configuration.current[:proxy_host].should == config[:proxy_host]
      Net::HTTP::Configuration.current[:read_timeout].should == 5
      :done
    end
    retval.should == :done
  end
  
  it "should be able to determine the current configuration" do
    Net::HTTP::Configuration.set_global(:proxy_host => 'global')
    config1 = Net::HTTP::Configuration.new(:proxy_host => 'config1')
    config2 = Net::HTTP::Configuration.new(:proxy_host => 'config2')
    
    Net::HTTP::Configuration.current[:proxy_host].should == 'global'
    config1.apply do
      Net::HTTP::Configuration.current[:proxy_host].should == 'config1'
      config2.apply do
        Net::HTTP::Configuration.current[:proxy_host].should == 'config2'
      end
      Net::HTTP::Configuration.current[:proxy_host].should == 'config1'
    end
    Net::HTTP::Configuration.current[:proxy_host].should == 'global'
    
    Net::HTTP::Configuration.set_global(nil)
    Net::HTTP::Configuration.current.should == nil
  end
  
  it "should be able to determine if a host does not require a proxy" do
    Net::HTTP::Configuration.no_proxy?('host.local', :no_proxy => ['host.local']).should == true
    Net::HTTP::Configuration.no_proxy?('host.local', :no_proxy => ['not_this_one', '.local']).should == true
    Net::HTTP::Configuration.no_proxy?('HOST.LOCAL', :no_proxy => ['.local']).should == true
    Net::HTTP::Configuration.no_proxy?('host.local', :no_proxy => ['.LOCAL']).should == true
    Net::HTTP::Configuration.no_proxy?('host.local', :no_proxy => ['other.host.local']).should == false
    Net::HTTP::Configuration.no_proxy?('external.host', :no_proxy => ['.local']).should == false
    Net::HTTP::Configuration.no_proxy?('external.host', :no_proxy => nil).should == false
  end
  
end

describe "Net::HTTP" do
  
  it "should work normally if no configuration has been set" do
    Net::HTTP.should_receive(:new_without_configuration).with('localhost', 80, nil, nil, nil, nil)
    Net::HTTP.new('localhost', 80)
  end
  
  it "should use proxy settings if they have been set" do
    config = Net::HTTP::Configuration.new(:proxy_host => 'proxy', :proxy_port => 8080, :proxy_user => 'user', :proxy_password => 'password')
    Net::HTTP.should_receive(:new_without_configuration).with('localhost', 80, 'proxy', 8080, 'user', 'password')
    config.apply do
      Net::HTTP.new('localhost', 80)
    end
  end
  
  it "should honor no_proxy hosts" do
    config = Net::HTTP::Configuration.new(:proxy_host => 'proxy', :proxy_port => 8080, :no_proxy => ['localhost'])
    Net::HTTP.should_receive(:new_without_configuration).with('localhost', 80, nil, nil, nil, nil)
    config.apply do
      Net::HTTP.new('localhost', 80)
    end
  end
  
  it "should honor proxies explicitly passed" do
    config = Net::HTTP::Configuration.new(:proxy_host => 'proxy', :proxy_port => 8080, :proxy_user => 'user', :proxy_password => 'password')
    Net::HTTP.should_receive(:new_without_configuration).with('localhost', 80, 'other_proxy', 9000, nil, nil)
    config.apply do
      Net::HTTP.new('localhost', 80, 'other_proxy', 9000)
    end
  end
  
  it "should set read_timeout from the configuration" do
    config = Net::HTTP::Configuration.new(:read_timeout => 7)
    config.apply do
      http = Net::HTTP.new('localhost', 80)
      http.read_timeout.should == 7
    end
  end
  
  it "should set open_timeout from the configuration" do
    config = Net::HTTP::Configuration.new(:open_timeout => 6)
    config.apply do
      http = Net::HTTP.new('localhost', 80)
      http.open_timeout.should == 6
    end
  end
  
end

describe "Net::BufferedIO" do
  
  it "should timeout without an interrupt" do
    io = Net::BufferedIO.new(StringIO.new)
    lambda do
      io.send(:timeout, 1){sleep(2)}
    end.should raise_error(Net::NetworkTimeoutError)
  end

end

describe "Net::Protocol" do
  
  it "should timeout without an interrupt" do
    http = Net::HTTP.new('localhost')
    lambda do
      http.send(:timeout, 1){sleep(2)}
    end.should raise_error(Net::NetworkTimeoutError)
  end
  
end

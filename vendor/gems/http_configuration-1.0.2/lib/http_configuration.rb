require 'net/protocol'
require 'net/http'

module Net

  class Protocol

    private

    # Default error type to a non-interrupt exception
    def timeout (secs, errorType = NetworkTimeoutError)
      super(secs, errorType)
    end

  end

  class BufferedIO

    private

    # Default error type to a non-interrupt exception
    def timeout (secs, errorType = NetworkTimeoutError)
      super(secs, errorType)
    end

  end

  # Error thrown by network timeouts
  class NetworkTimeoutError < StandardError
  end

  class HTTP

    class << self
      def new_with_configuration (address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil)
        config_options = Configuration.current
        if config_options
          if Configuration.no_proxy?(address, config_options)
            p_addr = nil
            p_port = nil
            p_user = nil
            p_pass = nil
          elsif p_addr.nil? and config_options[:proxy_host]
            p_addr = config_options[:proxy_host]
            p_port = config_options[:proxy_port].to_i
            p_user = config_options[:proxy_user]
            p_pass = config_options[:proxy_password]
          end
        end

        http = HTTP.new_without_configuration(address, port, p_addr, p_port, p_user, p_pass)

        if config_options
          http.open_timeout = config_options[:open_timeout] if config_options[:open_timeout]
          http.read_timeout = config_options[:read_timeout] if config_options[:read_timeout]
        end

        return http
      end

      alias_method :new_without_configuration, :new
      alias_method :new, :new_with_configuration

    end

    # The Configuration class encapsulates a set of HTTP defaults. The configuration
    # can made either global or all requests, or it can be applied only within a block.
    # Configuration blocks can also set an additional set of options which take precedence
    # over the initialization options.
    #
    # Available options are :proxy_host, :proxy_port, :proxy_user, :proxy_password, :no_proxy,
    # :read_timeout, :open_timeout, and :proxy. This last value can either contain a proxy string
    # or the symbol :none for no proxy or :environment to use the values in the HTTP_PROXY/http_proxy
    # and NO_PROXY/no_proxy environment variables.
    #
    # If you specify a proxy, but don't want it to be used for certain hosts, specify the domain names
    # in the :no_proxy option. This can either be an array or a comma delimited string. A request to a
    # host name which ends with any of these values will not be proxied.
    #
    # The normal functionality for Net::HTTP is still available, so you can set proxies
    # and timeouts manually if needed. Because of the way in which https calls are made, you cannot
    # configure a special proxy just for https calls.
    class Configuration

      def initialize (options = {})
        @default_options = options.dup
        expand_proxy_config!(@default_options)
      end

      # Get the specified option for the configuration.
      def [] (name)
        @default_options[name]
      end

      # Apply the configuration to the block. If any options are provided, they will override the default options
      # for the configuration.
      def apply (options = {})
        options = @default_options.merge(options)
        expand_proxy_config!(options)
        Thread.current[:net_http_configuration] ||= []
        Thread.current[:net_http_configuration].push(options)
        begin
          return yield
        ensure
          Thread.current[:net_http_configuration].pop
        end
      end

      def self.no_proxy? (host, options)
        return false unless options[:no_proxy].kind_of?(Array)

        host = host.downcase
        options[:no_proxy].each do |pattern|
          pattern = pattern.downcase
          return true if host[-pattern.length, pattern.length] == pattern
        end

        return false
      end

      # Set the options for a global configuration used for all HTTP requests. The global configuration can be cleared
      # by setting nil
      def self.set_global (options)
        if options
          @global = Configuration.new(options)
        else
          @global = nil
        end
      end

      def self.global
        @global
      end

      # Get the current configuration that is in scope.
      def self.current
        stack = Thread.current[:net_http_configuration]
        config = stack.last if stack
        config || global
      end

      private

      def expand_proxy_config! (options)
        proxy_config = options[:proxy]
        if proxy_config
          options.delete(:proxy)
          if proxy_config == :environment
            parse_proxy!(ENV['HTTP_PROXY'] || ENV['http_proxy'], options)
            options[:no_proxy] = ENV['NO_PROXY'] || ENV['no_proxy']
          elsif proxy_config == :none
            options[:proxy_user] = nil
            options[:proxy_password] = nil
            options[:proxy_host] = nil
            options[:proxy_port] = nil
            options[:no_proxy] = nil
          else
            parse_proxy!(proxy_config, options)
          end
        end
        parse_no_proxy!(options[:no_proxy], options)
      end

      def parse_proxy! (proxy, options)
        return unless proxy and proxy.length > 0
        proxy_info = /(http:\/\/)?(([^:]+):([^@]+)@)?([^:]+)(:(\d+))?/i.match(proxy)
        if proxy_info
          options[:proxy_user] = proxy_info[3]
          options[:proxy_password] = proxy_info[4]
          options[:proxy_host] = proxy_info[5]
          options[:proxy_port] = proxy_info[7].to_i if proxy_info[7]
        end
      end

      def parse_no_proxy! (no_proxy, options)
        return unless no_proxy and no_proxy.length > 0
        if no_proxy.kind_of?(Array)
          options[:no_proxy] = no_proxy.dup
        else
          options[:no_proxy] = no_proxy.split(/\s*,\s*/)
        end
      end
    end

  end

end

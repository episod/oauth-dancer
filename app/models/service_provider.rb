class ServiceProvider < ActiveRecord::Base
  has_many :access_tokens, :dependent => :destroy, :order => "created_at ASC"
  validates_uniqueness_of :label, :on => :create, :message => "must be unique"
  validates_presence_of :label, :on => :create, :message => "can't be blank"
  validates_presence_of :consumer_key, :on => :create, :message => "can't be blank"
  
  def uri_objects
    {
      :request_token_uri => URI.parse(self.request_token_url), 
      :access_token_uri => URI.parse(self.access_token_url),
      :authorize_uri => URI.parse(self.authorize_url)
    }
  end
  
  def base_host
    host = uri_objects[:request_token_uri].scheme + "://" + uri_objects[:request_token_uri].host 
    unless [80, 443].include?(uri_objects[:request_token_uri].port)
      host = host + ":" + uri_objects[:request_token_uri].port.to_s
    end
    host
  end
  
  def request_token_host
    uri_objects[:request_token_uri].host
  end
  
  def request_token_path
    uri_objects[:request_token_uri].path
  end
  
  def authorize_host
    uri_objects[:authorize_uri].host
  end
  
  def authorize_path
    uri_objects[:authorize_uri].path
  end
  
  def access_token_host
    uri_objects[:access_token_uri].host
  end
  
  def access_token_path
    uri_objects[:access_token_uri].path
  end
  
  def to_oauth_consumer(options = {})
    OAuth::Consumer.new(self.consumer_key, self.consumer_secret, self.options_for_consumer(options))
  end
  
  def get_request_token(oauth_callback, options = {})
    consumer = self.to_oauth_consumer(options)
    request_token = consumer.get_request_token({:oauth_callback => oauth_callback})
    return request_token
  end
  
  def exchange_request_token_for_access_token(request_token, oauth_verifier)
    access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    return access_token
  end
  
  def to_two_legged_token(consumer = nil)
    if !consumer
      consumer = self.to_oauth_consumer
    end
    OAuth::TwoLeggedMockToken.new(consumer)
  end
  
  def autentication_http_method
    if self.use_post_for_authentication_steps?
      return :post
    else
      return :get
    end
  end
  
  def authentication_scheme
    scheme = self.oauth_scheme
    if scheme
      return scheme.to_sym
    else
      return :header
    end
  end
  
  def options_for_consumer(override_options = {})
    {
      :signature_method   => 'HMAC-SHA1',
      :site => self.base_host,
      :request_token_path => self.request_token_path,
      :authorize_path     => self.authorize_path,
      :access_token_path  => self.access_token_path,
      :scheme        => self.authentication_scheme,
      :http_method   => self.autentication_http_method,
      :oauth_version => self.oauth_version || "1.0"
    }.merge(override_options)
  end
  
end





# == Schema Information
#
# Table name: service_providers
#
#  id                                :integer         not null, primary key
#  label                             :string(255)
#  note                              :text
#  consumer_key                      :string(255)
#  consumer_secret                   :string(255)
#  request_token_url                 :string(255)
#  authorize_url                     :string(255)
#  access_token_url                  :string(255)
#  oauth_version                     :string(255)     default("1.0")
#  default_response_content_type     :string(255)     default("application/x-www-form-urlencoded; charset=utf-8")
#  default_request_content_type      :string(255)     default("application/x-www-form-urlencoded; charset=utf-8")
#  oauth_scheme                      :string(255)     default("header")
#  use_out_of_band                   :boolean         default(FALSE)
#  use_post_for_authentication_steps :boolean         default(TRUE)
#  created_at                        :datetime
#  updated_at                        :datetime
#  use_xauth                         :boolean         default(FALSE)
#


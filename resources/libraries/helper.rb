module Nginx
  module Helper
    require 'net/ip'
    require 'openssl'
    require 'resolv'
    def local_routes()
      # return all local routes that exist in the system
      routes = []
      Net::IP.routes.each do |r|
      	next if routes.include?(r.to_h[:prefix])
      	next if r.to_h[:scope].nil? or r.to_h[:scope] != "link"
      	routes.push(r.to_h[:prefix])
      end
      routes
    end
    def create_cert(cn)
      # Return a hash with private key and certificate in x509 format
    	key = OpenSSL::PKey::RSA.new 4096
    	name = OpenSSL::X509::Name.parse "CN=#{cn}/DC=redborder"
    	cert = OpenSSL::X509::Certificate.new
    	cert.version = 2
    	cert.serial = 0
    	cert.not_before = Time.now
    	cert.not_after = Time.now + (3600 *24 *365 *10)
    	cert.public_key = key.public_key
    	cert.subject = name
    	extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert
    	cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE', true)
    	cert.add_extension extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
    	cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')
    	cert.issuer = name
    	cert.sign key, OpenSSL::Digest::SHA1.new
      { :key => key, :crt => cert}
    end
    def check_webui_service()
      # check if webui.service can be resolved (in other words, registered as a service in consul)
      address = nil
      begin
        address = Resolv.getaddress("webui.service")
      rescue
        address = false
      end
      address
    end
  end
end

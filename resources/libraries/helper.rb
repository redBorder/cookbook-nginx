module Nginx
  module Helper
  	require 'net/ip'
  	require 'openssl'
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
    	#open "/etc/nginx/ssl/#{filename}.crt", 'w' do |io|
        #	io.write cert.to_pem
    	#end
    	#open "/etc/nginx/ssl/#{filename}.key", 'w' do |io|
        #	io.write key.to_pem
    	#end
    	#open "/etc/nginx/ssl/#{filename}_public_key.pem", 'w' do |io|
    	#	io.write key.public_key.to_pem
      	#end
      	{ :key => key, :crt => cert}
    end
  end
end

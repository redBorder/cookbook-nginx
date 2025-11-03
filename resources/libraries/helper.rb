module Nginx
  module Helper
    require 'openssl'
    require 'resolv'
    require 'base64'
    require 'securerandom'

    def create_cert(cn)
      # Return a hash with private key and certificate in x509 format
      # Certificates only for s3
      key = OpenSSL::PKey::RSA.new 4096
      name = OpenSSL::X509::Name.parse("CN=#{cn}")
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(2**128)
      cert.not_before = Time.now
      cert.not_after = Time.now + (3600 * 24 * 365 * 10)
      cert.public_key = key.public_key
      cert.subject = name
      cert.issuer = name
      if cn.start_with?('s3.')
        san_list = [
          "DNS:redborder.#{cn}",
          "DNS:rbookshelf.#{cn}",
          "DNS:malware.#{cn}",
          "DNS:#{cn.sub('s3', 's3.service')}",
          "DNS:#{cn}",
        ].join(',')
        extension_factory = OpenSSL::X509::ExtensionFactory.new
        extension_factory.subject_certificate = cert
        extension_factory.issuer_certificate = cert
        cert.add_extension(extension_factory.create_extension('subjectAltName', san_list, false))
      end
      cert.sign key, OpenSSL::Digest.new('SHA256')
      { key: key, crt: cert }
    end

    def create_json_cert(app, cdomain)
      ret_json = { 'id' => app }
      cert_hash = create_cert("#{app}.#{cdomain}")
      ret_json["#{app}_crt"] = Base64.urlsafe_encode64(cert_hash[:crt].to_pem)
      ret_json["#{app}_key"] = Base64.urlsafe_encode64(cert_hash[:key].to_pem)
      ret_json
    end

    def nginx_certs(app, cdomain)
      ret_json = {}

      # Check if certs exists in a data bag
      begin
        nginx_cert_item = data_bag_item('certs', app)
      rescue
        nginx_cert_item = {}
      end

      if nginx_cert_item.empty?
        unless File.exist?("/var/chef/data/data_bag/certs/#{app}.json")
          # Create S3 certificate
          ret_json = create_json_cert(app, cdomain)
          system('mkdir -p /var/chef/data/data_bag/certs')
          File.write("/var/chef/data/data_bag/certs/#{app}.json", ret_json.to_json)
        end
        # Upload cert to data bag
        if File.exist?('/root/.chef/knife.rb')
          system("knife data bag from file certs /var/chef/data/data_bag/certs/#{app}.json")
        else
          Chef::Log.warn('knife command not available, certs databag wont be uploaded')
        end
      else
        ret_json = nginx_cert_item
      end
      ret_json
    end

    # This function will be used to get the cdomain for the action add_s3,
    # which is only executed early in installation, where node is not available yet.
    def get_cdomain
      if node.dig('redborder', 'cdomain')
        node['redborder']['cdomain']
      elsif File.exist?('/etc/redborder/cdomain')
        File.read('/etc/redborder/cdomain').strip
      else
        'redborder.cluster'
      end
    end
  end
end

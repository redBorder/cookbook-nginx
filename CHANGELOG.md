cookbook-nginx CHANGELOG
===============

## 1.3.4

  - jnavarrorb
    - [1458019] Remove executable permissions on non-executable files

## 1.3.3

  - nilsver
    - [06b08f6] remove flush cache

## 1.3.2

  - nilsver
    - [a84ef3a] get cdomain for first chef solo run
    - [e463207] fix bug upon installation with add_s3
    - [6458bb8] add erchef and s3 cdomain
    - [1cba240] add erchef.service.cdomain

## 1.3.1

  - Rafael Gomez
    - [6dc572d] Fix server_name configuration in http2k.conf.erb to correctly reference the domain

## 1.2.3

  - Pablo Torres
    - [a05ef5b] Bugfix #18588: Only redirect to webui if it is a proxy or a ips
    - [000ccab] Bugfix #18588: Only redirect to webui if the command executed is Knife
    - [4b140b3] Bugfix #18588: Change nginx to redirect to webui

## 1.2.2

  - Miguel Negrón
    - [0fcac9d] Merge pull request #19 from redBorder/feature/18969_ip_identifier
  - Miguel Alvarez
    - [dda2601] Allow all requests on outliers api

## 1.2.1

  - nilsver
    - [42b410b] add user in relevant action blocks

## 1.2.0

  - Miguel Negrón
    - [4435c11] Merge pull request #15 from redBorder/bugfix/#19144_missing_nginx_confd_files
  - David Vanhoucke
    - [524bf9d] remove files if service disabled
  - Miguel Negron
    - [fcbbde2] erchef_hosts
    - [26ab787] Add balancing

## 1.0.2

  - Miguel Negrón
    - [76275bf] Add pre and postun to clean the cookbook

## 1.0.1

  - Miguel Alvarez
    - [dfbf9d0] generate random 128 bit serial

## 1.0.0

  - malvads
    - [e5b2a9b] Fix lint
    - [dd1b692] Update config.rb
    - [ded1a47] Update s3.conf.erb
    - [08dbca5] Add back s3
    - [6880cbd] Remove add s3 from configure solo
    - [95d5155] Configure Minio Load Balancer
    - [dd1b692] Update config.rb
    - [ded1a47] Update s3.conf.erb

## 0.0.8
  - Miguel Negrón
    - [717936a] lint avoid use constants for OpenSSL
    - [7d575d6] lint file.write instead of file.open
    - [fc2b48b] lint resources 2
    - [1862ff6] lint solo
    - [4311a8a] lint providers 2
    - [7720b9b] lint helper
    - [b4fdc17] lint providers
    - [b0618e1] lint resources
    - [2b065d7] lint recipes
    - [b12293f] lint attributes
    - [42a9d18] Update metadata.rb

This file is used to list changes made in each version of the nginx cookbook.

0.0.7
-----
- [malvarez]
  - Configure rb-aioutliers service 


0.0.1
-----
- [cjmateos]
  - fc33df3 Fix in ADD action fo config resource

- [jjprieto]
  - 781cd56 check if webui service is regitered in consul
  - 5d35fa0 fix template missing from other cookbook
  - 9e9e552 improve remove action in providers
  - 85b63b5 add certificate from databag and improve spec
  - 03dbd77 skel creation
  - 9e8d179 Initial commit

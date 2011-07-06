# Class: openssh::server
#
# This class installs openssh
#
# Parameters:
#
# Actions:
#  - Install openssh
#  - Manage openssh service
#
# Requires:
#
# Sample Usage:
#
#    node host1.fqdn {
#        $ssh_port = 2222
#        $ssh_pubkeyauthentication = yes
#        $ssh_permitemptypasswords = no
#        include openssh::server
#    }
#
class openssh::server {
    class install {
        package {
            "openssh-server":
                ensure => present;
            "openssh-client":
                ensure => present;
            "openssh-blacklist":
                ensure => present;
        }
    }

    class config {
        file { 
            "/etc/ssh":
                ensure  => directory,
                owner   => root,
                group   => root,
                mode    => 700,
                require => Class["install"];

            "/etc/ssh/sshd_config":
                ensure  => present,
                owner   => root,
                group   => root,
                mode    => 600,
                content => template ("openssh/sshd_config.erb");
        }

        # Optional:
        
        #logrotate::file { "auth":
        #   source => "/etc/logrotate.d/auth",
        #   log    => "/var/log/auth.log",
        #}
    }

    class service {
        service { "ssh":
            enable     => true,
            ensure     => running,
            hasrestart => true,
            hasstatus  => true,
            require    => Class["config"],
        }
    }

    include openssh::server::install
    include openssh::server::config
    include openssh::server::service
    
    Class["openssh::server::install"] -> Class["openssh::server::config"] -> Class["openssh::server::service"]
}
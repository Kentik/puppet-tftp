# == Class: tftp::server
#
# Simple class to ensure the tftpd server package is installed
#
# === Parameters
#
# [*address*]
#   IP address to bind the daemon process to.
#   default: 0.0.0.0:69
#
# [*ensure*]
#   Used to control the install and configuration or the
#   clean up and unstinall of the tftpd server.
#   default: present
#
# [*create*]
#   Allow new files to be created.  By default, tftpd will only allow upload
#   of files that already exist.  Files are created with default permissions
#   allowing anyone to read or write them, unless the permissive or umask
#   options are specified.
#   default: false
#
# [*listen*]
#   Run the server in standalone (listen) mode, rather than run from inetd.
#   In listen mode, the timeout option is ignored, and the address option
#   can be used to specify a specific local address or port to listen to.
#   default: true
#
# [*permissive*]
#   Perform no additional permissions checks above the normal system-provided
#   access controls.  When set to false, files and directories in tftproot
#   must be world-readable.
#   default: true
#
# [*secure*]
#   Change root directory on startup.  This means the remote host does not need
#   to pass along the directory as part of the transfer, and may add security.
#   When secure is true, exactly one tftproot directory should be specified.
#   The use of this option is recommended for security as well as compatibility
#   with some boot ROMs which cannot be easily made to include a directory name
#   in its request.
#   default: true             
#
# [*timeout*]
#   When run from inetd this specifies how long, in seconds, to wait for a
#   second connection before terminating the server.  inetd will then respawn
#   the server when another request comes in.  
#   default: 900 (15 minutes)
#
# [*tftproot*]
#   The directory that tftp content will be served from.
#
# [*umask*]
#   Sets the umask for newly created files to the specified value.
#   default: 377 (owner read-only)
#
# [*verbosity*]
#   Set the logging verbosity value.
#   default: 3
#
# === Variables
#
# [*defaults_config_file*]
#   Full path to the defaults file used when starting the tftp daemon
#
# [*group*]
#   Group ID to use for file and directory ownership
#
# [*rc2file*]
#   Full path to the rc2.d file used to test if the tftp service is enabled
#
# [*server_package*]
#   Name of the tftp server package
#
# [*service_restart_command*]
#   Command used to restart the tftp service
#
# [*service_start_command*]
#   Command used to start the tftp service
#
# [*service_status_command*]
#   Command used to get the status of the tftp service
#
# [*service_stop_command*]
#   Command used to stop the tftp service
#
# [*mapfile*]
#   Name of the mapfile
#
# [*user*]
#   User ID to use for file and directory ownership
#
# === Examples
#
#   class { 'tftp::server':
#       ensure     => 'present',
#       address    => '0.0.0.0:69',
#       create     => true,
#       listen     => true,
#       permissive => true,
#       secure     => true,
#       umask      => '007',
#       verbosity  => 3,
#       tftproot   => '/srv/tftp',
#   }
#
# === Supported Operating Systems
#
#   * CentOS
#   * Debian
#   * Fedora
#   * RedHat
#   * Ubuntu
#
# === Authors
#
#   Bennett Samowich <bennett@foolean.org>
#
# === Copyright
#
#   Copyright (c) 2013 Foolean.org
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
class tftp::server (
    $address    = '0.0.0.0:69',
    $create     = false,
    $ensure     = 'present',
    $listen     = true,
    $permissive = true,
    $secure     = true,
    $timeout    = '900',
    $tftproot   = '/srv/tftp',
    $umask      = '377',
    $verbosity  = 3,
)
{
    # Set the user for file ownership
    $user = $::operatingsystem ? {
        'centos' => 'tftp',
        'debian' => 'tftp',
        'fedora' => 'tftp',
        'redhat' => 'tftp',
        'ubuntu' => 'tftp',
        default  => 'root',
    }

    # Set the group for file ownership
    $group = $::operatingsystem ? {
        'centos'  => 'tftp',
        'debian'  => 'tftp',
        'fedora'  => 'tftp',
        'freebsd' => 'wheel',
        'openbsd' => 'wheel',
        'redhat'  => 'tftp',
        'ubuntu'  => 'tftp',
        default   => 'root',
    }

    # Set the name of the tftp package to install
    $server_package = $::operatingsystem ? {
        'centos' => 'tftp-server',
        'debian' => 'tftpd-hpa',
        'fedora' => 'tftp-server',
        'redhat' => 'tftp-server',
        'ubuntu' => 'tftpd-hpa',
        default  => '',
    }

    # Set the name of the daemon defaults file
    $defaults_config_file = $::operatingsystem ? {
        'centos' => '/etc/sysconfig/tftpd-hpa',
        'debian' => '/etc/default/tftpd-hpa',
        'fedora' => '/etc/sysconfig/tftpd-hpa',
        'redhat' => '/etc/sysconfig/tftpd-hpa',
        'ubuntu' => '/etc/default/tftpd-hpa',
        default  => false,
    }

    # Set the name of the init script
    $service_init_script = $::operatingsystem ? {
        'centos' => '/etc/init.d/tftpd-hpa',
        'debian' => '/etc/init.d/tftpd-hpa',
        'fedora' => '/etc/init.d/tftpd-hpa',
        'redhat' => '/etc/init.d/tftpd-hpa',
        'ubuntu' => '/etc/init.d/tftpd-hpa',
        default  => false,
    }

    # Set the name of the init script template
    $service_init_script_template = $::operatingsystem ? {
        'centos' => '/etc/init.d/tftpd-hpa.rh',
        'debian' => '/etc/init.d/tftpd-hpa.deb',
        'fedora' => '/etc/init.d/tftpd-hpa.rh',
        'redhat' => '/etc/init.d/tftpd-hpa.rh',
        'ubuntu' => '/etc/init.d/tftpd-hpa.deb',
        default  => false,
    }

    # Service status command
    $service_status_command = $::operatingsystem ? {
        default => '/etc/init.d/tftpd-hpa status',
    }

    # Service start command
    $service_start_command = $::operatingsystem ? {
        'ubuntu' => 'service tftpd-hpa start',
        default  => '/etc/init.d/tftpd-hpa start',
    }

    # Service stop command
    $service_stop_command = $::operatingsystem ? {
        'ubuntu' => 'service tftpd-hpa stop',
        default  => '/etc/init.d/tftpd-hpa stop',
    }

    # Service restart command
    $service_restart_command = $::operatingsystem ? {
        'ubuntu' => 'service tftpd-hpa restart',
        default  => '/etc/init.d/tftpd-hpa restart',
    }

    # Path to the rc2.d file
    $rc2file = $::operatingsystem ? {
        'debian' => '/etc/rc2.d/K01tftpd-hpa',
        'ubuntu' => '/etc/rc2.d/K01tftpd-hpa',
        default  => '',
    }

    # Set the name of the mapfile to use
    $mapfile = 'remap'

    # Fail if we aren't configured for this operating system
    if ( ! $server_package ) {
        fail( "Unknown OS '${::operatingsystem}', unable to select packages" )
    }

    case $ensure {
        'present': {
            # Install the package
            package { 'tftpd-package':
                ensure => 'latest',
                name   => $server_package,
            }

            # Ensure the daemon group exists
            group { $group:
                ensure  => 'present',
                require => Package['tftpd-package'],
            }

            # Ensure the daemon user exists
            user { $user:
                ensure  => 'present',
                comment => 'tftp daemon',
                gid     => $group,
                home    => $tftproot,
                shell   => '/bin/false',
                require => Group[$group],
            }

            # Configure the default file
            if ( $defaults_config_file ) {
                file { $defaults_config_file:
                    mode    => '0444',
                    owner   => 'root',
                    group   => 'root',
                    content => template( "${module_name}/${defaults_config_file}" ),
                    notify  => Service['tftp-service'],
                    require => Package['tftpd-package']
                }
            }

            # Make sure the tftproot exists
            if ( $create ) {
               $tftproot_mode = '0600'
            } else {
               $tftproot_mode = '0400'
            }
            file { $tftproot:
                ensure  => 'directory',
                owner   => $user,
                group   => $group,
                mode    => $tftproot_mode,
                recurse => true,
                require => [
                    Package['tftpd-package'],
                    User[$user],
                    Group[$group],
                ],
            }

            # Copy in the init script
            file { $service_init_script:
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0755',
                content => inline_template(
                    file (
                        "${settings::modulepath}/${module_name}/templates/${$service_init_script_template}"
                    )
                ),
                require => Package['tftpd-package'],
            }

            # Copy in the mapfile
            file { "${tftproot}/${mapfile}":
                ensure  => 'present',
                owner   => $user,
                group   => $group,
                mode    => '0400',
                content => inline_template(
                    file (
                        "${settings::modulepath}/${module_name}/templates/${tftproot}/${mapfile}",
                        "${settings::modulepath}/../private/${fqdn}/${tftproot}/${mapfile}",
                        "${settings::vardir}/private/${fqdn}/${tftproot}/${mapfile}"
                    )
                ),
                require => [
                    File[$tftproot],
                    Package['tftpd-package'],
                    User[$user],
                    Group[$group],
                ],
            }

            # The package enables inetd, which we typically don't want.
            # Nevertheless, we'll use the listen parameter to determine
            # the desired state of the daemon and inetd.
            if ( $listen ) {
                # We'll start the daemon if we're not running inetd
                $service_state = 'running'

                case $::operatingsystem {
                    'centos','fedora','redhat': {
                        exec { 'configure-tftpd-inetd':
                            path    => [ '/bin', '/usr/bin/', '/sbin' ],
                            command => '/sbin/chkconfig tftp off',
                            unless  => [ 'test `chkconfig --list | grep -c "tftp:.*off"` -eq 1' ],
                            require => Package['tftpd-package'],
                        }
                    }
                    'debian', 'ubuntu': {
                        exec { 'configure-tftpd-inetd':
                            path    => [ '/usr/bin/', '/usr/sbin' ],
                            command => '/usr/sbin/update-inetd --disable tftp',
                            onlyif  => [ '/usr/bin/test -f /etc/inetd.conf && /usr/bin/test -f /usr/sbin/update-inetd' ],
                            require => Package['tftpd-package'],
                        }
                    }
                }
            } else {
                # We'll stop the daemon if we're running inetd
                $service_state = 'stopped'

                case $::operatingsystem {
                    'centos','fedora','redhat': {
                        exec { 'configure-tftpd-inetd':
                            path    => [ '/bin', '/usr/bin/', '/sbin' ],
                            command => '/sbin/chkconfig tftp on',
                            unless  => [ 'test `chkconfig --list | grep -c "tftp:.*on"` -eq 1' ],
                            require => Package['tftpd-package'],
                        }
                    }
                    'debian', 'ubuntu': {
                        exec { 'configure-tftpd-inetd':
                            path    => [ '/usr/bin/', '/usr/sbin' ],
                            command => '/usr/sbin/update-inetd --enable tftp',
                            onlyif  => [ '/usr/bin/test -f /etc/inetd.conf && /usr/bin/test -f /usr/sbin/update-inetd' ],
                            require => Package['tftpd-package'],
                        }
                    }
                }
            }

            # Reload the service if the configuration changed
            service { 'tftp-service':
                ensure  => $service_state,
                name    => 'tftpd-hpa',
                start   => $service_start_command,
                stop    => $service_stop_command,
                status  => $service_status_command,
                require => [
                    Package['tftpd-package'],
                    Exec['configure-tftpd-inetd'],
                    File[$defaults_config_file],
                    File[$tftproot],
                    File[$service_init_script],
                    User[$user],
                    Group[$group],
                ],
            }
        }

        'absent': {
            # Stop the service
            service { 'tftp-service':
                ensure => 'stopped',
                enable => false,
                name   => 'tftpd-hpa',
                start   => $service_start_command,
                stop    => $service_stop_command,
                status  => $service_status_command,
            }

            # Remove the defautlts file
            file { $defaults_config_file:
                ensure  => 'absent',
                before  => Package['tftpd-package'],
                require =>  Service['tftp-service'],
            }

            # Remove the init file
            file { $service_init_script:
                ensure  => 'absent',
                before  => File[$tftproot],
                require =>  Service['tftp-service'],
            }

            # Remove the tftproot
            file { $tftproot:
                ensure  => 'absent',
                force   => true,
                before  => Package['tftpd-package'],
                require =>  Service['tftp-service'],
            }

            # Remove the package
            package { 'tftpd-package':
                ensure  => 'purged',
                name    => $server_package,
                require =>  Service['tftp-service'],
            }

            # Remove the daemon user
            user { $user:
                ensure  => 'absent',
                require => Package['tftpd-package'],
            }

            # Remove the daemon group
            group { $group:
                ensure  => 'absent',
                require => [
                    Package['tftpd-package'],
                    User[$user],
                ],
            }
        }

        default: {
            fail( 'ensure must be "absent" or "present"' )
        }
    }
}

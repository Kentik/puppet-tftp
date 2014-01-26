# == Class: tftp::client
#
# Simple class to ensure the tftpd client package is installed
#
# === Parameters
#
# [*ensure*]
#   Used to control the install and configuration or the
#   clean up and unstinall of the tftpd client.
#   default: present
#
# === Variables
#
# [*client_package*]
#   The name of the tftp client package to install.
#
# === Examples
#
#   class { 'tftp::client': }
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
class tftp::client (
    $ensure = 'present',
)
{
    # Set the name of the tftp client package to install
    $client_package = $::operatingsystem ? {
        'centos'   => 'tftp',
        'debian'   => 'tftp-hpa',
        'fedora'   => 'tftp',
        'redhat'   => 'tftp',
        'opensuse' => 'tftp',
        'ubuntu'   => 'tftp-hpa',
        default    => false,
    }

    # Fail if we aren't configured for this operating system
    if ( ! $client_package ) {
        fail( "Unknown OS '${::operatingsystem}', unable to select package" )
    }

    case $ensure {
        'present': {
            # Install the package
            package { 'tftp-client-package':
                ensure => 'latest',
                name   => $client_package,
            }
        }

        'absent': {
            # Remove the package
            package { 'tftp-client-package':
                ensure => 'purged',
                name   => $client_package,
            }
        }

        default: {
            fail( 'ensure must be "absent" or "present"' )
        }
    }
}

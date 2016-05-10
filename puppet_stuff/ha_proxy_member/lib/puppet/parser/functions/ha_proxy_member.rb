#
# ha_proxy_member.rb

module Puppet::Parser::Functions
  newfunction(:ha_proxy_member, :type => :rvalue, :doc => <<-EOS
    This function will take a hash, for example:
    puppet db_query query_facts("Class[role::${loadbalanced_role}]", [ 'hostname', 'ipaddress' ])
      $ods_nodes = { "server1.com" =>
        {
          'hostname'  => ha_member1,
          'ipaddress' => 192.168.1.1,
        }
      "server2.com" =>
        {
          'hostname'  => ha_member2,
          'ipaddress' => 192.168.1.1,
        }
      }
    and return a hash of ordered arrays:
    ha_members {servers => ['ha_member1', 'ha_member2'], ipaddresses => [192.168.1.1, 192.168.1.2]}
    These can then be accessed from your module:
      $ha_members = ha_members($hash_of_nodes)
      $server_names = $ha_members['servers']
      $ipaddresses  = $ha_members['ipadresses']
  EOS
  ) do |arguments|
    # Only 1 argument should be passed
    raise(Puppet::ParseError, "reduce_arguments(): Wrong number of arguments " + "given (#{arguments.size} for 1)") if arguments.size != 1

    # The argument should be a Hash
    raise(Puppet::ParseError, "reduce_arguments() accepts a Hash, you passed a " + arguments[0].class) if arguments[0].class != Hash

    ha_members = Hash.new
    array_hostname  = Array.new
    array_ipaddress = Array.new

    arguments[0].each do |key, value|
      value.each do |key2, value2|
        if key2 == 'hostname'
          array_hostname << value2
        elsif key2 == 'ipaddress'
          array_ipaddress << value2
        else
          raise(Puppet::ParseError, "Hash does not contain valid key/value pairs")
        end
      end
    end
    ha_members['servers'] = array_hostname
    ha_members['ipaddresses'] = array_ipaddress
    return ha_members
  end
end
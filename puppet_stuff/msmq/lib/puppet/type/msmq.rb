# lib/puppet/type/msmq.rb

Puppet::Type.newtype(:msmq) do
  @doc = %q{Custom type to manage MSMQ.
    Will create and destroy a queue based on the queue name.
    Will update permissions to allow or deny FullControl for a paricular queue.
    Cavets:
    1. Will allow and deney permissions for the same user, deny takes precedence.
    2. Only available for Private queues types
    3. Only available for FullControl
    4. Do not deny "Everyone" will render queue unaccessible
    5. User must exist on system beore adding

    Future Enhancement:
    1. Use a hash to allow more fine grained control for allow and deny ACLs
      e.g. acl_allow => {user => [Read, Write, Peek]}
    2. Allow for Private and Public queue types
    3. Use Set and Revoke for permissions.  Allow / deny only append values.
    4. More / imprved validation

    Usage:
      msmq { 'queue':
        acl_allow => [ 'NT Authority\Network Service', 'Builtin\Administrators' ],
        acl_deny  => [ 'hostname\user' ],
      }
  }

  ensurable

  newparam(:name, :namevar => true) do
    isnamevar
    desc "The Queue Name"
  end

  newproperty(:acl_allow, :array_matching => :all) do
    desc "Manage MSMQ Allowed List of ACLs - usernames must exist on system. Deny will take precedence"

    def insync?(is)
      is.collect(&:downcase).sort == should.collect(&:downcase).sort
    end
  end

  newproperty(:acl_deny, :array_matching => :all) do
    desc "Manage MSMQ Denied List of ACLs - usernames must exist on system. Deny will take precedence"

    def insync?(is)
      is.collect(&:downcase).sort == should.collect(&:downcase).sort
    end
  end
end
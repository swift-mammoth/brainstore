Puppet::Type.type(:msmq).provide(:msmq) do

  desc <<-EOT
    User PowerShell cmdlets to manage MSMQ.
  EOT

  confine    :operatingsystem => :windows
  confine    :feature         => :msmq_cmdlets
  defaultfor :operatingsystem => :windows

  commands :powershell => "PowerShell.exe"

  def create
    Puppet.info "Create MSMQ Queue #{@resource[:name]} with acl #{@resource[:acl_allow]}"
    params = ["New-MsmqQueue -QueueType Private -Name #{resource[:name]} -Transactional"]
    powershell(params)
    set_acls(resource[:acl_allow], "allow" ) unless resource[:acl_allow].nil?
    set_acls(resource[:acl_deny], "deny" ) unless resource[:acl_deny].nil?
  rescue => detail
    raise Puppet::Error.new("Error Create MSMQ Queue for #{@resource[:name]}. Error is #{detail}", detail)
  end

  def destroy
    Puppet.info "Destroy MSMQ Queue #{@resource[:name]}"
    params = ["Get-MsmqQueue -QueueType Private -Name #{resource[:name]} | Remove-MsmqQueue"]
    powershell(params)
  rescue => detail
    raise Puppet::Error.new("Error Create MSMQ Queue for #{@resource[:name]}. Error is #{detail}", detail)
  end

  def exists?
    queue = get_queue(resource[:name])
    result = queue.include?("private$\\#{resource[:name]}")
    return result
  end

  def acl_allow
    get_acls(resource[:acl_allow], "allow")
  end

  def acl_deny
    get_acls(resource[:acl_deny], "deny")
  end

  def acl_allow=(acl)
    set_acls(acl, "allow")
  end

  def acl_deny=(acl)
    set_acls(acl, "deny")
  end

  def get_queue(name)
    begin
      params = ["Get-MsmqQueue -QueueType Private -Name #{name}"]
      queue = powershell(params)
      Puppet.debug "MSMQ Get Queue params #{params}"
      Puppet.debug "MSMQ Get Queue queue #{queue}"
    rescue => detail
      raise Puppet::Error.new("Error calling get_queue for #{name}. Error is #{detail}", detail)
      return nil
    end
    return queue
  end

  def get_acls(acl, grant)
    Puppet.debug "User #{acl} has #{grant} FullControl on Queue #{@resource[:name]}"
    all_acls = Array.new
    acl.each do |user|
      begin
        params = ["(Get-MsmqQueue -QueueType Private -Name #{resource[:name]} | Get-MsmqQueueACL | Where Access -eq #{grant} | Where Right -eq FullControl | Where AccountName -eq \'#{user}\').AccountName"]
        Puppet.debug "MSMQ Get Acl params #{params}"
        user_acl = powershell(params)
        all_acls.push(user_acl)
      rescue => detail
        raise Puppet::Error.new("Error calling set_acls with #{grant} for #{resource[:name]}. Error is #{detail}", detail)
      end
    end
    all_acls.map! {|x| x.chomp}
    Puppet.debug "MSMQ Get Users with #{grant} FullControl #{all_acls} on #{resource[:name]}"
    return all_acls
  end

  def set_acls(acl, grant)
    Puppet.info "Updating acls #{@resource[:acl_deny]} with #{grant} FullControl on Queue #{@resource[:name]}"
    acl.each do |user|
      begin
        params = ["Get-MsmqQueue -QueueType Private -Name #{resource[:name]} | Set-MsmqQueueACL -User \'#{user}\' -#{grant} FullControl"]
        Puppet.debug "MSMQ Set Acl params #{params}"
        powershell(params)
      rescue => detail
        raise Puppet::Error.new("Error calling setter_acl_deny for #{resource[:name]}. Error is #{detail}", detail)
      end
    end
  end
end

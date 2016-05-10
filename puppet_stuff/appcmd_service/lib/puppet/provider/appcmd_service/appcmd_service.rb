Puppet::Type.type(:appcmd_service).provide(:appcmd_service) do

  desc <<-EOT
    Treat IIS Application Pools as a service.
    Use appcmd.exe to control applicatio pools.
  EOT

  confine    :operatingsystem => :windows
  confine    :feature         => :appcmd
  defaultfor :operatingsystem => :windows

  has_feature :refreshable

  commands :appcmd_exe => "#{ENV['SYSTEMROOT']}\\system32\\inetsrv\\appcmd.exe"

  def start
    Puppet.info "Start AppPool #{@resource[:name]}\""
    cmd = ['start', 'apppool', "#{resource[:name]}"]
    appcmd_exe cmd
  rescue => detail
    raise Puppet::Error.new("Error calling Start AppPool #{@resource[:name]}. Error is #{detail}", detail)
  end

  def stop
    Puppet.info "Stop AppPool #{@resource[:name]}\""
    cmd = ['stop', 'apppool', "#{resource[:name]}"]
    appcmd_exe cmd
  rescue => detail
    raise Puppet::Error.new("Error calling Stop AppPool #{@resource[:name]}. Error is #{detail}", detail)
  end

  def restart
    Puppet.info "Restart AppPool #{@resource[:name]}"
    cmd = ['recycle', 'apppool', "#{resource[:name]}"]
    appcmd_exe cmd
  rescue => detail
    raise Puppet::Error.new("Error calling Recycle AppPool #{@resource[:name]}. Error is #{detail}", detail)
  end

  def status
    cmd = ['list', 'apppool', "#{resource[:name]}", '/text:state']
    status_cmd = appcmd_exe cmd
    state = case status_cmd
      when "Stopped\n" then :stopped
      when "Started\n" then :started
      else
        raise Puppet::Error.new("Cannot get status of #{@resource[:name]} result is #{status_cmd}")
    end
    return state
  rescue => detail
      raise Puppet::Error.new("Error calling appcmd.exe status #{@resource[:name]} state. Error is #{detail}", detail)
  end
end
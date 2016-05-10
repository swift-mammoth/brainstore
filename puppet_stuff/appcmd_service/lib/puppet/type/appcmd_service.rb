# lib/puppet/type/appcmd_service.rb

Puppet::Type.newtype(:appcmd_service, :self_refresh => true) do
  @doc = "Treat IIS Application Pool as a service
    use appcmd.exe to control application pool.
    Have the ability to stop, start and restart."

  feature :refreshable, "Provider can restart service",
    :methods => [:restart]

  newparam(:name, :namevar => true) do
    isnamevar
    desc "The Application Pool Name"
  end

  newproperty(:ensure) do
    desc "Application Pool should be running or stopped"

    newvalue(:started, :event => :service_started, :invalidate_refreshes => true) do
      provider.start
    end

    newvalue(:stopped, :event => :service_stopped) do
      provider.stop
    end

    aliasvalue(:true, :started)
    aliasvalue(:running, :started)
    aliasvalue(:false, :stopped)

    defaultto :started

    def retrieve
      provider.status
    end
  end

  def refresh
    if (@parameters[:ensure] || newattr(:ensure)).retrieve == :started
      provider.restart
    else
      debug "Skipping restart of AppPool"
    end
  end
end

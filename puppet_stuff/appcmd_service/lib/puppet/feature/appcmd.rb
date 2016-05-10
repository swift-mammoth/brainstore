require 'puppet/util/feature'

if Puppet.features.microsoft_windows?
  Puppet.features.add(:appcmd) {
    File.exists?("#{ENV['SYSTEMROOT']}\\system32\\inetsrv\\appcmd.exe")
  }
end
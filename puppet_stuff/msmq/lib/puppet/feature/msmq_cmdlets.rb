require 'puppet/util/feature'

if Puppet.features.microsoft_windows?
  Puppet.features.add(:msmq_cmdlets) {
    File.exists?("#{ENV['ProgramFiles']}\\WindowsPowerShell\\Modules\\MSMQ\\MSMQ.psd1") || File.exists?("#{ENV['windir']}\\System32\\WindowsPowerShell\\v1.0\\Modules\\MSMQ\\MSMQ.psd1")
  }
end
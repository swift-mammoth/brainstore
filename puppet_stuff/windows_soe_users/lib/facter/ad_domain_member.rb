# ad_domain_member.rb

Facter.add(:ad_domain_member) do
  confine :kernel => 'windows'
  setcode do
    powershell = 'C:\Windows\system32\WindowsPowershell\v1.0\powershell.exe'
    partofdomain = '(gwmi win32_computersystem).partofdomain'
    result = Facter::Core::Execution.exec(%Q{#{powershell} -command "#{partofdomain}"})
    ad_domain_member = (result == 'True') ? true : false
    ad_domain_member
  end
end
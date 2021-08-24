Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

$SafeAdminPassword = ConvertTo-SecureString "${safemode_admin_pwd}" -AsPlainText -Force

Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DomainMode WinThreshold `
    -DomainName "${domain_name}" `
    -DomainNetbiosName "${domain_nb_name}" `
    -ForestMode WinThreshold `
    -InstallDns:$true `
    -NoRebootOnCompletion:$true `
    -SafeModeAdministratorPassword $SafeAdminPassword `
    -Force:$true

Set-DnsServerForwarder -IPAddress "168.63.129.16"
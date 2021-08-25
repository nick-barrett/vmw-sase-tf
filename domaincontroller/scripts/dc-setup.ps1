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

# Use Azure's default DNS resolver for non-local
Set-DnsServerForwarder -IPAddress "168.63.129.16"

# Copy the stage2 script to the C:\ drive so that it is present after reboot
Copy-Item ${stage2_blob_name} C:\

# The VM must reboot at this point
# Per https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows,
# the recommended way to do this is via a scheduled task
$time = [DateTime]::Now.AddMinutes(1)
$hourMinute = $time.ToString("HH:mm")
schtasks /create /sc ONCE /ru system /tn "CompleteADDSSetup" /tr "shutdown /r /f" /st $hourMinute

# We also want our users and groups to be provisioned
# Another scheduled task is used to spawn the stage-2 script
# once the reboot completes. 
schtasks /create /sc ONSTART /ru system /tn "Stage2Script" /tr "powershell -ExecutionPolicy Unrestricted -File C:\${stage2_blob_name}"
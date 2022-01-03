Start-Transcript -Path C:\dc-setup-stage1-log.txt

$needReboot = $false

Write-Host "Checking if ADDS feature is installed..."
$addsStatus = Get-WindowsFeature -Name AD-Domain-Services

if ($addsStatus.Installed -eq $false) {
    Write-Host "ADDS is not installed. Installing."
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    $needReboot = $true
}

try {
    Write-Host "Checking if an AD forest exists..."
    Get-ADForest -Identity "${domain_name}" -ErrorAction Stop
}
catch {
    Write-Host "AD forest does not exist. Creating."
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

    $needReboot = $true
}

# Use Google's default DNS resolver for non-local
Set-DnsServerForwarder -IPAddress "8.8.8.8"

# Copy the stage2 script to the C:\ drive so that it is present after reboot
Copy-Item ${stage2_blob_name} C:\

# If ADDS was installed or the AD forest was created, need to schedule a reboot and then
# call into stage-2 script.
if ($needReboot -eq $true) {
    # In order to set up WinRM, a stage-2 script is scheduled after the reboot
    # Another scheduled task is used to spawn the stage-2 script
    # once the reboot completes. 
    schtasks /create /sc ONSTART /ru system /tn "Stage2Script" /tr "powershell -ExecutionPolicy Unrestricted -File C:\${stage2_blob_name}"

    # The VM must reboot at this point to complete domain services setup
    # Per https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows,
    # the recommended way to do this is via a scheduled task
    # This schedules a task in 1 minute to reboot the VM
    $hourMinute = [DateTime]::Now.AddMinutes(1).ToString("HH:mm")
    schtasks /create /sc ONCE /ru system /tn "ADDSReboot" /tr "shutdown /r /f" /st $hourMinute

    Stop-Transcript
} else {
    # Otherwise, go directly into stage-2 script.
    Stop-Transcript

    & "C:\${stage2_blob_name}"
}

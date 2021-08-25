# This script is triggered via a scheduled tasks in dc-setup.ps1
# Log to a file in C:\ because Azure VM extensions are no longer handling this script

Start-Transcript -Path C:\dc-setup-stage2-log.txt -Append

# Wait for domain services to be ready
do {
    Start-Sleep -Seconds 5
    Get-ADComputer $env:COMPUTERNAME | Out-Null
} until ($?)

# Clean up the scheduled tasks
schtasks /delete /f /tn CompleteADDSSetup
schtasks /delete /f /tn Stage2Script

%{ for ou in ous }
New-ADOrganizationalUnit `
    -Name "${ou.name}" `
    -Path "${ou.path}"
%{ endfor }

%{ for user in users }
$SecurePassword = ConvertTo-SecureString "${user.password}" -AsPlainText -Force
New-ADUser `
    -Name "${user.name}" `
    -GivenName "${user.given_name}" `
    -Surname "${user.surname}" `
    -SamAccountName "${user.sam_account_name}" `
    -UserPrincipalName "${user.upn}" `
    -Path "${user.path}" `
    -DisplayName "${user.display_name}" `
    -AccountPassword $SecurePassword `
    -PasswordNeverExpires $true `
    -Enabled $true
%{ endfor }

%{ for group in groups }
New-ADGroup `
    -Name "${group.name}" `
    -SamAccountName ${group.sam_account_name} `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "${group.display_name}" `
    -Path "${group.path}" `
    -Description "${group.description}"

Add-ADGroupMember `
    -Identity "${group.sam_account_name}" `
    -Members ${group.members}
%{ endfor }

Stop-Transcript

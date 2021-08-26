# This script is triggered via a scheduled tasks in dc-setup.ps1

Start-Transcript -Path C:\dc-setup-stage2-log.txt

# Enable debugging because winrm is tricky
# Set-PSDebug -Trace 1

# Wait for domain services to be ready
do {
    Start-Sleep -Seconds 5
    Get-ADComputer $env:COMPUTERNAME | Out-Null
} until ($?)

# Clean up the scheduled tasks
schtasks /delete /f /tn CompleteADDSSetup
schtasks /delete /f /tn Stage2Script

# Create self-signed certificate
$cert = New-SelfSignedCertificate -Subject "CN=${ip_address}" -TextExtension "2.5.29.37={text}1.3.6.1.5.5.7.3.1"
$thumbprint = $cert.Thumbprint

# Enable WinRM over TLS
$winrmCommand = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname=""${ip_address}"";CertificateThumbprint=""$thumbprint""}'"
Invoke-Expression $winrmCommand

# Permit WinRM through the firewall
$FirewallParam = @{
    DisplayName = 'WinRM-In'
    Direction = 'Inbound'
    LocalPort = 5986
    Protocol = 'TCP'
    Action = 'Allow'
    Program = 'System'
}
New-NetFirewallRule @FirewallParam

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

# This script is triggered via a scheduled tasks or directly from dc-setup-stage1.ps1

Start-Transcript -Path C:\dc-setup-stage2-log.txt

# Wait for domain services to be ready
do {
    Start-Sleep -Seconds 5
    Get-ADComputer $env:COMPUTERNAME | Out-Null
} until ($?)

# Clean up the scheduled tasks
schtasks /delete /f /tn ADDSReboot
schtasks /delete /f /tn Stage2Script

$certSubject = "CN=${ip_address}"
$cert = $null

# Check if there is already a certificate for WinRM
$matchingCerts = get-childitem -Path "Cert:\localmachine\my" | Where-Object { $_.subject = $certSubject }

if ($null -eq $matchingCerts) {
    # Create self-signed certificate
    $cert = New-SelfSignedCertificate -Subject $certSubject -TextExtension "2.5.29.37={text}1.3.6.1.5.5.7.3.1"
    
} else {
    $cert = $matchingCerts | Select-Object -Index 0
}

$thumbprint = $cert.Thumbprint

# TODO: Check if WinRM is enabled using this thumbprint already
# will require some horrible string-parsing since winrm does not output PS objects

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

# TODO: This needs to be done in a smarter way.
# Passing the data in as JSON and doing all of the control-flow inside powershell 
# may be a good solution.

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

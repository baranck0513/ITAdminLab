<#
Creates a basic Active Directory OU, user and group structure for the IT Administration Lab

.DESCRIPTION
This script creates department based organisational Units, security groups and sample users
inside the "securelab.local" domain. It is designed for a controlled home lab environment
and demonstrates basic Active Directory administration and PowerShell automation

.NOTES
Environment: securelab.local
Use case: Home lab / portfolio project
Warning: This script uses a simple default password for lab users
#>

Import-Module ActiveDirectory

$DomainDN = "DC=securelab,DC=local"
$DefaultPassword = ConvertTo-SecureString "Password123!" -AsPlainText -Force

function Ensure-OU {
    param (
        [string]$Name,
        [string]$Path
    )

    $ExistingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path -ErrorAction SilentlyContinue

    if (-not $ExistingOU) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        Write-Host "Created OU: $Name under $Path"
    } else {
        Write-Host "OU already exists: $Name under $Path"
    }
}

function Ensure-Group {
    param (
        [string]$Name,
        [string]$Path,
        [string]$Description
    )

    $ExistingGroup = Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue

    if (-not $ExistingGroup) {
        New-ADGroup `
            -Name $Name `
            -SamAccountName $Name `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $Path `
            -Description $Description

        Write-Host "Created group: $Name"
    } else {
        Write-Host "Group already exists: $Name"
    }
}

function Ensure-User {
    param (
        [string]$FirstName,
        [string]$LastName,
        [string]$Username,
        [string]$Department,
        [string]$Path,
        [string[]]$Groups
    )

    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue

    if (-not $ExistingUser) {
        New-ADUser `
            -Name "$FirstName $LastName" `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@securelab.local" `
            -Department $Department `
            -Path $Path `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $Username"
    } else {
        Write-Host "User already exists: $Username"
    }

    foreach ($GroupName in $Groups) {
        $UserExists = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue
        $GroupExists = Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue

        if ($UserExists -and $GroupExists) {
            Add-ADGroupMember -Identity $GroupName -Members $Username -ErrorAction SilentlyContinue
            Write-Host "Added $Username to $GroupName"
        } else {
            Write-Host "Skipped membership: $Username to $GroupName because user or group was not found"
        }
    }
}

# Top-level OUs
Ensure-OU -Name "Lab Users" -Path $DomainDN
Ensure-OU -Name "Workstations" -Path $DomainDN
Ensure-OU -Name "Servers" -Path $DomainDN
Ensure-OU -Name "Service Accounts" -Path $DomainDN
Ensure-OU -Name "Disabled Users" -Path $DomainDN
Ensure-OU -Name "Groups" -Path $DomainDN

# Department OUs under Lab Users
$LabUsersPath = "OU=Lab Users,$DomainDN"

Ensure-OU -Name "IT" -Path $LabUsersPath
Ensure-OU -Name "HR" -Path $LabUsersPath
Ensure-OU -Name "Finance" -Path $LabUsersPath
Ensure-OU -Name "Contractors" -Path $LabUsersPath

# Groups
$GroupsPath = "OU=Groups,$DomainDN"

Ensure-Group -Name "GG_IT_Admins" -Path $GroupsPath -Description "IT administrator users"
Ensure-Group -Name "GG_HR_Users" -Path $GroupsPath -Description "HR department users"
Ensure-Group -Name "GG_Finance_Users" -Path $GroupsPath -Description "Finance department users"
Ensure-Group -Name "GG_Contractors" -Path $GroupsPath -Description "Contractor users"
Ensure-Group -Name "GG_Workstation_Users" -Path $GroupsPath -Description "Standard workstation users"
Ensure-Group -Name "GG_Server_Admins" -Path $GroupsPath -Description "Server administration users"

# Users
Ensure-User `
    -FirstName "Pam" `
    -LastName "Beesly" `
    -Username "pam.beesly" `
    -Department "HR" `
    -Path "OU=HR,OU=Lab Users,$DomainDN" `
    -Groups @("GG_HR_Users", "GG_Workstation_Users")

Ensure-User `
    -FirstName "Jim" `
    -LastName "Halpert" `
    -Username "jim.halpert" `
    -Department "IT" `
    -Path "OU=IT,OU=Lab Users,$DomainDN" `
    -Groups @("GG_IT_Admins", "GG_Workstation_Users")

Ensure-User `
    -FirstName "Kevin" `
    -LastName "Malone" `
    -Username "kevin.malone" `
    -Department "Finance" `
    -Path "OU=Finance,OU=Lab Users,$DomainDN" `
    -Groups @("GG_Finance_Users", "GG_Workstation_Users")

Ensure-User `
    -FirstName "Michael" `
    -LastName "Scott" `
    -Username "michael.scott" `
    -Department "Contractors" `
    -Path "OU=Contractors,OU=Lab Users,$DomainDN" `
    -Groups @("GG_Contractors", "GG_Workstation_Users")

Ensure-User `
    -FirstName "Dwight" `
    -LastName "Schrute" `
    -Username "dwight.schrute" `
    -Department "IT" `
    -Path "OU=IT,OU=Lab Users,$DomainDN" `
    -Groups @("GG_IT_Admins", "GG_Server_Admins", "GG_Workstation_Users")

Write-Host "Active Directory structure completed successfully."
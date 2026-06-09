# Active Directory Structure

## Objective
Creating a small enterprise style Active Directory structure with department OUs, security groups and sample users

## OU Structure
- Lab Users
  - IT
  - HR
  - Finance
  - Contractors
- Workstations
- Servers
- Service Accounts
- Disabled Users
- Groups

## Sample Users
| Name | Username | Department |
|---|---|---|
| Pam Beesly | pam.beesly | HR |
| Jim Halpert | jim.halpert | IT |
| Kevin Malone | kevin.malone | Finance |
| Michael Scott | michael.scott | Contractors |
| Dwight Schrute | dwight.schrute | IT |

## Security Groups
- GG_IT_Admins
- GG_HR_Users
- GG_Finance_Users
- GG_Contractors
- GG_Workstation_Users
- GG_Server_Admins

## Automation
The AD structure was created using PowerShell:
`powershell/create-ad-structure.ps1`

## Evidence
- OU structure screenshots
- User screenshots
- Group screenshots
- PowerShell export files

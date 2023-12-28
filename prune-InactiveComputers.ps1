

#requires -version 2
<#
.SYNOPSIS
  Find and manage inactive Active Directory computer objects.
.DESCRIPTION
  This script allows you to specify the criteria required to identify inactive computer objects within your AD environment. This script also allows
  for the management of found computers. Management of computer objects includes one or more of the following options:
    - Reporting
    - Disabling computer objects
    - Deleting computer objects
.PARAMETER SearchScope
  Optional. Determines the search scope of what type of computer object you would like to include in the inactive computers search. Options available are:
   - All                        : Default option. All computer including never logged on computer objects.
   - OnlyInactiveComputers      : Only inactive computers. These are computers that have logged on in the past but have not logged on since DaysInactive.
   - OnlyNeverLoggedOn          : Only never logged on objects. This option excludes computers that have logged on before.
   Note: If not specified, the default search scope is All (i.e. all inactive and never logged on computer objects).
.PARAMETER DaysInactive
  Optional. The number of days a computer hasn't logged into the domain for in order to classify it as inactive. The default option is 90
  days, which means any computer that hasn't logged into the domain for 90 days or more is considered inactive and therefore managed by this
  script.
.PARAMETER ReportFilePath
  Optional. This is the location where the report of inactive computer objects will be saved to. If this parameter is not specified, the default location
  the report is saved to is C:\InactiveComputers.csv.
  Note: When specifying the file path, you MUST include the file name with the extension of .csv. Example: 'C:\MyReport.csv'.
.PARAMETER DisableObjects
  Optional. If this parameter is specified, this script will disable the inactive computer objects found based on the search scope specified.
  Note: If this parameter is not specified, then by default this script WILL NOT disable any inactive computers found.
.PARAMETER DeleteObjects
  Optional. If this parameter is specified, this script will delete the inactive computer objects found based on the search scope specified.
  Note: If this parameter is not specified, then by default this script WILL NOT delete any inactive computers found.
.INPUTS
  None.
.OUTPUTS
  Report of inactive computer objects found. See ReportFilePath parameter for more information.
.NOTES
  Version:        1.0
  Author:         Luca Sturlese
  Creation Date:  16.07.2016
  Purpose/Change: Initial script development
.EXAMPLE
  Execution of script using default parameters. Default execution performs reporting of inactive AD computers only, not disabling or deleting any objects.
  By default the report is saved in C:\.
  .\Find-ADInactiveComputers.ps1
.EXAMPLE
  Reporting and disabling all inactive computer objects, except never logged on objects. Storing the report in C:\Reports.
  .\Find-ADInactiveComputers.ps1 -SeachScope OnlyInactiveComputers -ReportFilePath 'C:\Reports\DisabledComputers.csv' -DisableObjects
.EXAMPLE
  Find & delete all inactive computer objects that haven't logged in for the last 30 days. Include never logged on objects in this search.
  .\Find-ADInactiveComputers.ps1 -SeachScope All -DaysInactive 30 -DeleteObjects
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [Parameter(Mandatory = $false)][string][ValidateSet('All', 'OnlyInactiveComputers', 'OnlyNeverLoggedOn')]$SearchScope = 'All',
  [Parameter(Mandatory = $false)][int]$DaysInactive = 30,
  [Parameter(Mandatory = $false)][string]$ReportFilePath = 'C:\Inactivecomputers.csv',
  [Parameter(Mandatory = $false)][switch]$DisableObjects = $true,
  [Parameter(Mandatory = $false)][switch]$DeleteObjects = $false
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module ActiveDirectory

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Set Inactive Date:
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Find-Objects {
  Param ()

  Begin {
    Write-Host "Finding inactive computer objects based on search scope specified [$SearchScope]..."
  }

  Process {
    Try {
      Switch ($SearchScope) {
        'All' {
          $global:Results = Get-ADComputer -Filter { (LastLogonDate -lt $InactiveDate -or LastLogonDate -notlike "*") -and (Enabled -eq $true) } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
        }

        'OnlyInactiveComputers' {
          $global:Results = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
        }

        'OnlyNeverLoggedOn' {
          $global:Results = Get-ADComputer -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName
        }

        Default {
          Write-Host -BackgroundColor Red "Error: An unknown error occcurred. Can't determine search scope. Exiting."
          Break
        }
      }
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }

    End {
      If ($?) {
        Write-Host 'Completed Successfully.'
        Write-Host ' '
      }
    }
  }
}

Function Create-Report {
  Param ()

  Begin {
    Write-Host "Creating report of inactive computers in specified path [$ReportFilePath]..."
  }

  Process {
    Try {
      #Check file path to ensure correct
      If ($ReportFilePath -notlike '*.csv') {
        $ReportFilePath = Join-Path -Path $ReportFilePath -ChildPath '\InactiveComputers.csv'
      }

      # Create CSV report
      $global:Results | Export-Csv $ReportFilePath -NoTypeInformation
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }
  }

  End {
    If ($?) {
      Write-Host 'Completed Successfully.'
      Write-Host ' '
    }
  }
}

Function Disable-Objects {
  Param ()

  Begin {
    Write-Host 'Disabling inactive computers...'
  }

  Process {
    Try {
      ForEach ($Item in $global:Results){
        Set-ADComputer -Identity $Item.DistinguishedName -Enabled $false
        Move-ADObject -Identity $Item.DistinguishedName -TargetPath "OU=zzz Quarantined Workstations,DC=Pomeroy,DC=msft"
        Write-Host "$($Item.Name) - Disabled"
      }
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }
  }

  End {
    If ($?) {
      Write-Host 'Completed Successfully.'
      Write-Host ' '
    }
  }
}

Function Delete-Objects {
  Param ()

  Begin {
    Write-Host 'Deleting inactive computers...'
  }

  Process {
    Try {
      ForEach ($Item in $global:Results){
        Remove-ADComputer -Identity $Item.DistinguishedName -Confirm:$false
        Write-Host "$($Item.Name) - Deleted"
      }
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }
  }

  End {
    If ($?) {
      Write-Host 'Completed Successfully.'
      Write-Host ' '
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Find-Objects
Create-Report

If ($DisableObjects) {
  Disable-Objects
}

If ($DeleteObjects) {
  Delete-Objects
}


Empty OUs
PowerShell

#requires -version 2
<#
.SYNOPSIS
  Find and manage empty Active Directory OUs.
.DESCRIPTION
  This script allows you to find and manage empty organizational units within your AD environment. This script also allows
  for the management of found OUs. Management of empty OUs includes one or more of the following options:
    - Reporting
    - Deleting
.PARAMETER SearchScope
  Optional. Specifies an Active Directory Path to search under. This is primarily used to narrow down your search within a certain OU and it's children.
  Search Scope must be specfied in LDAP format. If not specified, the default search scope is the root of the domain.
  Example: -SearchScope "OU=MGT,DC=testlab,DC=com"
.PARAMETER ReportFilePath
  Optional. This is the location where the report of empty OUs will be saved to. If this parameter is not specified, the default location
  the report is saved to is C:\EmptyOUs.csv.
  Note: When specifying the file path, you MUST include the file name with the extension of .csv. Example: 'C:\MyReport.csv'.
.PARAMETER DeleteObjects
  Optional. If this parameter is specified, this script will delete the empty OUs found based on the search scope specified.
  Note: If this parameter is not specified, then by default this script WILL NOT delete any empty OUs found.
  Note: If the OU to be deleted has been marked with PreventFromAccidentialDeletion, then this script will return an error.
.INPUTS
  None.
.OUTPUTS
  Report of empty OUs found. See ReportFilePath parameter for more information.
.NOTES
  Version:        1.0
  Author:         Luca Sturlese
  Creation Date:  16.07.2016
  Purpose/Change: Initial script development
.EXAMPLE
  Execution of script using default parameters. Default execution performs reporting of empty OUs only, not deleting any objects.
  By default the report is saved in C:\.
  .\Find-ADEmptyOU.ps1
.EXAMPLE
  Reporting and deleting all empty OUs found within the MGT OU. Store the report in C:\Reports.
  .\Find-ADEmptyOU.ps1 -SeachScope "OU=MGT,DC=testlab,DC=com" -ReportFilePath 'C:\Reports\DeletedOUs.csv' -DeleteObjects
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [Parameter(Mandatory = $false)][string]$SearchScope,
  [Parameter(Mandatory = $false)][string]$ReportFilePath = 'C:\EmptyOUs.csv',
  [Parameter(Mandatory = $false)][switch]$DeleteObjects = $false
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module ActiveDirectory

#----------------------------------------------------------[Declarations]----------------------------------------------------------



#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Find-Objects {
  Param ()

  Begin {
    Write-Host "Finding empty OUs based on search scope specified..."
  }

  Process {
    Try {
      If($SearchScope) {
        $global:Results = Get-ADOrganizationalUnit -Filter * -SearchBase $SearchScope | ForEach-Object { If ( !( Get-ADObject -Filter * -SearchBase $_ -SearchScope OneLevel) ) { $_ } } | Select-Object Name, DistinguishedName
      } Else {
        $global:Results = Get-ADOrganizationalUnit -Filter * | ForEach-Object { If ( !( Get-ADObject -Filter * -SearchBase $_ -SearchScope OneLevel) ) { $_ } } | Select-Object Name, DistinguishedName
      }
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }

    End {
      If ($?) {
        Write-Host 'Completed Successfully.'
        Write-Host ' '
      }
    }
  }
}

Function Create-Report {
  Param ()

  Begin {
    Write-Host "Creating report of empty OUs in specified path [$ReportFilePath]..."
  }

  Process {
    Try {
      #Check file path to ensure correct
      If ($ReportFilePath -notlike '*.csv') {
        $ReportFilePath = Join-Path -Path $ReportFilePath -ChildPath '\EmptyOUs.csv'
      }

      # Create CSV report
      $global:Results | Export-Csv $ReportFilePath -NoTypeInformation
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }
  }

  End {
    If ($?) {
      Write-Host 'Completed Successfully.'
      Write-Host ' '
    }
  }
}

Function Delete-Objects {
  Param ()

  Begin {
    Write-Host 'Deleting empty OUs...'
  }

  Process {
    Try {
      ForEach ($Item in $global:Results){
        Remove-ADOrganizationalUnit -Identity $Item.DistinguishedName -Confirm:$false
        Write-Host "$($Item.Name) - Deleted"
      }
    }

    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }
  }

  End {
    If ($?) {
      Write-Host 'Completed Successfully.'
      Write-Host ' '
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Find-Objects
Create-Report

If ($DeleteObjects) {
  Delete-Objects
}

The complete solution is also available from the following GitHub repository - PS-ManageInactiveAD.

These scripts provide you with the ability to find and report on inactive user and computer accounts, as well as empty AD groups and OUs. Finally with these scripts you will also be able to manage these inactive objects through either disabling them (if possible) or deleting them.
Do-It-Yourself

diy-active-directory-cleanup-powershell

For those of you who are more interested in the inner workings of the solution above, or would like to build your own inactive AD object cleanup scripts, then this section is for you.

Before we go looking at any of the code, it is important to note that each of the snippets documented below are NOT complete solutions but rather the core cmdlets required to achieve the following:

    Finding AD objects that meet cleanup criteria
    Reporting: How to export the results to a CSV file
    Disabling: How to disable the discovered objects
    Removing: How to delete the discovered objects

These cmdlets provide you with the ability to build your own custom solution, whether that be just report on inactive objects, or take further action such as disable and \ or delete objects too.

Note: To be able to run any the following scripts, you will need to have the PowerShell Active Directory module available on your machine (or the machine you are running these from). The simplest way to get this is to install the Remote Server Administration Tools for your OS.
Inactive AD User Accounts

The most common Active Directory object you will need to cleanup will be user accounts, so let’s start here:
PowerShell

Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

#-------------------------------
# FIND INACTIVE USERS
#-------------------------------
# Below are four options to find inactive users. Select the one that is most appropriate for your requirements:

# Get AD Users that haven't logged on in xx days
$Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

# Get AD Users that haven't logged on in xx days and are not Service Accounts
$Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

# Get AD Users that have never logged on
$Users = Get-ADUser -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

# Automated way (includes never logged on users)
$Users = Search-ADAccount -AccountInactive -DateTime $InactiveDate -UsersOnly | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Users | Export-Csv C:\Temp\InactiveUsers.csv -NoTypeInformation

#-------------------------------
# INACTIVE USER MANAGEMENT
#-------------------------------
# Below are two options to manage the inactive users that have been found. Either disable them, or delete them. Select the option that is most appropriate for your requirements:

# Disable Inactive Users
ForEach ($Item in $Users){
  $DistName = $Item.DistinguishedName
  Disable-ADAccount -Identity $DistName
  Get-ADUser -Filter { DistinguishedName -eq $DistName } | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, Enabled
}

# Delete Inactive Users
ForEach ($Item in $Users){
  Remove-ADUser -Identity $Item.DistinguishedName -Confirm:$false
  Write-Output "$($Item.Username) - Deleted"
}

Note: The cleanup inactive user accounts script is also available on GitHub here.
Inactive AD Computer Objects

The second most common AD object you will need to cleanup will be computer object. Here is how to do that:
PowerShell

Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

#-------------------------------
# FIND INACTIVE COMPUTERS
#-------------------------------
# Below are three options to find inactive computers. Select the one that is most appropriate for your requirements:

# Get AD Computers that haven't logged on in xx days
$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

# Get AD Computers that have never logged on
$Computers = Get-ADComputer -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

# Automated way (includes never logged on computers)
$Computers = Search-ADAccount -AccountInactive -DateTime $InactiveDate -ComputersOnly | Select-Object Name, LastLogonDate, Enabled, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Computers | Export-Csv C:\Temp\InactiveComputers.csv -NoTypeInformation

#-------------------------------
# INACTIVE COMPUTER MANAGEMENT
#-------------------------------
# Below are two options to manage the inactive computers that have been found. Either disable them, or delete them. Select the option that is most appropriate for your requirements:

# Disable Inactive Computers
ForEach ($Item in $Computers){
  $DistName = $Item.DistinguishedName
  Set-ADComputer -Identity $DistName -Enabled $false
  Get-ADComputer -Filter { DistinguishedName -eq $DistName } | Select-Object Name, Enabled
}

# Delete Inactive Computers
ForEach ($Item in $Computers){
  Remove-ADComputer -Identity $Item.DistinguishedName -Confirm:$false
  Write-Output "$($Item.Name) - Deleted"
}

Note: The cleanup inactive computer objects script is also available on GitHub here.
Empty AD Groups

Active Directory groups are awesome for managing access and permissions to your network, but they can get out of hand pretty quickly. Here is how to cleanup empty Active Directory groups:


PowerShell

Import-Module ActiveDirectory

#-------------------------------
# FIND EMPTY GROUPS
#-------------------------------

# Get empty AD Groups within a specific OU
$Groups = Get-ADGroup -Filter { Members -notlike "*" } -SearchBase "OU=GROUPS,DC=testlab,DC=com" | Select-Object Name, GroupCategory, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------

# Export results to CSV
$Groups | Export-Csv C:\Temp\InactiveGroups.csv -NoTypeInformation

#-------------------------------
# INACTIVE GROUP MANAGEMENT
#-------------------------------

# Delete Inactive Groups
ForEach ($Item in $Groups){
  Remove-ADGroup -Identity $Item.DistinguishedName -Confirm:$false
  Write-Output "$($Item.Name) - Deleted"
}

Note: The cleanup of empty AD Groups script is also available on GitHub here.
Empty AD Organizational Units

If you have any old, empty OUs in your Active Directory structure, here is how to find them, report on them and remove them:
PowerShell

Import-Module ActiveDirectory

#-------------------------------
# FIND EMPTY OUs
#-------------------------------

# Get empty AD Organizational Units
$OUs = Get-ADOrganizationalUnit -Filter * | ForEach-Object { If ( !( Get-ADObject -Filter * -SearchBase $_ -SearchScope OneLevel) ) { $_ } } | Select-Object Name, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------

# Export results to CSV
$OUs | Export-Csv C:\Temp\InactiveOUs.csv -NoTypeInformation

#-------------------------------
# INACTIVE OUs MANAGEMENT
#-------------------------------

# Delete Inactive OUs
ForEach ($Item in $OUs){
  Remove-ADOrganizationalUnit -Identity $Item.DistinguishedName -Confirm:$false
  Write-Output "$($Item.Name) - Deleted"
}

Import-Module ActiveDirectory

<# 
User perms and adds details that i dont wanna do manually or forget to do when setting up an account

Adds manager under organization
Adds memberships from specific user using their username. 
Adds Description
#>

function Update-UserDescription {
    param (
        [Parameter(Mandatory=$true)][string]$UserName,
        [Parameter(Mandatory=$true)][string]$Description
    )
    try {
        Set-ADUser -Identity $UserName -Description $Description
        Write-Host "Description updated for user $UserName."
    } catch {
        Write-Warning "Failed to update description for user $UserName. Error: $_"
    }
}

function Copy-GroupMemberships {
    param (
        [Parameter(Mandatory=$true)][string]$SourceUser,
        [Parameter(Mandatory=$true)][string]$TargetUser
    )
    try {
        $sourceUser = Get-ADUser -Identity $SourceUser -Properties MemberOf
        $groups = $sourceUser.MemberOf
        foreach ($group in $groups) {
            Add-ADGroupMember -Identity $group -Members $TargetUser
        }
        Write-Host "Group memberships copied from $SourceUser to $TargetUser."
    } catch {
        Write-Warning "Failed to copy group memberships from $SourceUser to $TargetUser. Error: $_"
    }
}

function Add-UserManager {
    param (
        [Parameter(Mandatory=$true)][string]$UserName,
        [Parameter(Mandatory=$true)][string]$ManagerName
    )
    try {
        $manager = Get-ADUser -Identity $ManagerName
        if ($manager) {
            Set-ADUser -Identity $UserName -Manager $manager.DistinguishedName
            Write-Host "Manager $ManagerName added to user $UserName."
        } else {
            Write-Warning "Manager $ManagerName not found. Please try again."
        }
    } catch {
        Write-Warning "Failed to add manager $ManagerName to user $UserName. Error: $_"
    }
}

function New-UserWithPrompts {
    $newUserFullName = Read-Host "Enter the new user's full name"
    $newUserName = Read-Host "Enter the new user's username"
    $description = Read-Host "Enter the description for the new user"
    $sourceUserForGroups = Read-Host "Enter the username of the user to copy group memberships from"
    $managerUserName = Read-Host "Enter the manager's username"

    try {
        # Assuming user creation logic here
        Write-Host "User $newUserFullName created."

        Update-UserDescription -UserName $newUserName -Description $description
        Copy-GroupMemberships -SourceUser $sourceUserForGroups -TargetUser $newUserName
        Add-UserManager -UserName $newUserName -ManagerName $managerUserName
    } catch {
        Write-Warning "Failed to create user $newUserFullName. Error: $_"
    }
}

# Call the main function
New-UserWithPrompts
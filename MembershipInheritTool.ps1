param(
    [string]$sourceUser,
    [string]$targetUser,
    [string]$managerUser
)

Import-Module ActiveDirectory

function Copy-GroupMemberships {
    param (
        [string]$sourceUser,
        [string]$targetUser
    )

    $sourceGroups = Get-ADUser -Identity $sourceUser -Property MemberOf | Select-Object -ExpandProperty MemberOf
    foreach ($group in $sourceGroups) {
        Add-ADGroupMember -Identity $group -Members $targetUser
    }
}

function Add-AttributeManager {
    param (
        [string]$targetUser,
        [string]$managerUser
    )

    Set-ADUser -Identity $targetUser -Manager $managerUser
}

do {
    $sourceUser = Read-Host -Prompt 'Enter the UPN of the source user'
    $targetUser = Read-Host -Prompt 'Enter the UPN of the target user'
    $managerUser = Read-Host -Prompt 'Enter the UPN of the manager user'
    
    $confirmation = Read-Host -prompt "Are you sure you want to copy group memberships and manager attribute from $sourceUser to $targetUser? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Output "Action cancelled."
        return
    }

    Copy-GroupMemberships -sourceUser $sourceUser -targetUser $targetUser
    Add-AttributeManager -targetUser $targetUser -managerUser $managerUser

    Write-Output "Group memberships and manager attribute copied from $sourceUser to $targetUser"
    $continue = Read-Host -Prompt 'Do you want to copy group memberships and manager attribute for another user? (yes/no)'
} while ($continue -eq 'yes')

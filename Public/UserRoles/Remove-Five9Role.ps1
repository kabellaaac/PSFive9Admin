function Remove-Five9Role
{
    <#
    .SYNOPSIS
    
        Function used to remove a user role

    .NOTES

        All users must have at least one role. You cannot remove a user's only role.
   
    .EXAMPLE
    
        Remove-Five9UserRole -Username 'jdoe@domain.com' -RoleName Reporting
    
        # Removes reporting role to user

    .LINK

        Add-Five9Role
        Set-Five9RoleAdmin
        Set-Five9RoleAgent
        Set-Five9RoleReporting
        Set-Five9RoleSupervisor

    #>
    [CmdletBinding(DefaultParametersetName='Username',PositionalBinding=$false)]
    param
    (
        # Username of the user being modified
        # This parameter is not used when -UserProfileName is passed
        [Parameter(ParameterSetName='Username',Mandatory=$true)][string]$Username,

        # Profile name being modified
        # This parameter is not used when -Username is passed
        [Parameter(ParameterSetName='UserProfileName',Mandatory=$true)][string]$UserProfileName,

        <#
        Name of role being removed
         
        Options are:
            • Agent
            • Admin
            • Supervisor
            • Reporting
        #>
        [Parameter(Mandatory=$true)][ValidateSet("Agent", "Admin", "Supervisor", "Reporting")][string]$RoleName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

Test-Five9Connection -ErrorAction: Stop

        $objToModify = $null
        try
        {
            if ($PsCmdLet.ParameterSetName -eq "Username")
            {
                $objToModify = $global:DefaultFive9AdminClient.getUsersInfo($Username)
            }
            elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
            {
                $objToModify = $global:DefaultFive9AdminClient.getUserProfile($UserProfileName)
            }
            else
            {
                throw "Error setting media type. ParameterSetName not set."
            }

        }
        catch
        {

        }


        if ($objToModify.Count -gt 1)
        {
            throw "Multiple matches were found using query: ""$($Username)$($UserProfileName)"". Please try using the exact name of the user or profile you're trying to modify."
            return
        }

        if ($objToModify -eq $null)
        {
            throw "Cannot find a Five9 user or profile with name: ""$($Username)$($UserProfileName)"". Remember that this value is case sensitive."
            return
        }


        $objToModify = $objToModify | Select-Object -First 1

        if ($objToModify.roles.$RoleName -eq $null)
        {
            throw "Cannot remove role, user is not assigned the $RoleName role."
            return
        }


        $roleCount = 0

        foreach ($role in @("Agent", "Admin", "Supervisor", "Reporting"))
        {
            if ($objToModify.roles.$role -ne $null)
            {
                $roleCount++
            }
        }

        if ($roleCount -le 1)
        {
            throw "You cannot remove the $RoleName role becasue it is the only role assigned. Please use Add-Five9UserRole<RoleName> to add another role, then try again."
            return
        }


        if ($PsCmdLet.ParameterSetName -eq "Username")
        {
            if ($RoleName -eq "Admin")
            {
                $roleToRemove = 'DomainAdmin'
            }
            else
            {
                $roleToRemove = $RoleName
            }

            Write-Verbose "$($MyInvocation.MyCommand.Name):Removing '$RoleName' from user '$Username'."

            $response = $global:DefaultFive9AdminClient.modifyUser($objToModify.generalInfo,$null,$roleToRemove)

        }
        elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            $objToModify.roles.$RoleName = $null
            Write-Verbose "$($MyInvocation.MyCommand.Name): Removing '$RoleName' from user profile '$UserProfileName'." 
            $response = $global:DefaultFive9AdminClient.modifyUserProfile($objToModify)
        }

    }
    catch
    {
        throw $_
    }
}


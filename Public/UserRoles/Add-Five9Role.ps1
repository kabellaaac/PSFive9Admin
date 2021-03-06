function Add-Five9Role
{
    <#
    .SYNOPSIS
    
        Function used to add a new role to a user

    .EXAMPLE
    
        Add-Five9UserRole -Username 'jdoe@domain.com' -RoleName Reporting
    
        # Adds default reporting role to user

    .LINK

        Remove-Five9Role
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
        Name of role being added. Role permissions will be default
        To permissions within role, cmdlet Set-Five9Role<RoleName>
         
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

        # user already has role they're trying to add
        if ($objToModify.roles.$RoleName -ne $null)
        {
            return
        }


        if ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            $userRoles = $objToModify.roles
        }
        else
        {
            $userRoles = New-Object -TypeName PSFive9Admin.userRoles
        }

        if ($RoleName -eq "Agent")
        {
            $agentRole = New-Object -TypeName PSFive9Admin.agentRole
            $agentRole.permissions = @()

            $userRoles.agent = $agentRole

        }
        elseif ($RoleName -eq "Admin")
        {
            $userRoles.admin = @()
        }
        elseif ($RoleName -eq "Supervisor")
        {
            $userRoles.supervisor = @()
            
            # supervisor role requires at least one view to be set
            $supervisorPermission = New-Object PSFive9Admin.supervisorPermission
            $supervisorPermission.type = "Agents"
            $supervisorPermission.typeSpecified = $true
            $supervisorPermission.value = $true
            $userRoles.supervisor += $supervisorPermission

            $supervisorPermission = New-Object PSFive9Admin.supervisorPermission
            $supervisorPermission.type = "CanRunJavaClient"
            $supervisorPermission.typeSpecified = $true
            $supervisorPermission.value = $true
            $userRoles.supervisor += $supervisorPermission

        }
        elseif ($RoleName -eq "Reporting")
        {
            $userRoles.reporting = @()
        }

        if ($PsCmdLet.ParameterSetName -eq "Username")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Adding '$RoleName' to user '$Username'." 
            $response = $global:DefaultFive9AdminClient.modifyUser($objToModify.generalInfo, $userRoles, $null)
        }
        elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            $objToModify.roles = $userRoles
            Write-Verbose "$($MyInvocation.MyCommand.Name): Adding '$RoleName' to user profile '$UserProfileName'." 
            $response = $global:DefaultFive9AdminClient.modifyUserProfile($objToModify)
        }

    }
    catch
    {
        throw $_
    }
}


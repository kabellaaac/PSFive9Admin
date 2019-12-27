function Get-Five9User
{
    <#
    .SYNOPSIS
    
        Function used to return Five9 user(s) using a 

    .EXAMPLE
    
        Get-Five9User
    
        # Returns all Users
    
    .EXAMPLE
    
        Get-Five9User -NamePattern "jdoe@domain.com"
    
        # Returns user who matches the string "jdoe@domain.com"

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Optional regex parameter. If used, function will return only users matching regex string
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop


        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning user(s) matching pattern '$($NamePattern)'"
        $response = $global:DefaultFive9AdminClient.getUsersInfo($NamePattern)

        $userList = @()
        foreach ($user in $response)
        {
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name agentGroups -Value $user.agentGroups -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name cannedReports -Value $user.cannedReports -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name roles -Value $user.roles -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name skills -Value $user.skills -Force

            $userList += $user.generalinfo
        }


        return $userList
    }
    catch
    {
        Write-Error $_
    }

}



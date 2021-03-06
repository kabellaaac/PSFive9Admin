function Get-Five9UserProfile
{
    <#
    .SYNOPSIS
    
        Function used to get User Profile object(s) from Five9

    .EXAMPLE
    
        Get-Five9UserProfile
    
        # Returns all User Profiles
    
    .EXAMPLE
    
        Get-Five9UserProfile -NamePattern "Call_Center_Agent"
    
        # Returns all profiles matching the string "Call_Center_Agent"
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Returns only user profiles matching a given regex string
        # If omitted, all user profiles will be returned
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning user profiles matching pattern '$NamePattern'" 
        return $global:DefaultFive9AdminClient.getUserProfiles($NamePattern) | sort name

    }
    catch
    {
        throw $_
    }
}




function Get-Five9ContactField
{
    <#
    .SYNOPSIS
    
        Function used to return contact field(s) from Five9

    .EXAMPLE

        Get-Five9ContactField

        # Returns all contact fields

    .EXAMPLE
    
        Get-Five9ContactField -Name "first_name"
    
        # Returns contact field with name ""first_name"
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of existing contact field. If omitted, all contact fields will be returned
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning contact field matching patter '$NamePattern'." 
        return $global:DefaultFive9AdminClient.getContactFields($NamePattern)

    }
    catch
    {
        throw $_
    }
}

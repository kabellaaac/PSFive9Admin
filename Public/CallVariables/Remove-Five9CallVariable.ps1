function Remove-Five9CallVariable
{
    <#
    .SYNOPSIS
    
        Function used to remove an existing call variable

    .EXAMPLE
    
        Remove-Five9CallVariable -Name "SalesforceId" -Group "Salesforce"
    
        # Deletes existing call variable named "SalesforceId" which is in the "Salesforce" call variable group

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of existing call variable to be removed
        [Parameter(Mandatory=$true)][string]$Name,

        # Group name of existing call variable to be removed
        [Parameter(Mandatory=$true)][string]$Group
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing call variable '$Name' within group '$Group'." 
        $response = $global:DefaultFive9AdminClient.deleteCallVariable($Name, $Group)
        return $response

    }
    catch
    {
        throw $_
    }
}




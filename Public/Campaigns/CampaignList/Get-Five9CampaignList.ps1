function Get-Five9CampaignList
{
    <#
    .SYNOPSIS

        Function returns the attributes of the dialing lists associated with an outbound campaign
 
    .EXAMPLE
    
        Get-Five9CampaignList -Name 'Hot-Leads'

        # Returns lists associated with a campaign
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Outbound campaign name that list(s) will be returned from
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning list(s) associated with campaign '$Name'." 
        return $global:DefaultFive9AdminClient.getListsForCampaign($Name)

    }
    catch
    {
        throw $_
    }
}


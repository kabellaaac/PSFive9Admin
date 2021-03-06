function Remove-Five9CampaignList
{
    <#
    .SYNOPSIS

        Function to remove list(s) from an outbound campaign

    .EXAMPLE
    
        Remove-Five9CampaignList -Name 'Hot-Leads' -List 'Hot-Leads-List'

        # Remove a list from a campaign

    .EXAMPLE
    
        $listsToBeRemoved = @('Hot-Leads-List', 'Cold-Leads-List')
        Remove-Five9CampaignList -Name 'Hot-Leads' -List $listsToBeRemoved

        # Removes multiple lists from a campaign

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Outbound campaign name that list(s) will be removed from
        [Parameter(Mandatory=$true)][string]$Name,

        # Name of list(s) to be removed from a campaign
        [Parameter(Mandatory=$true)][string[]]$List
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing list(s) from campaign '$Name'."
        return $global:DefaultFive9AdminClient.removeListsFromCampaign($Name, $List)

    }
    catch
    {
        throw $_
    }
}

function Get-Five9DNIS
{
    <#
    .SYNOPSIS
    
        Function to return the list of DNIS for the domain
 
    .EXAMPLE
    
        Get-Five9DNIS

        # Returns basic details for both assigned and unassigned DNISes 

    .EXAMPLE
    
        Get-Five9DNIS -IncludeUnassigned $true -IncludeCampaignInfo $true 

        # Returns all DNISes including campaign details

    .EXAMPLE
    
        Get-Five9DNIS -IncludeUnassigned $false -IncludeCampaignInfo $true -CampaignName "Inbound"

        # Returns only DNISes assigned to campaign "Inbound"
    
    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        <#
        Options are
            • True (Default): only DNIS not assigned to a campaign are returned
            • False: only DNIS which are not assigned to a campaign
        #>
        [Parameter(Mandatory=$false)][bool]$IncludeUnassigned = $true,
        
        <#
        Options are
            • True: will return campaign details associated with each DNIS. NOTE: This method is MUCH more time consuming
            • False (Default): only DNIS numbers will be returned
        #>
        [Parameter(Mandatory=$false)][bool]$IncludeCampaignInfo = $false,

        # Name of campaign to return DNISes
        # If omitted, and -IncludeCampaignInfo is True, all campaigns will be returned
        [Parameter(Mandatory=$false)][string]$CampaignName = '.*'

    )

    try
    {


Add-Type @"
public struct campaignDNIS {
    public string dnis;
    public string campaignName;
    public string campaignState;
}
"@ -IgnoreWarnings

        Test-Five9Connection -ErrorAction: Stop

        $returnList = @()

        if ($IncludeCampaignInfo -eq $false)
        {
            $assignedDnisList = $global:DefaultFive9AdminClient.getDNISList($false, $true)

            foreach ($dnis in $assignedDnisList)
            {
                $returnList += New-Object campaignDNIS -Property @{
                    dnis = $dnis
                }
            }

        }
        else
        {
            $inboundCampaigns = $null
            $inboundCampaigns = $global:DefaultFive9AdminClient.getCampaigns($CampaignName, 'INBOUND', $true)

            if (!$inboundCampaigns)
            {
                throw "Cannot find a Five9 campaign with name: ""$CampaignName"". Remember that CampaignName is case sensitive."
                return
            }


            $count = $inboundCampaigns.Count
            $i = $count
            $j = 0
 
            foreach ($campaign in $inboundCampaigns)
            {
                try
                {
                    Write-Progress -Activity $campaign.name -Status "$i Inbound Campaigns Remaining.."  -PercentComplete (($j / $count) * 100)
                    $i--
                    $j++
                }
                catch
                {

                }

                $campaignDnis = $null
                $campaignDnis = $global:DefaultFive9AdminClient.getCampaignDNISList($campaign.name)

                foreach ($dnis in $campaignDnis)
                {
                    $returnList += New-Object -TypeName campaignDNIS -Property @{
                        dnis = $dnis
                        campaignName = $campaign.name
                        campaignState = $campaign.state

                    }
                }


            }
        }

        Write-Progress -Activity "Complete" -PercentComplete 100 -Completed: $true


        if ($IncludeUnassigned -eq $true)
        {
            $unassignedDnisList = $global:DefaultFive9AdminClient.getDNISList($true, $true)

            foreach ($dnis in $unassignedDnisList)
            {
                $returnList += New-Object campaignDNIS -Property @{
                    dnis = $dnis
                    campaignName = "Unassigned"
                }
            }


        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning DNIS list."
        return $returnList

        
        

    }
    catch
    {
        throw $_
    }
}

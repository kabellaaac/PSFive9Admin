<#
.SYNOPSIS
    
    Function to returns the list of DNIS for the domain
 
.PARAMETER SelectUnassigned

    • True: only DNIS not assigned to a campaign are returned
    • False (Default): all DNIS provisioned for the domain are returned


.EXAMPLE
    
    Get-Five9DNIS

    # returns list of all DNIS for the domain

.EXAMPLE
    
    Get-Five9DNIS -SelectUnassigned: $true

    # returns only DNIS not assigned to a campaign
    
#>
function Get-Five9DNIS
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$false)][bool]$SelectUnassigned = $false
    )

    return $global:DefaultFive9AdminClient.getDNISList($SelectUnassigned, $true)

}

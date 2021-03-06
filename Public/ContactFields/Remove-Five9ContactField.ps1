function Remove-Five9ContactField
{
    <#
    .SYNOPSIS
    
        Function used to remove an existing contact field

    .NOTES

        • All campaigns must be stopped before removing a contact field

    .EXAMPLE

        Remove-Five9ContactField -Name 'hair_color'

        # Removes contact field named "hair_color"
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of contact field to be removed
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing contact field '$Name'." 
        return $global:DefaultFive9AdminClient.deleteContactField($Name)

    }
    catch
    {
        throw $_
    }
}

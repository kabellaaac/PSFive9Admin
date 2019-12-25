<#
.SYNOPSIS
    
    Function used to get Skill objects from Five9


.PARAMETER NamePattern
 
    Returns only skills matching a given regex string
   
.EXAMPLE
    
    Get-Five9Skill
    
    # Returns all skills
    
.EXAMPLE
    
    Get-Five9Skill -NamePattern "MultiMedia"
    
    # Returns all skills matching the string "MultiMedia"
    

 
#>

function Get-Five9Skill
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    return $global:DefaultFive9AdminClient.getSkills($NamePattern)

}




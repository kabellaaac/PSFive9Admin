function Add-Five9ListRecord
{
    <#
    .SYNOPSIS
    
        Function used to add new or existing contact record(s) to an outbound dialing list

        Using the function you are able to add records to a list 3 ways:
            1. Specifying a single object using -InputObject
            2. Specifying an arrary of objects using -InputObject
            3. Specifying the path of a local CSV file using -CsvPath
   
    .EXAMPLE
    
        Add-Five9ListRecord -Name "Hot-Leads" -InputObject $dataToBeImported

        # Records in $dataToBeImported will be imported into Five9 list named "Hot-Leads" using default values

    .EXAMPLE

        Add-Five9ListRecord -Name "Hot-Leads" -CsvPath 'C:\files\list-data.csv'

        # Records in CSV file "C:\files\list-data.csv"  will be imported into Five9 list named "Hot-Leads" using default values

    .EXAMPLE

        Add-Five9ListRecord -Name "Hot-Leads" -CsvPath 'C:\files\list-data.csv' `
                            -CrmAddMode: ADD_NEW -CrmUpdateMode: UPDATE_ALL -ListAddMode: ADD_ALL -Key @('number1', 'first_name') `
                            -CleanListBeforeUpdate: $true -FailOnFieldParseError $true -ReportEmail 'jdoe@domain.com'

        # Imports records from CSV file to list, specifying additional optional parameters
    #>
    [CmdletBinding(DefaultParametersetName='InputObject', PositionalBinding=$false)]
    param
    ( 
        # Name of list that records will be added to
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Single object or array of objects to be added to list. 
        # Note: Parameter not needed when specifying a CsvPath
        [Parameter(ParameterSetName='InputObject', Mandatory=$true)][psobject[]]$InputObject,

        # Local file path to CSV file containing records to be removed from a list. 
        # Note: Parameter not needed when specifying an InputObject
        [Parameter(ParameterSetName='CsvPath', Mandatory=$true)][string]$CsvPath,

        <#
         Specifies whether a contact record is added to the contact database when a new record is added to a dialing list.

        Options are:
            • ADD_NEW (Default) - Contact records are created in the contact database and are added to the dialing list
            • DONT_ADD - Records are added to the dialing list but no records are created in the contact database
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("ADD_NEW", "DONT_ADD")]$CrmAddMode = "ADD_NEW",

        <#
        Specifies how contact records should be updated when records are added to a dialing list.

        Options are:
            • UPDATE_FIRST (Default) - Update the first matched record
            • UPDATE_SOLE_MATCHES - Update only if one matched record is found
            • UPDATE_ALL - Update all matched records
            • DONT_UPDATE - Do not update any record
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("UPDATE_FIRST", "UPDATE_ALL", "UPDATE_SOLE_MATCHES", "DONT_UPDATE")]$CrmUpdateMode = "UPDATE_FIRST",

        <#
        Specifies how to add records to a list

        Options are:
            • ADD_FIRST (Default) - Adds the first record when multiple matches exist
            • ADD_IF_SOLE_CRM_MATCH - Add record if only one match exists in the database
            • ADD_ALL - Add all records
        #>
        [Parameter(Mandatory=$false)][string][ValidateSet("ADD_FIRST", "ADD_ALL", "ADD_IF_SOLE_CRM_MATCH")]$ListAddMode = "ADD_FIRST",

        # Single string, or array of strings which designate key(s). Used when a record needs to be updated, it is used to find the record to update in the contact database.
        # If omitted, 'number1' will be used
        [Parameter(Mandatory=$false)][string[]]$Key = @("number1"),

        # Whether to remove all records in the list before adding new records. If set to True, all existing records will be removed from list before being udpated
        [Parameter(Mandatory=$false)][bool]$CleanListBeforeUpdate,

        <#
        Whether to stop the import if incorrect data is found
        For example, if set to True and you have a column named hair_color in your data, but that field has not been created as a contact field, the list import will fail

        Options are:
            • True: The record is rejected when at least one field fails validation
            • False: Default. The record is accepted. However, changes to the fields that fail validation are rejected
        #>
        [Parameter(Mandatory=$false)][bool]$FailOnFieldParseError,

        # Notification about import results is sent to the email addresses that you set for your application
        [Parameter(Mandatory=$false)][string]$ReportEmail

    )


    try
    {
        Test-Five9Connection -ErrorAction: Stop

        if ($PSCmdlet.ParameterSetName -eq 'InputObject')
        {
            $csv = $InputObject | ConvertTo-Csv -NoTypeInformation
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'CsvPath')
        {
            # try to import csv file so that if it throw an error, we know the data is bad
            $csv = Import-Csv $CsvPath | ConvertTo-Csv -NoTypeInformation
        }
        else
        {
            # should never reach this point becasue user should use either InputObject or CsvPath
            return
        }


        $headers = $csv[0] -replace '"' -split ','

        # verify that key(s) passed are present in $Inputobject
        foreach ($k in $Key)
        {
            if ($headers -notcontains $k)
            {
                throw "Specified key ""$k"" is not a property name found in data being imported."
                return
            }
        }

        $listUpdateSettings = New-Object PSFive9Admin.listUpdateSettings

        # prepare "fieldMapping" per Five9's documentation
        $counter = 1
        foreach ($header in $headers)
        {
            $isKey = $false
            if ($Key -contains $header)
            {
                $isKey = $true
            }

            $listUpdateSettings.fieldsMapping += @{
                columnNumber = $counter
                fieldName = $header
                key = $isKey
            }

            $counter++

        }


        $csvData = ($csv | select -Skip 1) | Out-String


        $listUpdateSettings.crmAddModeSpecified = $true
        $listUpdateSettings.crmAddMode = $CrmAddMode
    
        $listUpdateSettings.crmUpdateModeSpecified = $true
        $listUpdateSettings.crmUpdateMode = $CrmUpdateMode
    
        $listUpdateSettings.listAddModeSpecified = $true
        $listUpdateSettings.listAddMode = $ListAddMode
    

        if ($PSBoundParameters.Keys -contains "CleanListBeforeUpdate")
        {
            $listUpdateSettings.cleanListBeforeUpdate = $CleanListBeforeUpdate
        }

        if ($PSBoundParameters.Keys -contains "FailOnFieldParseError")
        {
            $listUpdateSettings.failOnFieldParseErrorSpecified = $true
            $listUpdateSettings.failOnFieldParseError = $FailOnFieldParseError
        }

        if ($PSBoundParameters.Keys -contains "ReportEmail")
        {
            $listUpdateSettings.reportEmail = $ReportEmail
        }
    
        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding specified records to list '$Name'." 

        # single record
        if ($InputObject.Count -eq 1)
        {
            $data = $csvData -replace '"' -split ','
            $response = $global:DefaultFive9AdminClient.addRecordToList($Name, $listUpdateSettings, $data)
        }
        else
        {
            $response = $global:DefaultFive9AdminClient.addToListCsv($Name, $listUpdateSettings, $csvData)
        }

        return $response

    }
    catch
    {
        throw $_
    }
}

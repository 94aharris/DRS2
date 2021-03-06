function Get-DrsDiskReport {
    <#
    .SYNOPSIS
        Get Disk Report for computers
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    
    [CmdletBinding(DefaultParameterSetName="ConfigReport")]
    param (
        [Parameter(ParameterSetName="ConfigReport")]
        $Config,

        [Parameter(ParameterSetName="ComputerReport",Mandatory,ValueFromPipeline)]
        [Alias("Computer")]
        [String[]]$ComputerName,

        # Parameter for Creds
        [Parameter(ParameterSetName='ComputerReport')]
        [PSCredential]$Credential,

        # Parameter for Output Folder
        [Parameter(ParameterSetName='ComputerReport')]
        [Parameter(ParameterSetName='ConfigReport')]
        [String]$OutputFolder
    )
    
    begin {

    }
    
    process {
        
        # Default Params for Get-DRSDiskHealth
        $DiskHealthParams = @{

        }

        # Evaluate ParameterSet Used
        switch ($PSCmdlet.ParameterSetName) {
            # If no Params or Using Config
            "ConfigReport" {
                if ($null -eq $config) {
                    Write-Verbose "Config not passed, acquiring"
                    $config = Get-DrsConfig
                }
            }

            # If Receiving Specific Computers Add them to param
            "ComputerReport" {
                $DiskHealthParams.Add("ComputerName",$ComputerName)
                
                # Add the Credential to Key Value Pair if Passed
                if ($Credential) {
                    $DiskHealthParams.add("Credential",$Credential)
                } 
            }

            default {
                throw "Bad Param Set Evaluation"
            }

        }


        
        Write-Verbose "Acquiring Disk Health"
        $DiskHealth = Get-DrsDiskHealth @DiskHealthParams
        
        Write-Verbose "Generating HTML"
        $DiskHtmlParams = @{
            HealthObject = $DiskHealth
            Title = "DRS - Disk Report"
            DisplayProperties = @(
                'ComputerName',
                'Label',
                'Drive',
                'DirtyBit',
                'FreeSpaceGB',
                'CapacityGB',
                'FreeSpacePct',
                'Status'
            )
        }

        $DiskHtml = ConvertTo-DrsHtml @DiskHtmlParams


        Write-Verbose "Outputting HTML"
        if ($OutputFolder)
        {
            Out-DrsHtml -Html $DiskHtml -ReportName "DiskReport" -OutputFolder $OutputFolder
        } else {
            Out-DrsHtml -Html $DiskHtml -ReportName "DiskReport" 
        }

    }
    
    end {
        
    }
}
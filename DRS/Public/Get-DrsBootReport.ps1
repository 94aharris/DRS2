function Get-DrsBootReport {
    <#
    .SYNOPSIS
        Short description
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

        # Default Params for Get-DRSServiceHealth
        $BootHealthParams = @{

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
                $BootHealthParams.Add("ComputerName",$ComputerName)
                
                # Add the Credential to Key Value Pair if Passed
                if ($Credential) {
                    $BootHealthParams.add("Credential",$Credential)
                } 
            }

            default {
                throw "Bad Param Set Evaluation"
            }

        }

        Write-Verbose "Acquiring Boot Health"
        $BootHealth = Get-DrsBootTime @BootHealthParams

        Write-Verbose "Generating HTML"
        $BootHtmlParams = @{
            HealthObject = $BootHealth
            Title = "DRS - Boot Time Report"
            DisplayProperties = @(
                'ComputerName'
                'LastBootTime'
                'Status'
            )
        }

        $BootHtml = ConvertTo-DrsHtml @BootHtmlParams

        Write-Verbose "Outputting HTML"
        if ($OutputFolder)
        {
            Out-DrsHtml -Html $BootHtml -ReportName "BootReport" -OutputFolder $OutputFolder
        } else {
            Out-DrsHtml -Html $BootHtml -ReportName "BootReport" 
        }

        
    }
    
    process {
        
    }
    
    end {
        
    }
}
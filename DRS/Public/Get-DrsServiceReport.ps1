function Get-DrsServiceReport {
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
        [PSCredential]$Credential
    )
    
    begin {

        # Default Params for Get-DRSServiceHealth
        $ServiceHealthParams = @{

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
                $ServiceHealthParams.Add("ComputerName",$ComputerName)
                
                # Add the Credential to Key Value Pair if Passed
                if ($Credential) {
                    $ServiceHealthParams.add("Credential",$Credential)
                } 
            }

            default {
                throw "Bad Param Set Evaluation"
            }

        }

        Write-Verbose "Acquiring Service Health"
        $ServiceHealth = Get-DrsServiceHealth @ServiceHealthParams

        Write-Verbose "Generating HTML"
        $ServiceHtmlParams = @{
            HealthObject = $ServiceHealth
            Title = "DRS - Service Report"
            DisplayProperties = @(
                'ComputerName'
                'Name'
                'State'
                'StartName'
                'Status'
            )
        }

        $ServiceHtml = ConvertTo-DrsHtml @ServiceHtmlParams

        Write-Verbose "Outputting HTML"
        Out-DrsHtml -Html $ServiceHtml -ReportName "ServiceReport"

        
    }
    
    process {
        
    }
    
    end {
        
    }
}
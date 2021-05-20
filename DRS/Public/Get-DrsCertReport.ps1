function Get-DrsCertReport {
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

        # Default Params for Get-DRScertHealth
        $certHealthParams = @{

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
                $certHealthParams.Add("ComputerName",$ComputerName)
                
                # Add the Credential to Key Value Pair if Passed
                if ($Credential) {
                    $certHealthParams.add("Credential",$Credential)
                } 
            }

            default {
                throw "Bad Param Set Evaluation"
            }

        }

        Write-Verbose "Acquiring Cert Health"
        $CertHealth = Get-DrsCertHealth @CertHealthParams

        Write-Verbose "Generating HTML"
        $CertHtmlParams = @{
            HealthObject = $CertHealth
            Title = "DRS - Cert Report"
            DisplayProperties = @(
                'FriendlyName'
                'Subject'
                'Expiration'
                'Status'
            )
        }

        $CertHtml = ConvertTo-DrsHtml @CertHtmlParams

        Write-Verbose "Outputting HTML"
        if ($OutputFolder)
        {
            Out-DrsHtml -Html $CertHtml -ReportName "CertReport" -OutputFolder $OutputFolder
        } else {
            Out-DrsHtml -Html $CertHtml -ReportName "CertReport" 
        }
        

        
    }
    
    process {
        
    }
    
    end {
        
    }
}
function Get-VolumeHealthStatus {
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

    [CmdletBinding(DefaultParameterSetName="Volume")]
    param (
        # Volume to Return Alerts for
        [Parameter(Mandatory=$true,ParameterSetName='Volume',ValuefromPipeline=$True)]
        $Volume,

        [Parameter(ParameterSetName='Volume')]
        $config
    )
    
    begin {
        
        # Read Config if Needed
        if ($null -eq $config) {
            Write-Verbose "Config not passed, acquiring"
            $config = Get-DrsConfig
        }
        
    }
    
    process {
        $Volume | foreach {
            Write-Verbose "Processing Volume $_"
            
            Write-Verbose "Processing VolumeHealth Rules"
            $Vol = $_

            Write-Verbose "Getting Rule Results"
            $ruleResults = $config.VolumeHealth.rules | ForEach-Object {        
                Get-RuleResult -TestObject $vol -Rule $_
            }

            Write-Verbose "Determining Highest Severity Alert"
            $highestSeverity = "Info"
            if ($ruleResults.Severity -contains "Critical")
            {
                $highestSeverity = "Critical"

            } elseif ($ruleResults.Severity -contains "Alert")
            {
                $highestSeverity = "Alert"
            }  elseif ($ruleResults.Severity -contains "Warning")
            {
                $highestSeverity = "Warning"
            }

            Write-Verbose "Returning Severity and Alerts"
            [PSCustomObject]@{
                Severity = $highestSeverity
                RuleResults = $ruleResults
            }
        }
 
    }
    
    end {
        
    }
}
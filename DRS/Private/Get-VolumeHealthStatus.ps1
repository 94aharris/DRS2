function Get-ServiceHealthStatus {
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

    [CmdletBinding(DefaultParameterSetName="Service")]
    param (
        # Service to Return Alerts for
        [Parameter(Mandatory=$true,ParameterSetName='Service',ValuefromPipeline=$True)]
        $Service,

        [Parameter(ParameterSetName='Service')]
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
        $Service | foreach {
            Write-Verbose "Processing Service $_"
            
            Write-Verbose "Processing Service Rules"
            $Ser = $_

            Write-Verbose "Getting Rule Results"
            $ruleResults = $config.ServiceHealth.rules | ForEach-Object {        
                Get-RuleResult -TestObject $ser -Rule $_
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
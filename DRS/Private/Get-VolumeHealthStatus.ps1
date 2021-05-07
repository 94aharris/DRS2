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

            $config.VolumeHealth.alert | foreach {        
                Get-RuleResult -TestObject $vol -Rule $_
            }
        }
 
    }
    
    end {
        
    }
}
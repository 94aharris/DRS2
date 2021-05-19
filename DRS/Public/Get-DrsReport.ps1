function Get-DrsReport {

    <#
        .SYNOPSIS
            Controller Function to Generate a DRS Report
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

    [CmdletBinding(DefaultParameterSetName="Config")]
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
        
    }
    
    process {
        
        # This will be needed eventually, fail early
        if ($null -eq $Config) {
            Write-Verbose "Config not passed, acquiring"
            $Config = Get-DrsConfig
        }

        # Acquire Computers Detect Failed Heartbeats
        # $computerHeartbeat = Get-DrsComputer $Config
        # $aliveComputer = $computerHeartbeat | where {$_.Heartbeat -eq $true}
        # $unresponsiveComputer = $computerHeartbeat | where {$_.Heartbeat -eq $false}

        # Pass all Params Right on through for now
        Write-Verbose "Generating Disk Report"
        Get-DrsDiskReport @PsBoundParameters

        Write-Verbose "Generating Service Report"
        Get-DrsServiceReport @PsBoundParameters
    }
    
    end {
        
    }
}
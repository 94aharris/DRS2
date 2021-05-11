function Get-DrsHeartbeat {
    [CmdletBinding(DefaultParameterSetName="ComputerName")]
    param (
        [Parameter(ParameterSetName="ComputerName",Mandatory)]
        [Alias("Computer")]
        [String[]]$ComputerName
    )
    
    begin {
        
    }
    
    process {
        foreach($computer in $ComputerName) {
            Write-Verbose "Performing Simple Ping Alive Against $Computer"
            $heartbeat = Test-Connection -ComputerName $Computer -BufferSize 16 -Count 1 -Quiet

            [PSCustomObject]@{
                ComputerName = $Computer
                Heartbeat = $heartbeat
            }
        }
    }
    
    end {
        
    }
}
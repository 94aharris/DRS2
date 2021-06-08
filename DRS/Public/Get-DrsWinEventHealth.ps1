#TODO: Override Level Display Name with any special events in config

function Get-DrsWinEventHealth {
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
    [CmdletBinding(DefaultParameterSetName="DrsWinEvent")]
    param (
        
        [Parameter(ValueFromPipeline,Mandatory=$true)]
        [Alias("Event","WinEvent")]
        $DrsWinEvent,

        $Config = $(Get-DrsConfig),

        [switch]$BypassInfo
    )
    
    begin {
        
        
    }
    
    process {
        foreach ($event in $DrsWinEvent) {
            
            Write-Verbose "Checking if Event ID specified to be ignored in Config File (based on Id and LogName of Event)"
            if ($Event.Id -inotin @($Config.WinEventHealth.$($Event.LogName).ignoreEventId)) {
                
                Write-Verbose "Calculating Event Status Severity of $($Event.LevelDisplayName)"
                switch ($Event.LevelDisplayName) {
                    
                    "Critical" { $eventStatus = "Critical" } 

                    "Error" { $eventStatus = "Alert"}

                    "Warning" { $eventStatus = "Warning"}

                    {"Verbose", "LogAlways","Info" -contains $_} { $eventStatus = "Info" }

                    Default { 
                        Write-Verbose "Unrecognized Event Severity $($Event.LevelDisplayName) on $($Event.ID) From $($Event.LogName) on $($Event.ComputerName)"
                        $eventStatus = "Alert"
                    }
                }

                Write-Verbose "Checking if Info should be tossed" 
                if ($BypassInfo -and ($eventStatus -eq "Info")) {
                    Write-Verbose "Skipping $($Event.Id) from $($Event.LogName) as Info Event"
                } else {
                    [PSCustomObject]@{
                        ComputerName     = $Event.ComputerName
                        LogName          = $Event.LogName
                        ProviderName     = $Event.ProviderName
                        Id               = $Event.Id
                        Message          = $Event.Message
                        LevelDisplayName = $Event.LevelDisplayName
                        Count            = $Event.Count
                        Status           = $eventStatus
                    }
                }

            } else {
                Write-Verbose "Ignoring $($Event.Id) from $($Event.LogName) per Config"
            }
        }
    }
    
    end {
        
    }
}
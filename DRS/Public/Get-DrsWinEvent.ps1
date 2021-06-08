function Get-DrsWinEvent {
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
    [CmdletBinding()]
    param (
        
        [Parameter(ValueFromPipeline)]
        [Alias("Computer")]
        [ValidateNotNullOrEmpty]
        [string[]] $ComputerName,

        [Alias("Cred")]
        [ValidateNotNullOrEmpty]
        [System.Management.Automation.PSCredential] $Credential,

        [Alias("StartTime")]
        [datetime] $After = (Get-Date).AddDays(-2),

        [Alias("EndTime")]
        [datetime] $Before = (Get-Date).AddDays(1),
        
        [ValidateSet('Application','System','Security')]
        [String] $LogName = "Application",

        # 0 (LogAlways), 1 (Critical), 2 (Error), 3 (Warning), 4 (Info), 5 (Verbose)
        [ValidateRange(0, 5)]
        [Int32] $Severity = 2
    )
    
    begin {
        
        $eventFilter = @{
            logname   = $LogName
            level     = $Severity
            startTime = $After
            endTime   = $Before
        }

        
        
    }
    
    process {
        if ($ComputerName) {
            $rawEvents = foreach ($name in $ComputerName) {
                try {
                    if ($Credential) {
                        Write-Verbose "Getting $LogName Events from $name using Credentials"
                        Get-WinEvent -FilterHashtable $eventFilter -ComputerName $name -Credential $Credential -ErrorAction Stop 
                    }
                    else {
                        Write-Verbose "Getting $LogName Events from $name"
                        Get-WinEvent -FilterHashtable $eventFilter -ComputerName -ErrorAction Stop
                    }
                }
                catch [Exception] {
                    if ($_.Exception -match "No events were found that match the specified selection criteria") {
                        Write-Verbose "No matching events found";
                    }
                    else {
                        Write-Error "Error Reading Event Log on Local Computer : $($_.Exception.Message)"
                    }
                    
                }
            }
        }
        else {
            try {
                Write-Verbose "Getting $LogName Events from Local Computer"
                $rawEvents = Get-WinEvent -FilterHashtable $eventFilter -ErrorAction Stop
            }
            catch [Exception] {
                if ($_.Exception -match "No events were found that match the specified selection criteria") {
                    Write-Verbose "No matching events found";
                }
                else {
                    Write-Error "Error Reading Event Log on Local Computer : $($_.Exception.Message)"
                }
                
            }
        }            

        Write-Verbose "Parsing Events Into Counts"
        $groupedEvents = $rawevents | Group-Object ID, ProviderName 

        foreach ($group in $groupedEvents) {
            [PSCustomObject]@{
                ComputerName     = $group.group[0].MachineName
                LogName          = $group.group[0].LogName
                ProviderName     = $group.group[0].ProviderName
                Id               = $group.group[0].Id
                Message          = $group.group[0].Message
                LevelDisplayName = $group.group[0].LevelDisplayName
                Count            = $group.Count
            }
        }
    

    }

    end {
        
    }
}
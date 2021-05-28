function Get-DrsEventLog {
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
        [string[]] $ComputerName,

        [Alias("Cred")]
        [System.Management.Automation.PSCredential] $Credential,

        [Alias("StartTime")]
        [datetime] $After = (Get-Date).AddDays(-2),

        [Alias("EndTime")]
        [datetime] $Before = (Get-Date).AddDays(1),
        
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
        if ($null -ne $ComputerName) {
            foreach ($name in $ComputerName) {
                try {
                    if ($null -ne $Credential) {
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
                    } else {
                        Write-Error "Error Reading Event Log on Local Computer : $($_.Exception.Message)"
                    }
                    
                }
            }
        }
        else {
            try {
                Write-Verbose "Getting $LogName Events from Local Computer"
                Get-WinEvent -FilterHashtable $eventFilter -ErrorAction Stop
            }
            catch [Exception] {
                if ($_.Exception -match "No events were found that match the specified selection criteria") {
                    Write-Verbose "No matching events found";
                } else {
                    Write-Error "Error Reading Event Log on Local Computer : $($_.Exception.Message)"
                }
                
            }
        }
    }
    
    end {
        
    }
}
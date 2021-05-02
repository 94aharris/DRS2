<#
.SYNOPSIS
    Get the performance of a passed script block
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
function Get-DrsScriptPerformance {
    [CmdletBinding(DefaultParameterSetName="ScriptBlock")]
    param (
        # Script block to test the performance of
        [Parameter(Mandatory=$true,ParameterSetName="ScriptBlock")]
        [ScriptBlock]
        $Command,

        [Parameter(ParameterSetName="ScriptBlock")]
        [ValidateRange(1,10000)]
        [Int32]
        $Iterations = 100
    )
    
    begin {
        
    }
    
    process {
        
        # Set the Miliseconds
        $TotalMiliseconds = 0

        # Loop the Range
        foreach ($i in 1..$Iterations) {
            $TotalMiliseconds = $TotalMiliseconds + (Measure-Command $Command).Milliseconds
        }

        # Return
        [PSCustomObject]@{
            Miliseconds = $TotalMiliseconds
            Iterations = $Iterations
            Command = $Command
        }
        return
    }
    
    end {
        
    }
}
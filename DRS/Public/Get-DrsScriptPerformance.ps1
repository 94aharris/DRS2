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
        $totalMiliseconds = 0

        # Loop the Range
        foreach ($i in 1..$Iterations) {
            $totalMiliseconds = $totalMiliseconds + (Measure-Command $Command).Milliseconds
        }

        # Return
        [PSCustomObject]@{
            Miliseconds = $totalMiliseconds
            Iterations = $iterations
            Command = $command
        }
        return
    }
    
    end {
        
    }
}
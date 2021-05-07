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

    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        Write-Output "Acquiring Disks"
        $Disks = Get-DrsDiskHealth
        Format-DiskSpace $Disks

    }
    
    end {
        
    }
}
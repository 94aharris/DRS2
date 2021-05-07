function Get-DrsConfig {
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
    param ()
    
    # Read the file only once for each pipeline object
    begin {
        try {
            Write-Verbose "Getting content of config.json"
            $configLocation = Resolve-Path "$PSScriptRoot\..\config.json"
            $config = Get-Content -path $configLocation -ErrorAction 'Stop' -Raw | ConvertFrom-json
            
        } catch {
            throw "Unable to find config.json file at $configLocation. Use 'Set-DrsConfig' to create one"
        }

    }
    
    process {
        Write-Verbose "Returning Config Object"
        return $config
    }
    
    end {
        
    }
}
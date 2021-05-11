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
        [Parameter(ParameterSetName="Config")]
        $Config = $null

    )
    
    begin {
        
    }
    
    process {
        
        if ($null -eq $Config) {
            Write-Verbose "Config not passed, acquiring"
            $Config = Get-DrsConfig
        }

        Write-Verbose "Determining Params based on Param Set"
        switch ($PsCmdlet.ParameterSetName) {
            "Config" {
                $ReportParams = @{
                    Config = $Config
                }
              }
            Default {
                throw "Bad Param Set $($PsCmdlet.ParameterSetName)"
            }
        }

        Write-Verbose "Generating Disk Report"
        Get-DrsDiskReport @ReportParams
    }
    
    end {
        
    }
}
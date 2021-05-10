function Get-DrsDiskReport {
    <#
    .SYNOPSIS
        Get Disk Report for computers
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
    
    [CmdletBinding(DefaultParameterSetName="HtmlReport")]
    param (
        [Parameter(ParameterSetName="HtmlReport")]
        $CssPath = $null,

        [Parameter(ParameterSetName="HtmlReport")]
        $JsPath = $null
    )
    
    begin {

    }
    
    process {
        if ($null -eq $config) {
            Write-Verbose "Config not passed, acquiring"
            $config = Get-DrsConfig
        }

        
        if ($null -eq $CssPath) {
            Write-verbose "Generating CSS Path"
            $CssPath = Convert-path "$PSSCriptRoot\..\$($config.report.css)" -ErrorAction Stop
            Write-Verbose "CssPath: $cssPath"
        }

        if ($null -eq $JsPath) {
            Write-verbose "Generating CSS Path"
            $JsPath = Convert-path "$PSSCriptRoot\..\$($config.report.js)" -ErrorAction Stop
            Write-Verbose "CssPath: $JsPath"
        }
        
        Write-Verbose "Acquiring Disk Health"
        $DiskHealth = Get-DrsDiskHealth
        
        Write-Verbose "Generating HTML"
        $DiskHtmlParams = @{
            HealthObject = $DiskHealth
            DisplayProperties = @(
                'ComputerName',
                'Label',
                'Drive',
                'DirtyBit',
                'FreeSpaceGB',
                'CapacityGB',
                'FreeSpacePct',
                'Status'
            )
        }

        $DiskHtml = ConvertTo-DrsHtml @DiskHtmlParams

        Write-Verbose "Outputting HTML"
        Write-Verbose "$DiskHtml"
        $DiskHtml | Out-file "DiskHealth.html" -Force -encoding utf8

        Write-Verbose "Outputting CSS from $CssPath"
        Copy-Item -Path $cssPath -Destination "reportstyle.css" 

        Write-verbose "Outputting JSScripts from $JsPath"
        Copy-Item -Path $JsPath -Destination "reportscript.js"
    }
    
    end {
        
    }
}
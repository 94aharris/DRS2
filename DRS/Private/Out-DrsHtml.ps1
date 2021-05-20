function Out-DrsHtml {
    <#
    .SYNOPSIS
        Output Drs HTML File and Needed Support Files
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
        [Parameter(ParameterSetName="HtmlReport",Mandatory,ValueFromPipeline)]
        $Html,

        [Parameter(ParameterSetName="HtmlReport",Mandatory)]
        [String]$ReportName,

        [Parameter(ParameterSetName="HtmlReport")]
        $Config = $null,

        [Parameter(ParameterSetName="HtmlReport")]
        $CssPath = $null,

        [Parameter(ParameterSetName="HtmlReport")]
        $JsPath = $null,

        [Parameter(ParameterSetName="HtmlReport")]
        $OutputFolder = $null
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

        if ($null -eq $OutputFolder) {
            Write-verbose "Generating Output Path"
            $OutputFolder = ".\$($config.report.output)\$(Get-Date -Format "y-MM-d-HHmm")"
        }

        try {
            $OutputPath = Convert-Path $OutputFolder -ErrorAction Stop
        } catch {
            New-item -path $OutputFolder -type "Directory" | Out-Null
            $OutputPath = Convert-Path $OutputFolder -ErrorAction Stop
        }

        Write-Verbose "Sending HTML To File"
        $Html | Out-file "$OutputPath\$($ReportName).html" -Force -encoding utf8

        Write-Verbose "Outputting CSS from $CssPath"
        Copy-Item -Path $cssPath -Destination "$OutputPath\reportstyle.css" 

        Write-verbose "Outputting JSScripts from $JsPath"
        Copy-Item -Path $JsPath -Destination "$OutputPath\reportscript.js"
        
    }
    
    end {
        
    }
}
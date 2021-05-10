function ConvertTo-DrsHtml {
    [CmdletBinding(DefaultParameterSetName='ObjectHtml')]
    param (
        # Object to ConvertTo Html 
        [Parameter(Mandatory=$true,ParameterSetName='ObjectHtml',ValuefromPipeline=$True)]
        $HealthObject,

        [Parameter(Mandatory=$true, ParameterSetName='ObjectHtml')]
        [String[]]$DisplayProperties,

        [Parameter(ParameterSetName='ObjectHtml')]
        [Switch]$Fragment,

        [Parameter(ParameterSetName='ObjectHtml')]
        $config,

        [Parameter(ParameterSetName='scripts')]
        $scripts = '<script type="text/javascript" src="reportscript.js"></script>'
    )
    
    begin {
        
        # Read Config if Needed
        if ($null -eq $config) {
            Write-Verbose "Config not passed, acquiring"
            $config = Get-DrsConfig
        }
        
    }
    
    process {
        
        $HtmlBodyFragment = $HealthObject | Convertto-Html -Property $DisplayProperties -Fragment -postContent $scripts

        if ($Fragment) {
            return $HtmlBodyFragment
        }
        else {
            $HtmlFull = ConvertTo-Html -CssUri "reportstyle.css" -body $HtmlBodyFragment
            $HtmlFull
        }


    }
    
    end {
        
    }
}
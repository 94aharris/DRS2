function ConvertTo-DrsHtml {
    [CmdletBinding(DefaultParameterSetName='ObjectHtml')]
    param (
        # Object to ConvertTo Html 
        [Parameter(ParameterSetName='ObjectHtml',Mandatory,ValuefromPipeline)]
        $HealthObject,

        [Parameter(ParameterSetName='ObjectHtml',Mandatory)]
        [String[]]$DisplayProperties,

        [Parameter(ParameterSetName='ObjectHtml')]
        [Switch]$Fragment,

        [Parameter(ParameterSetName='ObjectHtml')]
        $config,

        [Parameter(ParameterSetName='ObjectHtml')]
        $scripts = '<script type="text/javascript" src="reportscript.js"></script>',

        [Parameter(ParameterSetName='ObjectHtml')]
        $title = 'DRS Report'
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
            $HtmlFull = ConvertTo-Html -CssUri "reportstyle.css" -body $HtmlBodyFragment -Title $title
            $HtmlFull
        }


    }
    
    end {
        
    }
}
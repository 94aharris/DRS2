function ConvertTo-DrsHtml {
    [CmdletBinding(DefaultParameterSetName = 'ObjectHtml')]
    param (
        # Object to ConvertTo Html 
        [Parameter(ParameterSetName = 'ObjectHtml', Mandatory = $true, ValuefromPipeline)]
        [Alias("HealthObject")]
        [object[]]$InputObject,

        [Parameter(ParameterSetName = 'ObjectHtml')]
        [String[]]$DisplayProperties,

        [Parameter(ParameterSetName = 'ObjectHtml')]
        [Switch]$Fragment,

        [Parameter(ParameterSetName = 'ObjectHtml')]
        $config = $(Get-DrsConfig),

        [Parameter(ParameterSetName = 'ObjectHtml')]
        $scripts = '<script type="text/javascript" src="reportscript.js"></script>',

        [Parameter(ParameterSetName = 'ObjectHtml')]
        $title = 'DRS Report'
    )
    
    begin {
        $prefix        
    }
    
    process {
        # Determine Display Properties from Object
        if ($null -eq $DisplayProperties) {
            Write-verbose "Setting Display Properties"
            $DisplayProperties = ($InputObject[0] | get-member -MemberType NoteProperty).Name
        }

        # Initialize the Table, Colgroup, and Headers
        if ($null -eq $HtmlBodyFragment) {
            
            Write-Verbose "Initializing HTML Fragment Table Headers"

            # Setup Table
            $HtmlBodyFragment = "<table>"
            
            # Setup colgroup
            $HtmlBodyFragment += "`n<colgroup>"
            foreach ($property in $DisplayProperties) {
                $HtmlBodyFragment += "<col/>"
            }
            $HtmlBodyFragment += "</colgroup>"

            # Setup Headers
            $HtmlBodyFragment += "`n<tr>"
            foreach ($property in $DisplayProperties) {
                if ($property -ne "Status") {
                    Write-Verbose "Adding $property to Header"
                    $HtmlBodyFragment += "<th>$property</th>"
                } 
            }
            if ($DisplayProperties -contains "Status") {
                Write-Verbose "Intentially Adding Status as Last Column"
                $HtmlBodyFragment += "<th>Status</th>"
            }
            $HtmlBodyFragment += "</tr>"
        }

        # Add each item as a row
        foreach ($item in $InputObject) {
            Write-Verbose "Adding Item to Table"
            $HtmlBodyFragment += "`n<tr>"
            foreach ($property in $DisplayProperties) {
                if ($property -ne "Status") {
                    $HtmlBodyFragment += "<td>$($item.$property)</td>"
                }
            } 
            if ($DisplayProperties -contains "Status") {
                $HtmlBodyFragment += "<td>$($item.status)</td>"
            }   
            $HtmlBodyFragment += "</tr>"
        }
    }
    
    end {

        # Close out the table
        $HtmlBodyFragment += "`n</table>"

        if ($Fragment) {
            Write-Verbose "Returning Body Fragment"
            return $HtmlBodyFragment
        }
        else {
            Write-Verbose "Returning Full Html Report"
            $HtmlFull = ConvertTo-Html -CssUri "reportstyle.css" -body $HtmlBodyFragment -Title $title
            $HtmlFull
        }
    }
}
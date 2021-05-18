function Compare-Values {
    [CmdletBinding()]
    param (
        # Left side value(e.g. x in x = y)
        [Parameter(Mandatory=$true)]
        $property,

        # Comparison Operator (e.g. = in x = y)
        [Parameter(Mandatory=$true)]
        $comparator,

        # Right side value (e.g. Y in x = y)
        [Parameter(Mandatory=$true)]
        $value
    )
    
    switch ($comparator) {
        # Check for 'greater than' equivalent operators
        {"-gt", ">" -contains $_} { return $property -gt $value }

        # Check for 'less than' equivalent operators
        {"-lt","<" -contains $_} { return $property -lt $value }

        # Check for 'equals' equivalent operators
        {"-eq","==" -contains $_} {  return $property -eq $value }

        # Check for 'not equals' equivalent operators
        {"-ne", "!=" -contains $_} { return $property -ne $value }

        # Error out if unrecognized
        Default {throw "Comparator value $comparator is not a valid operator. Valid Operators include, -gt, >, -lt, <, -eq, =="}
    }
}
# JsonConfig.psm1


# Example Usage:

<#
# Set up variables
$file = join-path $PSScriptRoot 'myConfig.json'
$def = @{
  timeout = 3;
  maxConnections = 100;
  adminUsers = ('Fred', 'Wilma')
}

# Initialize config object
$config = Import-Config -filename $file -defaults $def

# Use config where needed
Do-SomethingWith -delay $config.timeout -name $config.adminUsers[0]

# Change config setting
$config.maxConnections = 9001

# Save settings to file
Export-Config -filename $file -config $config

#> 

function Import-Config {
    param(
      [Parameter(Mandatory=$true)][String]$filename,
      [Hashtable]$defaults = @{}
    )

    # If $configFileName isn't a path, Test-Path will throw, which is okay.
    if (Test-path $filename) {

        # First load the config from the file
        $config = Get-Content $filename -raw | ConvertFrom-Json

        # Add any default values that weren't in the file
        $defaults.keys | foreach {
            if (-not (gm -in $config -name $_ -MemberType NoteProperty)) { 
                Add-Member -Type NoteProperty -InputObject $config -Name $_ -Value $defaults[$_]
            }
        }
        $config
    }
    else {
        # If file doesn't exist, just return a new config
        [pscustomobject]$defaults
    }        
}

function Export-Config {
    param(
      [Parameter(Mandatory=$true)][String]$filename,
      [Parameter(Mandatory=$true)][pscustomobject]$config
    )

    $config | ConvertTo-Json | Out-File $filename

}

Export-ModuleMember Export-Config
Export-ModuleMember Import-Config
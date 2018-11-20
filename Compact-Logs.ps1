# IceChat log compacter
# 
# Usage:
# CD to logs directory
#   .\Compact-Logs.ps1 NoAgenda 2016 5
#
# batch whole year:
#   1..12 | % { .\Compact-Logs.ps1 NoAgenda 2016 $_ }
#
#
# Assumes logs are named daily with '#Channel-yyyy-MM-dd.log'
# Creates monthly log named 'Channel-yyyy-MM.log'
# Individual date is prepended to each line of log so that day isn't lost


param([string]$channel, [int]$year, [int]$month, [switch]$prependDate)

$prefix = '.\#{0}-{1}-{2:00}-*' -f $channel, $year, $month
$outfile = '.\{0}-{1}-{2:00}.log' -f $channel, $year, $month
$prepend = ""

gci $prefix | foreach {

    if ($prependDate)  {
        $prepend =  if ($_ -match '(\d{4}-\d\d-\d{2})') { "$($matches[1]) " }
    }

    Get-Content $_.FullName | foreach { 
        $prepend + $_
    } | Out-File $outfile -Append -Encoding utf8

}

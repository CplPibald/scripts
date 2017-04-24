
# Initialize $shows list from Shows.ps1
. (join-path $PSScriptRoot 'Shows.ps1')

<# 
 .Synopsis
  Polls RSS feeds for inclusion in the No Agenda stream

 .Description
  Exports a function Get-NewPodcasts which will poll the RSS feeds for several podcasts.  When it finds a new
  episode, it displays the download URL and the metadata formatted for the No Agenda stream

 .Example
   # Poll all podcasts for updates
   Get-NewPodcasts

#>
function Get-NewPodcasts {

    loadLatest

    foreach($show in $shows) {

        $page = Invoke-WebRequest $show.link
        $xml = [xml]($page.content)
        $feed = $xml.rss.channel
        $latest = $feed.item[0]

        $rssTitle = $latest.title
        $link = $latest.enclosure.url
        $pubDate = if ($show.containsKey('parseDate')) {
            (&$show.parseDate $latest.pubDate).toString('ddd, dd MMM yyyy')
        } else {
            ([datetime]$latest.pubDate).toString('ddd, dd MMM yyyy')
        }

        $showNumber, $showTitle = & $show.parse

        if ($showNumber -gt $SCRIPT:latestEpisodes[$show.name]) {

            Write-Host "New episode for $($show.name):" -ForegroundColor Yellow
            '{0} #{1}: "{2}" - {3} - {4}' -f $show.name, $showNumber, $showTitle, $pubDate, $show.tagline
            $link
            ""
            
            $SCRIPT:latestEpisodes[$show.name] = $showNumber

        } else {
            Write-Host "No new episodes for $($show.name). Latest = $($SCRIPT:latestEpisodes[$show.name]); Current = $showNumber" -ForegroundColor Gray
            ""
        }
    }
    saveLatest
}

$latestDataFile = join-path $PSScriptRoot 'latestEpisodes.txt'

function loadLatest {
    $SCRIPT:latestEpisodes = @{}
    if (test-path $latestDataFile) {
        gc $latestDataFile | % {
            $title, $num = $_ -split '='
            $SCRIPT:latestEpisodes[$title] = $num
        }
    }
}

function saveLatest {
    $SCRIPT:latestEpisodes.GetEnumerator() | % {
        "{0}={1}" -f $_.Key, $_.Value
    } | Out-File $latestDataFile

}

Export-ModuleMember Get-NewPodcasts

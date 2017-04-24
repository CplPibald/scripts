
$shows = @(
    @{
        name = "No Agenda"
        link = 'http://feed.nashownotes.com/rss.xml'
        tagline = 'Adam Curry & John C. Dvorak'
        parse = { parseRssTitle $rssTitle '^(\d+).*\"(.+)\"$' }
    },
    @{
        name = "Congressional Dish"
        link = 'http://www.congressionaldish.com/feed/podcast/'
        tagline = 'Jennifer Briney'
        parse = { parseRssTitle $rssTitle '^CD(\d+)\: (.+)$' }
    },
    @{
        name = "Agenda 31"
        link = 'http://www.agenda31.org/feed/podcast/'
        tagline = 'Corey Eib & Todd McGreevy'
        parse = { parseRssTitle $rssTitle '^A31-(\d+) . (.+)$' }
    },
    @{
        name = "DH Unplugged"
        link = 'http://www.dhunplugged.com/feed/podcast/'
        tagline = 'Andrew Horowitz & John C. Dvorak'
        parse = { parseRssTitle $rssTitle '^DHUnplugged #(\d+)\: (.+)$' }
    },
    @{
        name = "Just Getting Tech"
        link = 'https://justgettingtech.com/podcasts?format=RSS'
        tagline = 'Craig Jones & Andrew Schmidt'
        parse = { parseRssTitle $rssTitle '^(\d+)\: (.+)$' }
    },
    @{
        name = "Airline Pilot Guy"
        link = 'http://airlinepilotguy.com/podcast.xml'
        tagline = 'airlinepilotguy.com'
        parse = { parseRssTitle $rssTitle '^APG (\d+) . (.+)$' }
    },
    @{
        name = "The OO Top Ten"
        link = 'http://rynothebearded.com/category/that-show/feed/'
        tagline = 'ryno.cc'
        parse = { (([datetime]$latest.pubDate).toString('yyyyMMdd'), $rssTitle) }
    },
    @{
        name = "Nick the Rat"
        link = 'http://nicktherat.com/radio/rss.xml'
        tagline = 'nicktherat.com'
        parse = { parseRssTitle $rssTitle '^EPISODE (\d+) : (.+)$' }
        parseDate = { [datetime]($args[0] -replace '\w{3}, ') }
    },
    @{
        name = "Cordkillers"
        link = 'https://feeds.feedburner.com/CordkillersOnlyAudio'
        tagline = 'Brian Brushwood & Tom Merritt'
        parse = { parseRssTitle $rssTitle '^Cordkillers (\d+) . (.+)$' }
    },
    @{
        name = "Grimerica"
        link = 'http://grimerica.libsyn.com/rss'
        tagline = 'grimerica.ca'
        parse = { parseRssTitle $rssTitle '#(\d+) . (.+)$' }
    }
)

function parseRssTitle([string]$t, [string]$rgx) {
    # Returns (number, title)
    if ($t -match $rgx) {
        $matches[1..2]
    } else {
        (0, "CANNOT PARSE TITLE: {{$rssTitle}}")
    }
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

Export-ModuleMember Get-NewPodcasts

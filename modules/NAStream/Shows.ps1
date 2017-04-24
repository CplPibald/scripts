<#
This file creates an array called $shows containing one or more show entries.

Each show entry is a hashmap containing the following fields
  name:      The title of the podcast.  This is used as a key in data files
  link:      The URL to the rss feed for the podcast
  tagline:   Author string for the podcast.  Used for Creative Commons attribution
  parse:     PS scriptblock which returns an array (episode_number, episode_title)
  parseDate: (OPTIONAL) PS scriptblock returning a [datetime] object.  
             If omitted, then [datetime]($latest.pubDate) is used.
#>

$shows = @(
    @{
        name = "No Agenda"
        link = 'http://feed.nashownotes.com/rss.xml'
        tagline = 'Adam Curry & John C. Dvorak'
        parse = { parseRssTitle $rssTitle '^(?<num>\d+).*\"(?<title>.+)\"$' }
    },
    @{
        name = "Congressional Dish"
        link = 'http://www.congressionaldish.com/feed/podcast/'
        tagline = 'Jennifer Briney'
        parse = { parseRssTitle $rssTitle '^CD(?<num>\d+)\: (?<title>.+)$' }
    },
    @{
        name = "Agenda 31"
        link = 'http://www.agenda31.org/feed/podcast/'
        tagline = 'Corey Eib & Todd McGreevy'
        parse = { parseRssTitle $rssTitle '^A31-(?<num>\d+) . (?<title>.+)$' }
    },
    @{
        name = "DH Unplugged"
        link = 'http://www.dhunplugged.com/feed/podcast/'
        tagline = 'Andrew Horowitz & John C. Dvorak'
        parse = { parseRssTitle $rssTitle '^DHUnplugged #(?<num>\d+)\: (?<title>.+)$' }
    },
    @{
        name = "Just Getting Tech"
        link = 'https://justgettingtech.com/podcasts?format=RSS'
        tagline = 'Craig Jones & Andrew Schmidt'
        parse = { parseRssTitle $rssTitle '^(?<num>\d+)\: (?<title>.+)$' }
    },
    @{
        name = "Airline Pilot Guy"
        link = 'http://airlinepilotguy.com/podcast.xml'
        tagline = 'airlinepilotguy.com'
        parse = { parseRssTitle $rssTitle '^APG (?<num>\d+) . (?<title>.+)$' }
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
        parse = { parseRssTitle $rssTitle '^EPISODE (?<num>\d+) : (?<title>.+)$' }
        parseDate = { [datetime]($args[0] -replace '\w{3}, ') }
    },
    @{
        name = "Cordkillers"
        link = 'https://feeds.feedburner.com/CordkillersOnlyAudio'
        tagline = 'Brian Brushwood & Tom Merritt'
        parse = { parseRssTitle $rssTitle '^Cordkillers (?<num>\d+) . (?<title>.+)$' }
    },
    @{
        name = "Grimerica"
        link = 'http://grimerica.libsyn.com/rss'
        tagline = 'grimerica.ca'
        parse = { parseRssTitle $rssTitle '#(?<num>\d+) . (?<title>.+)$' }
    }
)


# Helper function taking a regex to parse a string into episode number and episode name
# The regex must contain named capture groups "num" and "title".
# Example syntax : "(?<num>\d+)"

function parseRssTitle([string]$t, [string]$rgx) {
    # Returns (number, title)
    if ($t -match $rgx) {
        $matches['num', 'title']
    } else {
        (0, "CANNOT PARSE TITLE: {{$rssTitle}}")
    }
}

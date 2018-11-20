<#
This file creates an array called $shows containing one or more show entries.

Each show entry is a hashmap containing the following fields
  name:      The title of the podcast.  This is used as a key in data files
  rssUri:      The URL to the rss feed for the podcast
  tagline:   Author string for the podcast.  Used for Creative Commons attribution
  parse:     PS scriptblock which returns an array (episode_number, episode_title)
  parseDate: (OPTIONAL) PS scriptblock returning a [datetime] object.  
             If omitted, then [datetime]($latest.pubDate) is used.
#>

$shows = @(
    @{
        name = "No Agenda"
        rssUri = 'http://feed.nashownotes.com/rss.xml'
        tagline = 'Adam Curry & John C. Dvorak'
        parse = { parseRssTitle $rssTitle '^(?<num>\d+).*\"(?<title>.+)\"$' }
    },
    @{
        name = "Congressional Dish"
        rssUri = 'http://congressionaldish.libsyn.com/rss'
        tagline = 'Jennifer Briney'
        parse = { parseRssTitle $rssTitle '^CD(?<num>\d+)\: (?<title>.+)$' }
    },
    @{
        name = "Agenda 31"
        rssUri = 'http://www.agenda31.org/feed/podcast/'
        tagline = 'Corey Eib & Todd McGreevy'
        parse = { parseRssTitle $rssTitle '^A31-(?<num>\d+) . (?<title>.+)$' }
    },
    @{
        name = "DH Unplugged"
        rssUri = 'http://www.dhunplugged.com/feed/podcast/'
        tagline = 'Andrew Horowitz & John C. Dvorak'
        parse = { parseRssTitle $rssTitle '^DHUnplugged #(?<num>\d+)\: (?<title>.+)$' }
    },
#    @{
#        name = "Just Getting Tech"
#        rssUri = 'https://justgettingtech.com/podcasts?format=RSS'
#        tagline = 'Craig Jones & Andrew Schmidt'
#        parse = { parseRssTitle $rssTitle '^(?<num>\d+)\: (?<title>.+)$' }
#    },
    @{
        name = "Airline Pilot Guy"
        rssUri = 'http://airlinepilotguy.com/podcast.xml'
        tagline = 'airlinepilotguy.com'
        parse = { parseRssTitle $rssTitle '^APG (?<num>\d+) . (?<title>.+)$' }
    },
    @{
        name = "The OO Top Ten"
        rssUri = 'http://rynothebearded.com/category/that-show/feed/'
        tagline = 'ryno.cc'
        parse = { (([datetime]$latest.pubDate).toString('yyyyMMdd'), $rssTitle) }
    },
    @{
        name = "Nick the Rat"
        rssUri = 'http://nicktherat.com/radio/rss.xml'
        tagline = 'nicktheratradio.com'
        parse = { parseRssTitle $rssTitle '^EPISODE (?<num>\d+) : (?<title>.+)$' }
        # Nick hand-edits his date strings use non-standard TZ code "EST", which is ambiguous.
        # Strip the time zone to avoid a parsing error, since we're discarding the time portion anyway
        parseDate = { [datetime]($latest.pubDate -replace ' EST') }
    },
    @{
        name = "Cordkillers"
        rssUri = 'https://feeds.feedburner.com/CordkillersOnlyAudio'
        tagline = 'Brian Brushwood & Tom Merritt'
        parse = { parseRssTitle $rssTitle '^Cordkillers (?<num>\d+) . (?<title>.+)$' }
    },
    @{
        name = "Grimerica"
        rssUri = 'http://grimerica.libsyn.com/rss'
        tagline = 'grimerica.ca'
        parse = { parseRssTitle $rssTitle '#(?<num>\d+) . (?<title>.+)$' }
    },
    @{
        name = "Rock and Roll Geek Show"
        rssUri = 'http://www.americanheartbreak.com/rnrgeekwp/feed/podcast/'
        tagline = 'Michael Butler'
        parse = {  
            if ($link -match '(\d+)\.mp3$') { $matches[1] } else { 'UNKNOWN' }
            ($rssTitle.split("–-").trim() | where { $_ -notmatch '(?:Show|Episode)\s+\d+' }) -join ' - '
        }
    },
    @{
        name = "On the Odd"
        rssUri = 'http://ontheodd.com/feed/feed.xml'
        tagline = 'ontheodd.com'
        parse = { 
            if ($link -match 's(\d+)e(\d+)\.mp3$') { 100 * $matches[1] + $matches[2] } else { 'shownum:UNKNOWN' }
            if ($rssTitle -match '^On the Odd - (.+)$') { $matches[1] } else { 'title:UNKNOWN' }
        }
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

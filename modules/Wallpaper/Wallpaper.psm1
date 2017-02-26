#Set-RandomWallpaper

<#

.EXAMPLES

  # Sets wallpaper to the given file and style
  Set-Wallpaper 'c:\pics\stripes.jpg' -style 'Fit'

  # Sets wallpaper to a random 
  Set-Nex

#>

Import-Module JsonConfig

$SCRIPT:ConfigPath = join-path $PSScriptRoot 'PSWallpaper.json'

$SCRIPT:ConfigDefaults = @{
    wallpaperExtensions = @('.jpg', '.png');
    wallpaperDirectory = [System.Environment]::GetFolderPath("MyPictures")
}

# Load configuration, and initialize if the file isn't there.
$SCRIPT:Config = Import-Config -filename $SCRIPT:ConfigPath -defaults $SCRIPT:ConfigDefaults
if (-not (Test-Path $SCRIPT:ConfigPath)) {
    Export-Config -filename $SCRIPT:ConfigPath -config $SCRIPT:Config
}

Add-Type @"
namespace Wallpaper {
    public class Setter {
        public const int SetDesktopWallpaper = 20;
        public const int UpdateIniFile = 0x01;
        public const int SendWinIniChange = 0x02;

        [System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true, CharSet = System.Runtime.InteropServices.CharSet.Auto)]
        private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);

        public static void SetWallpaperFile ( string path ) {
            SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
        }
    }
}
"@ 

function Set-Wallpaper {
    param(
        [Parameter(Mandatory=$true)]
        $Path,
        
        [ValidateSet('Keep', 'Tile', 'Center', 'Stretch', 'Fit', 'Fill', 'Span')]
        $Type = 'Keep'
    )

    $Types = @{
        'Tile' = @{Style=1; Tile=1};
        'Center' = @{Style=1; Tile=0};
        'Stretch' = @{Style=2; Tile=0};
        'Fit' = @{Style=6; Tile=0};
        'Fill' = @{Style=10; Tile=0};
        'Span' = @{Style=22; Tile=0}
    }

    if ($Type -in $Types.Keys) {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'WallpaperStyle' -Value ([string]($Types[$Type].Style))
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'TileWallpaper' -Value ([string]($Types[$Type].Tile))
    }

    [Wallpaper.Setter]::SetWallpaperFile( $Path )
}

function Set-NextWallpaper {

    $newWallpaper = gci -Path $SCRIPT:Config.WallpaperDirectory | 
        where { $SCRIPT:Config.wallpaperExtensions -contains $_.Extension } | Get-Random | select -exp FullName

    "Setting wallpaper '$newWallpaper' from path $($SCRIPT:Config.wallpaperDirectory)"

    Set-Wallpaper -Path $newWallpaper

}

Export-ModuleMember Set-Wallpaper
Export-ModuleMember Set-NextWallpaper


# mac-airport-toggle

## Toggle Airpirt WiFi On / Off when ethernet cable is connected

### Installation

1. Copy `toggleAirport.sh` to `/Library/Scripts/` folder on your MacBook
2. Open terminal and run `chmod 755 /Library/Scripts/toggleAirport.sh` command, to be sure the script is executable.
3. Copy `com.petercherm.toggleairport.plist` to `~/Library/LaunchAgents/` folder on your MacBook.
4. Restart your computer or run the following command to load the launch agent: `launchctl load -w ~/Library/LaunchAgents/com.petercherm.toggleairport.plist`


# win-terminal-ssm-connect
Scripts and settings for connecting to private EC2 instances via SSM, there are two methods built out that you can use depending on your use case. The main one will make an SSM session directly, the other starts a proxied SSH session through SSM.

## PowerShell Scripts
- Copy the scripts to a central location (Example: your %USERPROFILE% folder or "c:\scripts")

## Windows Terminal Configuration
- Copy the json configuration in the "config" folder to your Windows Terminal settings file. You can open this by opening Windows Terminal > Clicking the dropdown > Click on Settings > At the bottom left click "Open JSON file"
- Scroll down to the section named "Profiles" and add the two json objects to the bottom of that section
- Finally change the startingDirectory lines to wherever you saved the scripts.
- Save the settings.json file

Once complete a new tab will show in the dropdown that will run the scripts then connect to your instances!

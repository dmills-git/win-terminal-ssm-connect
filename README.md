# win-terminal-ssm-connect
Scripts and settings for connecting to private EC2 instances via SSM. The script will query what instances are available in the specified region then output that to a menu, you can then select the instance you want to connect to and initiate an SSM remote session.

## PowerShell Script
- Copy the script to a central location (Example: your %USERPROFILE% folder or "c:\scripts")

## Windows Terminal Configuration
- Copy the json configuration in the "config" folder to your Windows Terminal settings file. You can open this by opening Windows Terminal > Clicking the dropdown > Click on Settings > At the bottom left click "Open JSON file"
- Scroll down to the section named "Profiles" and add the json object to the bottom of that section
- Finally change the startingDirectory line to wherever you saved the script.
- Save the settings.json file

Once complete a new tab will show in the dropdown that will run the script then connect to your instances!


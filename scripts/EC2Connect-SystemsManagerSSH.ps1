# Set default values
$defaultRegion="us-east-1"
$defaultProfile = "default"
$defaultKey = ""
$defaultUser = "ec2-user"

# Set region profile and key file or accept defaults
if (($aws_region = Read-Host "Enter Region (default=$defaultRegion)") -eq '') {$aws_region = $defaultRegion} else {$aws_region}
if (($aws_profile = Read-Host "Enter Profile (default=$defaultProfile)") -eq '') {$aws_profile = $defaultProfile} else {$aws_profile}
if (($aws_key = Read-Host "Enter SSH Key (default=$defaultKey)") -eq '') {$aws_key = $defaultKey} else {$aws_key}

# Create a PS array with the values from the AWS describe call
Write-Host "Listing Available Instances in ${aws_region}:"

$myArray = @()
$myArray = aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`].Value | [0],InstanceId:InstanceId,Placement:Placement.AvailabilityZone,State:State.Name,KeyName:KeyName}' | ConvertFrom-Json
if ($myArray.count -le 0) {
    Write-Host "No instances found in this region..." -ForegroundColor Red
    Read-Host -Prompt "Press any key to exit"
    exit
}

$indexedArray = @()
for ($i = 0; $i -lt $myArray.Length; $i++) {
    $indexedArray += [PSCustomObject]@{
        Selection = $i + 1
        Name = $myArray[$i].Name
        InstanceId = $myArray[$i].InstanceId
        Placement = $myArray[$i].Placement
        State = $myArray[$i].State
        KeyName = $myArray[$i].KeyName
    }
}

# Write the menu to the console and ask user to input the selection for instance target
$indexedArray | Format-Table -AutoSize
$SelectionId = Read-Host -Prompt "Input the Selection Number for Target Instance"

# Set the instance id and type variables based on selection
$InstanceId = $indexedArray.where{$_.Selection -eq $SelectionId} | Select-Object -ExpandProperty InstanceId

# Check if Instance ID was pulled based on selection number, if not, retry input or quit
while ($InstanceId.Length -le 0) {
    Write-Host -ForegroundColor Red "Please validate selection, no instance with id of $SelectionId"
    $SelectionId = Read-Host -Prompt "Input the Selection Number for Target Instance or Ctrl+C to Exit"
    $InstanceId = $indexedArray.where{$_.Selection -eq $SelectionId} | Select-Object -ExpandProperty InstanceId
}

# Set username or accept default
if (($aws_user = Read-Host "Enter Username (default=$defaultUser)") -eq '') {$aws_user = $defaultUser} else {$aws_user}

# Create a proxied ssh connection via ssm document
try {
    ssh -o ProxyCommand="aws ssm start-session --profile ${aws_profile} --region ${aws_region} --target ${InstanceId} --document-name AWS-StartSSHSession --parameters portNumber=%p" -i $aws_key $aws_user@$InstanceId
}
catch {
    Write-Error $_.Exception.Message
    Read-Host -Prompt "Press any key to exit..."
    exit
}
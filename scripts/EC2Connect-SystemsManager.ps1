# Set default values
$defaultRegion="us-east-1"
$defaultProfile = "default"
$defaultUser = "ec2-user"

# Set region & Profile or accept defaults
if (($aws_region = Read-Host "Enter Region (default=$defaultRegion)") -eq '') {$aws_region = $defaultRegion} else {$aws_region}
if (($aws_profile = Read-Host "Enter Profile (default=$defaultProfile)") -eq '') {$aws_profile = $defaultProfile} else {$aws_profile}

# Create a PS array with the values from the AWS describe call
Write-Host "Listing Available Instances in ${aws_region}:"

$myArray = @()
$myArray = aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`].Value | [0],InstanceId:InstanceId,Placement:Placement.AvailabilityZone,State:State.Name}' | ConvertFrom-Json
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
    }
}

<# Block using SSM API to query for hosts - Removed because it didnt include tags (name specifically)
$myArray = aws ssm describe-instance-information --output json --query "InstanceInformationList[].{ InstanceId:InstanceId, PingStatus:PingStatus, PlatformName:PlatformName, AssociationStatus:AssociationStatus}" | ConvertFrom-Json
if ($myArray.count -le 0) {
    Write-Host "No Available Instances to connect to..." -ForegroundColor Red
    Read-Host -Prompt "Press any key to exit"
    exit
}

# Format the PS array into an indexed menu starting with 1
$indexedArray = @()
for ($i = 0; $i -lt $myArray.Length; $i++) {
    $indexedArray += [PSCustomObject]@{
        Selection = $i + 1
        InstanceId = $myArray[$i].InstanceId
        PingStatus = $myArray[$i].PingStatus
        PlatformName = $myArray[$i].PlatformName
        AssociationStatus = $myArray[$i].AssociationStatus
    }
}
#>

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

if (($aws_user = Read-Host "Enter Username (default=$defaultUser)") -eq '') {$aws_user = $defaultUser} else {$aws_user}

# Start the SSM remote session and issue a custom command to switch to a user bash shell according to Username variable above
aws ssm start-session --target $InstanceId --document-name AWS-StartInteractiveCommand --parameters command="sudo su -l $aws_user"
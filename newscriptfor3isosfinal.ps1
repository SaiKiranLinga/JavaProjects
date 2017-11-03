# To automate the current installation process of Replibit we are using a powerful powershell module called WASP and Powercli.
# The script takes the 1st argument to create the no.of machines.

# This is to validate the argument which we pass to the script.
 
Param(
[Parameter(Mandatory=$true)]
$pastVersion=$args[0],
[Parameter(Mandatory=$true)]
$presentVersion=$args[1]
)
Write-Host "Parsing the input"
$pastVersionParts=$pastVersion -split "/"


$presentVersionParts=$presentVersion -split "/"
Write-Host "$pastVersionParts[0]"
$pastVersions="$($pastVersionParts[0])_$($pastVersionParts[1])_$($pastVersionParts[2])"
$currentVersion="$($presentVersionParts[0])_$($presentVersionParts[1])_$($presentVersionParts[2])"
Write-Host "$currentVersion"
# These modules contain the functions with credentials to do their respective tasks of connecting to server and logging to Replibit appliance.


Write-Host "Importing the modules"
Import-Module VMware.VimAutomation.Core
Import-Module Get-DenverConnection
Import-Module Send-CredentialsForThreeIsos
Import-Module Send-ScpCredentials
# Connect to the server.This is a self defined function which is part of the module Get-Connection.
Write-Host "Establishing Connection..."
Start-Sleep -s 3
Get-DenverEsxiConnection
Write-Host "Creating the VMs"
Start-Sleep -s 2
# This for loop will Create the no. of VMs we pass as the initial argument to the script
$a="nano.iso"
$b="NG.iso"
$c="prod.iso"
$names=$a,$b,$c
ForEach($VM in $names){

$Exists=Get-VM -Name $VM -ErrorAction SilentlyContinue
if($Exists)
{
Stop-VM -VM $VM  -Confirm:$false
Start-Sleep -s 3
Remove-VM -VM $VM -Confirm:$false -DeleteFromDisk

Start-Sleep -s 3
# Create a new VM with the required Configuration

New-VM -Name $VM  -Confirm:$false  -DiskGB 100 -DiskStorageFormat Thin -MemoryGB 8  -GuestId ubuntu64Guest  -NumCpu 2  -VMHost 10.128.0.194
Start-Sleep -s 3
}
Else 
{
New-VM -Name $VM  -Confirm:$false  -DiskGB 100 -DiskStorageFormat Thin -MemoryGB 8  -GuestId ubuntu64Guest  -NumCpu 2  -VMHost 10.128.0.194
Start-Sleep -s 3
}

# Add a CD-Drive and use the iso from the Datastore
$ISO='replibit'+'_'+$pastVersions+'_'+$VM
Write-Host "$ISO"
$ISOPATH="[datastore1] Setup_ISOs\"+"$ISO"
Write-Host "$ISOPATH"
New-CDDrive -VM $VM -IsoPath "$ISOPATH" -StartConnected
Start-Sleep -s 3
Start-VM -VM $VM
}





# The use of multiple Sleeps is due to the fact that sometimes due to network issues the execution time 
# of previous command might override the sleep so having multiple chunks of sleep is better than having one

Start-Sleep -s 10 
Start-Sleep -s 10 
Start-Sleep -s 10
Start-Sleep -s 10 
Start-Sleep -s 10
Start-Sleep -s 10 


ForEach($VM in $names){

# Open the VMRC console

Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2



# Here in this approach we are communicating with the GUI and trying to move forward with the installation process of Replibit.
# So ideally speaking all the things which can be done with the keyboard and the GUI can be automated.
# The below commands will fetch the vmrc console window and set it active

$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 1
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 1
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 1
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2

Add-Type -AssemblyName System.Windows.Forms
Start-Sleep -s 1
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 1 

Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1	
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1	
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1

Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 2
Stop-Process -processname vmrc
Start-Sleep -s 2
}

# The installation process approximately takes this much of time for completion

Start-Sleep -s 200
Start-Sleep -s 40
Start-Sleep -s 40




# These are the chunks in the installation process which we need to automate like the button clicks and pressing enter. 

ForEach($VM in $names){
Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 3
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 10
Stop-Process -processname vmrc
Start-Sleep -s 3
}


Start-Sleep -s 40
Start-Sleep -s 40

ForEach($VM in $names){
Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 3
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 10
Stop-Process -processname vmrc
Start-Sleep -s 3
}


Start-Sleep -s 20
Start-Sleep -s 20
Start-Sleep -s 10
Start-Sleep -s 20
Start-Sleep -s 10

# This is a self defined function which is there in the module Send-Credentials.So we have to make sure to import the module before using this command.
# Using this command we send the credentials to all the VMs to login. 
Write-Host "Sending the credentials"
Start-Sleep -s 3
ForEach($VM in $names){
Send-ReplibitISOCredentials -a $VM 
}
Start-Sleep -s 8

ForEach($VM in $names){
Get-VM $VM | Open-VMConsoleWindow 

Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2

$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 2
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2

Add-Type -AssemblyName System.Windows.Forms
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 2
$wshell.SendKeys('repenv')
Start-Sleep -s 3
$wshell.SendKeys('~')
Start-Sleep -s 2

# add alpha repo entry
Write-Host "adding alpha repo entry"

$wshell.SendKeys('echo "')
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('35.162.9.3       pkgmgrrepo.replibit.net">>')
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('/etc/hosts')
Start-Sleep -s 1
$wshell.SendKeys('~')
$wshell.SendKeys('cd /var/pkg')
Start-Sleep -s 3
$wshell.SendKeys('+m')
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('gr/')
Start-Sleep -s 1
$wshell.SendKeys('~')
Write-Host "Upgrading the package"

Start-Sleep -s 12
Start-Sleep -s 1
$wshell.SendKeys('python pkg')
Start-Sleep -s 1
$wshell.SendKeys('+i')
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('nstall.py ')
Start-Sleep -s 1
$wshell.SendKeys('+r')
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('eplibit')
Start-Sleep -s 1
$wshell.SendKeys('+c')
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('ore')
Start-Sleep -s 1
$wshell.SendKeys('~')
Stop-Process -processname vmrc
Start-Sleep -s 3
}


Start-Sleep -s 180


Start-Sleep -s 40

ForEach($VM in $names){
Get-VM $VM | Open-VMConsoleWindow 

Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2


Write-Host "Removing the alpha repo entry"
Start-Sleep -s 3
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 2
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2

Add-Type -AssemblyName System.Windows.Forms
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 2
$wshell.SendKeys('egrep -v "')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('35.162.9.3"')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys(' /etc/hosts >')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys(' /tmp/hosts.test')

$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
$wshell.SendKeys('cp /tmp/hosts.test /etc/hosts')
Start-Sleep -s 2
$wshell.SendKeys('~')

# Check the /etc/hosts file
$wshell.SendKeys('cat /etc/hosts')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
Stop-Process -processname vmrc
}
Start-Sleep -s 2



ForEach($VM in $names){
Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 2
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2
Add-Type -AssemblyName System.Windows.Forms
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 2

Write-Host "scp the background image"
Start-Sleep -s 3
# scp the background image

$wshell.SendKeys('scp jenkins@')
Start-Sleep -s 3
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('10.128.2.216:')
Start-Sleep -s 1
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('/home/jenkins/D')
Start-Sleep -s 1
$wshell.SendKeys('+')
Start-Sleep -s 1
$wshell.SendKeys('esktop/warty-final-ubuntu.png /usr/share/backgrounds')
Start-Sleep -s 3
$wshell.SendKeys('~')
Start-Sleep -s 4
$wshell.SendKeys('jenkins')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 8
$wshell.SendKeys('initctl start asyncreboot')
Start-Sleep -s 3
$wshell.SendKeys('~')
Stop-Process -processname vmrc

}
Start-Sleep -s 3 
Start-Sleep -s 20
Start-Sleep -s 20
Start-Sleep -s 20
Start-Sleep -s 20

Write-Host "Send ISO Credentials"
ForEach($VM in $names){
Send-ReplibitISOCredentials -a $VM 
}

$names1=$a,$c
ForEach($VM in $names1){
Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 2
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2
Add-Type -AssemblyName System.Windows.Forms
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 2
$wshell.SendKeys(' history -c')
Start-Sleep -s 3
$wshell.SendKeys('~')
$wshell.SendKeys(' history -w')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
Start-Sleep -s 2
$wshell.SendKeys(' remastersys backup replibit')
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($($presentVersionParts[0]))
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($($presentVersionParts[1]))
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($($presentVersionParts[2]))
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($VM)
Start-Sleep -s 2
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
Stop-Process -processname vmrc

}


Write-Host "Remastersys command"
Start-Sleep -s 3
$names2=$b

ForEach($VM in $names2){


Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 2
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2
Add-Type -AssemblyName System.Windows.Forms
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 2
$wshell.SendKeys(' history -c')
Start-Sleep -s 3
$wshell.SendKeys('~')
$wshell.SendKeys(' history -w')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
Start-Sleep -s 2
$wshell.SendKeys(' remastersys backup replibit')
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($($presentVersionParts[0]))
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($($presentVersionParts[1]))
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys($($presentVersionParts[2]))
Start-Sleep -s 2
$wshell.SendKeys('_')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('NG')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('.iso')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
Stop-Process -processname vmrc

}


Start-Sleep -s 800 
Write-Host "Turning on SSH"
Start-Sleep -s 3
Get-VMHostService -VMHost 10.128.0.194 | ?{$_.Label -eq "SSH"} | Start-VMHostService
Start-Sleep -s 2
Write-Host "scp the isos from the VMs to the Datastore" 
ForEach($VM in $names){
Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 2
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$App="$VM - VMware Remote Console"
Start-Sleep -s 2
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 2
$wshell.AppActivate($App)
Start-Sleep -s 2
Add-Type -AssemblyName System.Windows.Forms
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 2
$wshell.SendKeys('scp /home/remastersys/remastersys/replibit_*')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys(' root@')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('10.128.0.194:')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('/vmfs/volumes/59087358-4128399a-e8a6-d05099c1490d/S')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('etup_ISO')
Start-Sleep -s 2
$wshell.SendKeys('+')
Start-Sleep -s 2
$wshell.SendKeys('s/')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
Stop-Process -processname vmrc
Start-Sleep -s 2
Send-ScpCredentialsEsxi -a $VM
$wshell.SendKeys('~')

}
Start-Sleep -s 30

Write-Host "Turning off SSH"

Get-VMHostService -VMHost 10.128.0.194 | ?{$_.Label -eq "SSH"} | Stop-VMHostService -Confirm:$false

#copy datastore items to local directory but before that create the directory

New-Item -ItemType directory -Path C:\$currentVersion

$datastore=Get-Datastore "datastore1"
New-PSDrive -Location $datastore -Name ds -PSProvider VimDatastore -Root "\"
Start-Sleep -s 2
$iso=$("replibit_"+$currentVersion+"_*") 
Start-Sleep -s 2
Write-Host "Copying the isos from the datastore to the local directory"
Start-Sleep -s 2
Copy-DatastoreItem -Item ds:\Setup_ISOs\$iso C:\$currentVersion\


#Create new machines with the new ISO





ForEach($VM in $names){

$d=$VM
$VM=$VM+'testing'
Start-Sleep -s 3
$Exists=Get-VM -Name $VM -ErrorAction SilentlyContinue
Start-Sleep -s 2
if ($Exists){
Stop-VM -VM $VM  -Confirm:$false
Start-Sleep -s 3
Remove-VM -VM $VM -Confirm:$false -DeleteFromDisk

Start-Sleep -s 3
# Create a new VM with the required Configuration

New-VM -Name $VM  -Confirm:$false  -DiskGB 100 -DiskStorageFormat Thin -MemoryGB 8  -GuestId ubuntu64Guest  -NumCpu 2  -VMHost 10.128.0.194
Start-Sleep -s 3
}
Else {
New-VM -Name $VM  -Confirm:$false  -DiskGB 100 -DiskStorageFormat Thin -MemoryGB 8  -GuestId ubuntu64Guest  -NumCpu 2  -VMHost 10.128.0.194
Start-Sleep -s 3
}

# Add a CD-Drive and use the iso from the Datastore
$ISO1='replibit'+'_'+$currentVersion+'_'+$d
Start-Sleep -s 2
Write-Host "$d"

Write-Host "$ISO1"
$ISOPATH1="[datastore1] Setup_ISOs\"+"$ISO1"
Write-Host "$ISOPATH1"



New-CDDrive -VM $VM -IsoPath "$ISOPATH1" -StartConnected
Start-Sleep -s 3

New-HardDisk -VM $VM -CapacityGB 200 -ThinProvisioned
Start-Sleep -s 3
New-HardDisk -VM $VM -CapacityGB 200 -ThinProvisioned
Start-Sleep -s 3

# Enable Hardware Virtualization for all the VMs

$vmName = Get-VM -Name $VM
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.nestedHVEnabled = $true
$vmName.ExtensionData.ReconfigVM($spec)

Start-Sleep -s 3

# Set disk.enableUUID = true 

$vmName | New-AdvancedSetting -Name ‘disk.enableUUID’ -Value ‘true’ -Confirm:$false
Start-Sleep -s 3
Start-VM -VM $VM 
Start-Sleep -s 3

}



Start-Sleep -s 10 
Start-Sleep -s 10 
Start-Sleep -s 10
Start-Sleep -s 10 
Start-Sleep -s 10
Start-Sleep -s 10 
Write-Host "Installing the Replibit-Ubuntu OS in the test VMs"
Start-Sleep -s 3
ForEach($VM in $names){


$VM=$VM+'testing'
# Open the VMRC console

Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2



# Here in this approach we are communicating with the GUI and trying to move forward with the installation process of Replibit.
# So ideally speaking all the things which can be done with the keyboard and the GUI can be automated.
# The below commands will fetch the vmrc console window and set it active

$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 1
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 1
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 1
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 1
$App="$VM - VMware Remote Console"
Start-Sleep -s 1
$wshell.AppActivate($App)
Start-Sleep -s 1
Add-Type -AssemblyName System.Windows.Forms
Start-Sleep -s 1 
Select-window $ProcessName |Select-Control|Send-Click
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 2
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1	
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1	
Select-window $ProcessName |Send-Keys "{TAB}"
Start-Sleep -s 1

Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 2
Stop-Process -processname vmrc
Start-Sleep -s 2
}

# The installation process approximately takes this much of time for completion

Start-Sleep -s 200
Start-Sleep -s 40
Start-Sleep -s 40




# These are the chunks in the installation process which we need to automate like the button clicks and pressing enter. 

ForEach($VM in $names){

$VM=$VM+'testing'

Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 3
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 10
Stop-Process -processname vmrc
Start-Sleep -s 3
}


Start-Sleep -s 40
Start-Sleep -s 40

ForEach($VM in $names){

$VM=$VM+'testing'
Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2
$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 3
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 1
Select-window $ProcessName |Send-Keys "~"
Start-Sleep -s 10
Stop-Process -processname vmrc
Start-Sleep -s 3
}


Start-Sleep -s 20
Start-Sleep -s 20
Start-Sleep -s 10
Start-Sleep -s 20
Start-Sleep -s 10

# This is a self defined function which is there in the module Send-Credentials.So we have to make sure to import the module before using this command.
# Using this command we send the credentials to all the VMs to login. 
Write-Host "Sending Credentials"
Start-Sleep -s 2
ForEach($VM in $names){


$VM=$VM+'testing'
Send-ReplibitISOCredentials -a $VM 
}

Start-Sleep -s 8



$name="prod.iso"
$rel=$name
ForEach($VM in $rel){


$VM=$VM+'testing'
# Open the VMRC console

Get-VM $VM | Open-VMConsoleWindow 
Start-Sleep -s 2
Start-Sleep -s 2
Start-Sleep -s 2


Write-Host "sending apt-get install open-vmtools to prod vm"
Start-Sleep -s 3
# Here in this approach we are communicating with the GUI and trying to move forward with the installation process of Replibit.
# So ideally speaking all the things which can be done with the keyboard and the GUI can be automated.
# The below commands will fetch the vmrc console window and set it active

$ProcessName = Get-Process |Where-Object { $_.Name -Like 'vmrc' } |foreach {$_.Name}
Start-Sleep -s 1
Select-window $ProcessName |Set-WindowActive
Start-Sleep -s 1
Select-window $ProcessName |Select-Control|Send-Click
Start-Sleep -s 1

$App="$VM - VMware Remote Console"
Start-Sleep -s 1
$wshell = New-Object -ComObject wscript.shell
Start-Sleep -s 1
$wshell.AppActivate('$App')
Start-Sleep -s 1
Add-Type -AssemblyName System.Windows.Forms
Start-Sleep -s 2
Select-window $ProcessName |Select-Control|Send-Click 
Start-Sleep -s 2
$wshell.SendKeys('apt-get install open-vm-tools')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 10
$wshell.SendKeys('y')
Start-Sleep -s 2
$wshell.SendKeys('~')
Start-Sleep -s 3
Stop-Process -processname vmrc
Start-Sleep -s 20
Start-Sleep -s 20

Stop-VM -VM $VM -Confirm:$false

}
Start-Sleep -s 8
Write-Host "Creating the OVA"
Start-Sleep -s 2
$newVMName=$($name+"_"+$currentVersion)
Set-VM $VM -name $newVMName -Confirm:$false
Start-Sleep -s 3
Get-VM -Name $newVMName | Export-VApp -Destination "C:\OVAFiles" -Format Ova
Start-Sleep -s 3
$fileName=$($newVMName+".ova")
$filePath="C:\OVAFiles\"+$fileName

if([IO.File]::Exists($filePath) -ne $false)
{
Write-Host "Copying the OVA to the datastore"
Start-Sleep -s 2
$datastore=Get-Datastore "datastore1"
Start-Sleep -s 2
New-PSDrive -Location $datastore -Name ds -PSProvider VimDatastore -Root "\"
Start-Sleep -s 2
Copy-DatastoreItem -Item $filePath ds:\Setup_OVAs\
Start-Sleep -s 2
Write-Host "Copying the local OVA file to the datastore."
}

# edit the Send iso credentials and test the ova file creation And make sure that there is no hard coding of the passwords in the script Add write host and plan to move to github and add scp to local too in a folder add disable ssh of host. Try to create the exit code.
#rename the vm prod.isotesting to prod_version.iso so that you create the ova proper
#Set-VM $VM -name 'newvmname' -Confirm:$false
#Create a new directory in C:\ISOFILES\ISOversion and copy datastore item isos and
#md5s to this
#add     $datastore=Get-Datastore "datastore1" 
#Copy-DatastoreItem -Item ds:\Setup_ISO\replibit_version* C:\ISOFILES\ISOversion
#copy the iso and the md5 to the local folder..
#change the scp command to change to upload the md5 too to the datastore..
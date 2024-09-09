    # NOTE: To be added - automatic filtering between APP, STR, MOB etc.
    # NOTE: To be added - drop EUROLIVE\ and .riga.eurolivetech.com from results.
    # NOTE: To be added - remove trailing spaces so that we can create good *.csv.

# In order to store results we define an array:
$result = @()
# And read desired subnet:
$subnetName = Read-Host "Input subnet (2 numbers):"

# So we loop over all /24 subnet:
for ($i = 0; $i -le 254; $i++) 
{ 
  $ip =  '10.10.' + $subnetName + '.' + $i
  # For some reason there appears space between 62. and current IP, so we drop that.
  $ip = $ip -replace '\s',''
  # Reduced packet size and count to make things go quicker.
  $ipUsed = Test-Connection $ip -BufferSize 16 -Count 2 -Quiet
  
  if ($ipUsed -eq 'True'){
    # Domain name:
    $name = [System.Net.Dns]::GetHostEntry($ip)
    # Logged on user, if any:
    $currentUser = @(Get-WmiObject -ComputerName $ip -Namespace root\cimv2 -Class Win32_ComputerSystem -erroraction silentlycontinue)[0].UserName
    # Display output line, basicall just for monitoring purpose:
    Write-Host $ip ' in use by name: ' $name.HostName ' and has logged on user: ' $currentUser
    # NOTE: We can pull basically anything from WMI.

    # Now we update results a bit:
    $currentUser = $currentUser -creplace '^[^\\]*\\', ''
    $name = $name | Select-Object -ExpandProperty HostName
    $name = $name.Substring(0, $name.IndexOf('.'))
    $name = $name.ToUpper()
    # Now to get type:
    $pcType = $name.Substring($name.Length - 3)
    $pcType = $pcType.ToUpper()

    # Object is used so that we can save each cycle as separate line.
    # As we need separate columns, we populate object with properties:
    $item = New-Object psobject
    $item | Add-Member -MemberType NoteProperty "IP" -Value $ip
    $item | Add-Member -MemberType NoteProperty "Domain Name" -Value $name
    $item | Add-Member -MemberType NoteProperty "User" -Value $currentUser
    $item | Add-Member -MemberType NoteProperty "PC Type" -Value $pcType
    # Publish to array:
    $result += $item

  } else {
    Write-Host $ip ' not in use on network!'
  }
}

$fileName = "C:\Temp\SubnetSnoop" + $subnetName + ".csv"
$result | Out-GridView
$result | Out-File $fileName

#*====================================================================================================================
#* CHANGE LOG
#*====================================================================================================================
#
# 01/01/2016 - initial version.
# 02/12/2016 - 1.1.0
#              Added object and array based output.
#              Added subnet choice option.
# 04/12/2016 - 1.1.1
#              Added PC Type, fixed formatting.
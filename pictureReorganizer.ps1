#*====================================================================================================================
#* Bilžu kārtošanas programma
#* Version: 1.0.0
#* Author: K.Bergmanis
#*====================================================================================================================

#*====================================================================================================================
#* FUNCTION LISTINGS
#*====================================================================================================================
Function Write-Log {
<#
.SYNOPSIS
    Writes output to the console and log file simultaneously
.DESCRIPTION
    This functions outputs text to the console and to the log file specified in the XML configuration.
    The date, time and installation phase is pre-pended to the text, e.g. [30-07-2013 11:27:07] [Initialization] "Deploy Application script version is [2.0.0]"
.EXAMPLE
    Write-Log -Text "This is a custom message..."
.PARAMETER Text
    The text to display in the console and to write to the log file
.PARAMETER PassThru
    Passes the text back to the PowerShell pipeline
.NOTES
.LINK
    Http://psappdeploytoolkit.codeplex.com
#>
    Param(
        [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [array] $Text,
        [switch] $PassThru = $false
    )
    Process {
        $Text = $Text -join (" ")
        $currentDate = (Get-Date -UFormat "%d-%m-%Y")
        $currentTime = (Get-Date -UFormat "%T")
        If (!$VMComputerName) {$VMComputerName = $env:COMPUTERNAME}
        $logEntry = "[$currentDate $currentTime] [$VMComputerName] $Text"
        Write-Host $logEntry
        If ($DisableLogging -eq $false) {
            # Create the Log directory and file if it doesn't already exist
            If (!(Test-Path -Path $LogDir -ErrorAction Stop )) { New-Item $LogDir -Type Directory -ErrorAction Stop | Out-Null }
            #New-Item $LogDir -Type Directory -ErrorAction Stop | Out-Null
            If (!(Test-Path -Path $logFile -ErrorAction Stop )) { New-Item $logFile -Type File -ErrorAction Stop | Out-Null }
            #New-Item $logFile -Type File -ErrorAction Stop | Out-Null
            Try {
                "$logEntry" | Out-File $logFile -Append -ErrorAction Stop
            }
            Catch {
                $exceptionMessage = "$($_.Exception.Message) `($($_.ScriptStackTrace)`)"
                Write-Host "$exceptionMessage"
            }
        }
        If ($PassThru -eq $true) {
            Return $Text
        }
    }
}
#End Function

#*====================================================================================================================
#* SET SCRIPT VARIABLES
#*====================================================================================================================
# Time
$currentDate = (Get-Date -UFormat "%Y-%m-%d")
$currentTime = (Get-Date -Format "HH-mm-ss")

# Logs
$logdir = New-Item "C:\Temp\Logs" -ItemType Directory -Force
$LogFileName = 'Folder organizing on ' + $currentDate +' '+ $currentTime + '.log'
$logFile = $LogDir + '\' + $LogFileName 
$DisableLogging = $false

#*====================================================================================================================
#* EXECUTION 
#*====================================================================================================================
# Nodefinējam programmas logu:
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  
$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(600,300)
$form.Text = "Arhīva kārtotājs"  
Write-Log -Text "Programma palaista $date"
$pictureDir = "Izvēlies mapi..."

# Darba mape:
$InputBox = New-Object System.Windows.Forms.TextBox 
$InputBox.Location = New-Object System.Drawing.Size(20,20) 
$InputBox.Size = New-Object System.Drawing.Size(300,20)
$InputBox.Text = $pictureDir
$Form.Controls.Add($InputBox)
# Darba mapes nosaukums:
$InputBoxName = New-Object System.Windows.Forms.Label
$InputBoxName.Location = New-Object System.Drawing.Size (20,310)
$InputBoxName.Text = "Kārtojamā mape:"
$InputBoxName.AutoSize = $True
$Form.Controls.Add($InputBoxName)
# Mapes izvēles poga:
$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(320,20) 
$Button.Size = New-Object System.Drawing.Size(100,20) 
$Button.Text = "Izvēlēties mapi" 
$Button.Add_Click({
    # Select folder dialogs.
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $pictureDir = New-Object System.Windows.Forms.FolderBrowserDialog
    $pictureDir.rootfolder = "MyComputer"
    $pictureDir.ShowDialog()
    $InputBox.Text = $pictureDir.SelectedPath
    $outputBox.AppendText("`r`nMape izvēlēta...")
    $pictureDir = $InputBox.Text
    Write-Log -Text "Izvēlētā mape: $pictureDir" 
    })
$Form.Controls.Add($Button)

# What-If check box
$checkbox1 = new-object System.Windows.Forms.checkbox
$checkbox1.Location = new-object System.Drawing.Size(40,50)
$checkbox1.Size = new-object System.Drawing.Size(310,50)
$checkbox1.Text = "Strādāt drošajā režīmā, t.i., tikai parādīt izmaiņas?"
$checkbox1.Checked = $true
$Form.Controls.Add($checkbox1)  

# Kārtošanas poga
$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(440,20) 
$Button.Size = New-Object System.Drawing.Size(110,80) 
$Button.Text = "Kārtot!" 
$Button.Add_Click({
    $outputBox.AppendText("`r`nSākam kārtot " + $InputBox.Text + " ...")
    Write-Log -Text "Kārtošana uzsākta!"
    # Actual program code goes here:
    cd $InputBox.Text
    $dirList = Get-ChildItem $InputBox.Text -Recurse -Depth 0 -Directory
    # -Depth 0 means only folders within target dir.
    
    # Organizēšanas sākums:
    ForEach ($dir in $dirList){
    $picture = Get-ChildItem $dir -Filter *.jpg | Select-Object -First 1
    # We get an object - first jpg in every directory.
    if ($picture -like $null) {continue}
    # In cases where folder doesn't contain any .jpg files, value will be null, and Continue skips to next ForEach element.

        # Method completely stolen from:
        # http://stackoverflow.com/questions/6834259/how-can-i-get-programmatic-access-to-the-date-taken-field-of-an-image-or-video
        $shellObject = New-Object -ComObject Shell.Application
        $directoryObject = $shellObject.NameSpace( $picture.Directory.FullName )
        $fileObject = $directoryObject.ParseName( $picture.Name )

        $property = 'Date taken'
        for(
            $index = 5;
            $directoryObject.GetDetailsOf( $directoryObject.Items, $index ) -ne $property;
            ++$index ) { }
        # And our result is this:
        $takenDate = $directoryObject.GetDetailsOf( $fileObject, $index )

    # At this point name looks like "  2016.04.02. 11:45:02     ".
    $takenDate = $takenDate.Trim()
    # This removes whitespaces, tabs, new lines etc.
    # "2016.04.02. 11:45:02"
    $pos = $takenDate.IndexOf(" ")
    # Next we search for break symbol
    $pictureDate = $takenDate.Substring(0, $pos)
    # This creates new string containing only symbols from 0th Symbol to break symbol.
    # "2016.04.02."
    $pictureDate = $pictureDate.Substring(0,$pictureDate.Length-1)
    # And we drop last symbol.
    # "2016.04.02"
    $pictureDate = $pictureDate.replace('.','-')
    # And replace every . to -.
    # "2016-04-02"

    $newName = $pictureDate + " " + $dir
    # New name syntax will be "2016-04-02 OldName"
    if ($checkbox1.Checked -eq $True){
        Rename-Item $dir $newName -WhatIf    
        Write-Log -text "$dir tiktu pārsaukts par $newName."
        $outputBox.AppendText("`r`n$dir tiktu pārsaukts par $newName")
        }
    if ($checkbox1.Checked -eq $false){
        Rename-Item $dir $newName
        Write-Log -text "$dir pārsaukts par $newName."
        $outputBox.AppendText("`r`n$dir pārsaukts par $newName")        
        }
    # In case where we deal with large amounts or sensitive data, add -Whatif switch to see planned changes
    # Instead of performing them.
    # Alternative, comment Rename-Item out and just read log file.
    
    }
    # Organizēšanas beigas.
    Write-Log -text "Kārtošana pabeigta, vari aizvērt logu!"
    $outputBox.AppendText("`r`nKārtošana pabeigta, vari aizvērt logu!")
        }) 
$Form.Controls.Add($Button) 

# Statusa logs:
$outputBox = New-Object System.Windows.Forms.TextBox 
$outputBox.Location = New-Object System.Drawing.Size(10,150) 
$outputBox.Size = New-Object System.Drawing.Size(565,100) 
$outputBox.MultiLine = $True 
$outputBox.ScrollBars = "Vertical" 
$outputBox.AppendText("Labrīt!")
$Form.Controls.Add($outputBox) 

# Parādīt formu:
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()

#*====================================================================================================================
#* Change Log:
#*====================================================================================================================
# 2016-10-05 Initial version
#      Functional script.
#      Added Null value folder check.
#      Added logging.
#      Added comments for visibility.
# 2016-10-07 0.2.0
#      Replaced PictureTakenOn instead of Created.
# 2019-06-04 1.0.0
#      Full rehaul with GUI.
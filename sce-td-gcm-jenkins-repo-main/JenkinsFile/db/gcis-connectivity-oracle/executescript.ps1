dir env:
$Env:ORACLE_HOME = "E:\Oracle19\product\19.0.0\client_1"
# code for running the install/rollback sql
$ConnectStr = $env:DB_CRED_USR + '/' + $env:DB_CRED_PSW + $env:DB_CONN_STR
#$ConnectStr = 'TCGACDS_FLBK/Edison_9089@ayxp05-scan.sce.com:1526/L904_CYME'         #for local testing
#$ENV:ACTION = "INSTALL"                                                             #for local testing
#$ENV:WORKSPACE = "C:\GitRepo\gcis-connectivity-oracle"                              #for local testing
Write-Host "executescript:Connect String:"$ConnectStr",INPUT Branch:"$ENV:GIT_BRANCH",Git Commit:" $ENV:GIT_COMMIT
if(Test-Path -Path "$ENV:WORKSPACE\CICD\installscript.sql" -PathType Leaf) {
write-host "executescript:Install/Rollback Scripts found. Proceeding with Install/Rollback"   
if ($ENV:ACTION -eq "INSTALL"){
      #remove whitespace lines from install script
#      (gc "$ENV:WORKSPACE\CICD\installscript.sql") | ? {$_.trim() -ne "" } | set-content "$ENV:WORKSPACE\CICD\installscript_withoutemptylines.sql"
      $lines = Get-Content "$ENV:WORKSPACE\CICD\installscript.sql"
      $filteredLines = for ($i = 0; $i -lt $lines.Count; $i++) {
          if ($lines[$i].Trim() -ne "" -or ($lines[$i+1].Trim() -match '^--%')) {
              $lines[$i]
          }
      }
      $filteredLines | Set-Content "$ENV:WORKSPACE\CICD\installscript_withoutemptylines.sql"

      $Script_InputFile     = $ENV:WORKSPACE+"\CICD\installscript_withoutemptylines.sql"                                  # Input SQL File
      write-host "executescript:Installing SQL Script" $Script_InputFile
      $Script_OutputFile = $Script_InputFile + "output.log"
      E:/Oracle19/product/19.0.0/client_1/bin/sqlplus $ConnectStr "@.\CICD\installscript_withoutemptylines.sql" | out-file $Script_OutputFile
      write-host "executescript:Installing SQL Script Completed" $Script_InputFile
}
else {
      #remove whitespace lines from rollback script
#      (gc "$ENV:WORKSPACE\CICD\rollbackscript.sql") | ? {$_.trim() -ne "" } | set-content "$ENV:WORKSPACE\CICD\rollbackscript_withoutemptylines.sql"
      $lines = Get-Content "$ENV:WORKSPACE\CICD\rollbackscript.sql"
      $filteredLines = for ($i = 0; $i -lt $lines.Count; $i++) {
      if ($lines[$i].Trim() -ne "" -or ($lines[$i+1].Trim() -match '^--%')) {
            $lines[$i]
      }
      }
      $filteredLines | Set-Content "$ENV:WORKSPACE\CICD\rollbackscript_withoutemptylines.sql"

      $Script_InputFile     = $ENV:WORKSPACE+"\CICD\rollbackscript_withoutemptylines.sql"   	
      write-host "executescript:Rollback SQL Script Initiated" $Script_InputFile	
      $Script_OutputFile = $Script_InputFile + "output.log"
      E:/Oracle19/product/19.0.0/client_1/bin/sqlplus $ConnectStr "@.\CICD\rollbackscript_withoutemptylines.sql" | out-file $Script_OutputFile
      write-host "executescript:Rollback SQL Script Completed" $Script_InputFile
}
Write-Host "executescript:Input SQL File::"$Script_InputFile",Output SQL Log File:" $Script_OutputFile
}
else {
      write-host "Install/Rollback Scripts not found. Skipping Install/Rollback"    
}  
write-host "start compare table in different environment"
[System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess")
$report_filename = $ENV:WORKSPACE+"\JenkinsFile\gcis-data-table-compare2\sql-output\finalReport.txt"
$issue_filename = $ENV:WORKSPACE+"\JenkinsFile\gcis-data-table-compare2\sql-output\issueReport.txt"
$report_filenameCSV = $ENV:WORKSPACE+"\JenkinsFile\gcis-data-table-compare2\sql-output\finalReportCSV.csv"
$issue_filenameCSV = $ENV:WORKSPACE+"\JenkinsFile\gcis-data-table-compare2\sql-output\issueReportCSV.csv"
$ems_table_path = ".\\JenkinsFile\\gcis-data-table-compare2\\resource\\emsTable.txt"
$scim_table_path = ".\\JenkinsFile\\gcis-data-table-compare2\\resource\\scimTable.txt"
$result = "Source db: $env:SRC_DB_CONN_STR Target db: $env:TGT_DB_CONN_STR"
$issueResult = "Source db: $env:SRC_DB_CONN_STR Target db: $env:TGT_DB_CONN_STR"
$resultCSV = "table_name, source_count, target_count, difference"
$issueResultCSV = "table_name, source_count, target_count, difference"

write-host "prepare function"
function src_exe([string]$querystring) {
    
    $src_sel_stmt.CommandText = $querystring

    $src_rdr = $src_sel_stmt.ExecuteReader()
    while ($src_rdr.Read()) {
        if($($src_rdr.GetOracleString(0).Value))
        {
            return $($src_rdr.GetOracleString(0).Value)/1
        }
    }
}

function tgt_exe([string]$querystring) {
    
    $tgt_sel_stmt.CommandText = $querystring

    $tgt_rdr = $tgt_sel_stmt.ExecuteReader()
    while ($tgt_rdr.Read()) {
        if($($tgt_rdr.GetOracleString(0).Value))
        {
            return $($tgt_rdr.GetOracleString(0).Value)/1
        }
    }
}


try
{
    write-host "start db connection..."
    $SRC_DB_connection_string = $env:SRC_DB_CONN_STR.substring(1);
    $SRC_con   = new-object Oracle.DataAccess.Client.OracleConnection "User Id=$env:SRC_DB_CRED_USR;Password=$env:SRC_DB_CRED_PSW;Data Source=$SRC_DB_connection_string"

    $TGT_DB_connection_string = $env:TGT_DB_CONN_STR.substring(1);
    $TGT_con   = new-object Oracle.DataAccess.Client.OracleConnection "User Id=$env:TGT_DB_CRED_USR;Password=$env:TGT_DB_CRED_PSW;Data Source=$TGT_DB_connection_string"

    $SRC_con.Open()
    $TGT_con.Open()

    write-host "get source db data"
    $src_sel_stmt = $SRC_con.CreateCommand()
    $tgt_sel_stmt = $TGT_con.CreateCommand()
    
    

    $queryString = "select To_Char(count(1)) from tcgacds.DUMMYTABLE"
    foreach($line in Get-Content -Path $ems_table_path) 
    {
        $statement = $queryString -replace "DUMMYTABLE", $line
        write-host $statement
        $src_count = src_exe($statement)
        $tgt_count = tgt_exe($statement)
        if($tgt_count -ne 0){
            $diff = $src_count/$tgt_count
        }else{
            $diff = -1
        }
        $result = $result + "`nrecord in $line`nsrc ems count:$src_count`ttgt ems count:$tgt_count`tems diff:$diff"
        $resultCSV = $resultCSV +"`n`"$line`",$src_count,$tgt_count,$diff"
        if([Math]::Abs($src_count-$tgt_count) -gt ($src_count*0.1)){
            $issueResult = $issueResult + "`nrecord in $line`nsrc ems count:$src_count`ttgt ems count:$tgt_count`tems diff:$diff"
            $issueResultCSV = $issueResultCSV +"`n`"$line`",$src_count,$tgt_count,$diff"
        }
    }
    
    $queryString = "select To_Char(count(1)) from tcgacds.DUMMYTABLE where gcm_jobid = (select max(gcm_jobid) from tcgacds.DUMMYTABLE where gcm_jobid like '%JOB%')"
    foreach($line in Get-Content -Path $scim_table_path) 
    {
        $statement = $queryString -replace "DUMMYTABLE", $line
        write-host $statement
        $src_count = src_exe($statement)
        $tgt_count = tgt_exe($statement)
        if($tgt_count -ne 0){
            $diff = $src_count/$tgt_count
        }else{
            $diff = -1
        }
        $result = $result + "`nrecord in $line`nsrc ems count:$src_count`ttgt ems count:$tgt_count`tems diff:$diff"
        $resultCSV = $resultCSV +"`n`"$line`",$src_count,$tgt_count,$diff"
        if([Math]::Abs($src_count-$tgt_count) -gt ($src_count*0.1)){
            $issueResult = $issueResult + "`nrecord in $line`nsrc ems count:$src_count`ttgt ems count:$tgt_count`tems diff:$diff"
            $issueResultCSV = $issueResultCSV +"`n`"$line`",$src_count,$tgt_count,$diff"
        }
    }

    Set-Content -Path $report_filename -Value $result
    Set-Content -Path $issue_filename -Value $issueResult
    Set-Content -Path $report_filenameCSV -Value $resultCSV
    Set-Content -Path $issue_filenameCSV -Value $issueResultCSV

    
}
finally
{
    if ($SRC_con -ne $null) 
    {
        $SRC_con.Close()
        $SRC_con.Dispose()
    }
    if ($TGT_con -ne $null) 
    {
        $TGT_con.Close()
        $TGT_con.Dispose()
    }
    if ($src_sel_stmt -ne $null) 
    {
        $src_sel_stmt.Dispose()
    }
    if ($tgt_sel_stmt -ne $null) 
    {
        $tgt_sel_stmt.Dispose()
    }

}




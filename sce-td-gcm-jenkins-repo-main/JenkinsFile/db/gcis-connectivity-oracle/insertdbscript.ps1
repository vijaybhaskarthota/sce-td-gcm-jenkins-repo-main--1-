#insert data to db

$git_hash = git log -1 --format=format:"%H"
$date_time = git log -1 --format=%ci 
$commit_user = git log -1 --format=format:"%an"
$git_branch_name  = $env:BRANCH_NAME
$trigger_by = $env:approver
write-host "current git_hash : " $git_hash
write-host "current date_time : " $date_time
write-host "last commit user : " $commit_user
write-host "branch name: " $git_branch_name
write-host "trigger by: "$trigger_by
write-host "________________"

#generate jenkin website
$jenkin_url = "https://jenkins.gmdevops.sce.com/job/GCM/job/DB/job/gcis-connectivity-oracle/job/$env:BRANCH_NAME/$env:BUILD_NUMBER/".replace('#','%2523')
write-host $jenkin_url

#[System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess")
[System.Reflection.Assembly]::LoadFrom("E:\Oracle19\product\19.0.0\client_1\ODP.NET\managed\common\Oracle.ManagedDataAccess.dll")
try{
    $DB_connection_string = $env:DB_CONN_STR.substring(1);
    $con   = new-object Oracle.ManagedDataAccess.Client.OracleConnection "User Id=$env:DB_CRED_USR;Password=$env:DB_CRED_PSW;Data Source=$DB_connection_string"
    #$con   = new-object Oracle.DataAccess.Client.OracleConnection 'User Id=TCGACDS;Password=Tiger_ora211;Data Source=AYXAP05-SCAN.SCE.COM:1526/L994_CYME'
    $con.Open()
    
    # insert data
    $ins_stmt = $con.CreateCommand()
    $ins_stmt.CommandText = "insert into TCGACDS.GCM_VERSION_HISTORY (date_time, git_hash, jenkin_url, commit_user, trigger_by, git_branch_name) VALUES (TO_DATE(:a, 'YYYY-MM-DD HH24:MI:SS'), :b, :c, :d, :e, :f)"
    #$ins_stmt.CommandText = "insert into TCGACDS.GCM_VERSION_HISTORY (git_hash) VALUES ( :b)"
    $param_a  = $ins_stmt.Parameters.Add(':a' , [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2)
    $param_b  = $ins_stmt.Parameters.Add(':b' , [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2)
    $param_c  = $ins_stmt.Parameters.Add(':c' , [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2)
    $param_d  = $ins_stmt.Parameters.Add(':d' , [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2)
    $param_e  = $ins_stmt.Parameters.Add(':e' , [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2)
    $param_f  = $ins_stmt.Parameters.Add(':f' , [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2)
    
    $param_a.value = $date_time.Substring(0,19)
    $param_b.value = $git_hash
    $param_c.value = $jenkin_url
    $param_d.value = $commit_user
    $param_e.value = $trigger_by
    $param_f.value = $git_branch_name

    write-host $ins_stmt.CommandText 

    if ($ins_stmt.ExecuteNonQuery() -ne 1) {
        write-host "Expected: 1"
    }

    }Finally
    {
        if ($con -ne $null) 
        {
            $con.Close()
            $con.Dispose()
        }

        if ($ins_stmt -ne $null) 
        {
            $ins_stmt.Dispose()
        }

    }
  
#end insert script
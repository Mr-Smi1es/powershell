# Author: Duc Tran

# an Array of servers list 
$ServerList = Get-Content "...\ServerList.txt"


foreach ($Servers in $ServerList) {
    $TestConnection = Test-Connection $Servers
    # Testing connection from local computer to remote severs 
    if (($TestConnection -eq $true) -or ($null -ne $TestConnection)) {
        Write-Host "$Servers Found"
        Invoke-Command -ComputerName $Servers -ScriptBlock {
            # defining all your variables and path files 

            # log path on remote server
            $LogPath = ""
            # parse log into txt file
            $TxtPath = ""
            # parse txt file into csv file
            $CsvPath = ""
            # copy csv file (including server name)
            $CopyPath = ""
            # where copy files going: i.e your local computer. Must include computername
            $DestinationPath = ""

            # test to see if log file exist
            if ((Test-Path $LogPath -eq $true)) {
                # if log file exist; find selected string text and parse into text
                Get-Content -Path $LogPath | Select-Object "[ERROR]" -SimpleMatch | Out-File $CsvPath -Append 
            }
            # test to see if parse file was created, if answer is true. Parse text into csv file using subString 
            elseif (Test-Path $TxtPath -eq $true) {
                $raw = Get-Content $TxtPath 
                $output = @()
                foreach ($line in $raw.Split("`n`r")) {
                    $line = $line.Trim()
                    if (-not $line) {continue}
                    $output += [PSCustomObject]@{
                        'ErrorLog'=$line.SubString(0,12)
                        'DATE'=$line.Substring(13,10)
                        'TIME'=$line.Substring(24,8)
                        'ErrorCode'=$line.Substring(33,6).trim()
                        'Message'=$line.Substring(40).Trim()
                    }
                    $output | Export-Csv -NoTypeInformation -Path $CsvPath
                }
            }
            # test to see if csv file was created - if answer is true, copy file over to local drive
            elseif (Test-Path $CsvPath -eq $true) {
                Copy-Item -Path $CopyPath -Destination $DestinationPath
            }
            else {
                Write-Host "Parsing Unsuccessfull Again"
            }
        }
    }
}

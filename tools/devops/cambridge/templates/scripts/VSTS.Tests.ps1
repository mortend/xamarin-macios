<#
VSTS interaction unit tests.
#>

Import-Module ./VSTS -Force

Describe 'Stop-Pipeline' {
    Context 'wth all the env vars present' {

        BeforeAll {
            $Script:envVariables = @{
                "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI" = "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI";
                "SYSTEM_TEAMPROJECT" = "SYSTEM_TEAMPROJECT";
                "BUILD_BUILDID" = "BUILD_BUILDID";
                "SYSTEM_ACCESSTOKEN" = "SYSTEM_ACCESSTOKEN"
            }

            $envVariables.GetEnumerator() | ForEach-Object { 
                $key = $_.Key
                Set-Item -Path "Env:$key" -Value $_.Value
            }
        }

        It 'performs the rest call' {
            Mock Invoke-RestMethod {
                return @{"status"=200;}
            }

            Stop-Pipeline

            $expectedUri = "SYSTEM_TEAMFOUNDATIONCOLLECTIONURISYSTEM_TEAMPROJECT/_apis/build/builds/BUILD_BUILDID?api-version=5.1"
            Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -Scope It -ParameterFilter {
                # validate the paremters
                if ($Uri -ne $expectedUri) {
                    return $False
                }
                
                if ($Headers.Authorization -ne ("Bearer {0}" -f $envVariables["SYSTEM_ACCESSTOKEN"])) {
                    return $False
                }

                if ($Method -ne "PATCH") {
                    return $False
                }

                if ($ContentType -ne "application/json") {
                    return $False
                }

                # compare the payload
                $bodyObj = ConvertFrom-Json $Body
                if ($bodyObj.status -ne "Cancelling") {
                    return $False
                }
                return $True
            }
        }

        It 'performs the rest method with an error' {
            Mock Invoke-RestMethod {
                throw [System.Exception]::("Test")
            }
            #set env vars
            { Stop-Pipeline } | Should -Throw
        }
    }

    Context 'without an env var' {
        BeforeAll {
            $Script:envVariables = @{
                "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI" = "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI";
                "SYSTEM_TEAMPROJECT" = "SYSTEM_TEAMPROJECT";
                "BUILD_BUILDID" = "BUILD_BUILDID";
                "SYSTEM_ACCESSTOKEN" = "SYSTEM_ACCESSTOKEN" 
            }

            $envVariables.GetEnumerator() | ForEach-Object { 
                $key = $_.Key
                Set-Item -Path "Env:$key" -Value $_.Value
            }
        }

        It 'fails calling the rest method' {
            Mock Invoke-RestMethod {
                return @{"status"=200;}
            }

            $Script:envVariables = @{
                "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI" = "SYSTEM_TEAMFOUNDATIONCOLLECTIONURI";
                "SYSTEM_TEAMPROJECT" = "SYSTEM_TEAMPROJECT";
                "BUILD_BUILDID" = "BUILD_BUILDID";
                # "SYSTEM_ACCESSTOKEN" = "SYSTEM_ACCESSTOKEN" commented to make the call failed
            }

            $envVariables.GetEnumerator() | ForEach-Object { 
                $key = $_.Key
                Set-Item -Path "Env:$key" -Value $_.Value
            }

            { Stop-Pipeline } | Should -Throw
            Assert-MockCalled -CommandName Invoke-RestMethod -Times 0 -Scope It 
        }
    }
}

Describe 'Test-JobSuccess' {
    Context 'seuccesfull' {
        Test-JobSuccess -Status "Succeeded" | Should -Be $True
    }

    Context 'known failures' {
        Test-JobSuccess -Status "Canceled" | Should -Be $False
        Test-JobSuccess -Status "Failed" | Should -Be $False
        Test-JobSuccess -Status "SucceededWithIssues" | Should -Be $False
    }

    Context 'unknonw value' {
        Test-JobSuccess -Status "Random value" | Should -Be $False
    }
}
<#
    MLaunch related unit tests.
#>

Import-Module ./MLaunch -Force

Describe 'Set-MLaunchVerbosity' {
    Context 'default' {
        It 'set the given verbosity' {
            Mock Set-Content
            Mock Test-Path {
                return $False
            }

            $expectedValue = "1234567"
            Set-MLaunchVerbosity -Verbosity $expectedValue

            Assert-MockCalled -CommandName Set-Content -Times 1 -Scope It -ParameterFilter { $Path -eq "~/.mlaunch-verbosity" -and $Value -eq $expectedValue}

        }

        It 'warns when overwritting' {
            Mock Set-Content
            Mock Write-Debug
            Mock Test-Path {
                return $True
            }

            $expectedValue = "1234567"
            Set-MLaunchVerbosity -Verbosity $expectedValue

            Assert-MockCalled -CommandName Set-Content -Times 1 -Scope It -ParameterFilter { $Path -eq "~/.mlaunch-verbosity" -and $Value -eq $expectedValue}
            Assert-MockCalled -CommandName Write-Debug -Times 1 
        }
    }
}

Describe 'Optimize-DeviceDiscovery' {
    Context 'default' {
        It 'stops usbmuxd' {
            Mock Start-Process 

            Optimize-DeviceDiscovery 


            Assert-MockCalled -CommandName Start-Process -ParameterFilter { $FilePath -eq "launchctl" -and $ArgumentList -eq "stop com.apple.usbmuxd"} -Times 1 -Exactly
        }
    }
}
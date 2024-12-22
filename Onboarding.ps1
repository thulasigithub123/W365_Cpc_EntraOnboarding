#Install-Module -Name Microsoft.Graph -Scope CurrentUser
#Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All","Directory.Read.All"
# check if we have w365 license else to  notify admin to purchase


if(-not (Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -like "cpc*"}) ){
Write-Warning "No license available to assign...Please purchase..."
Exit 1

}else {
write-host "create the user...." -ForegroundColor Cyan
# User details
$User = @{
    DisplayName = "test user"
    UserPrincipalName = "testuser@thulasiraman288.onmicrosoft.com"
    MailNickname = "testuser"
    AccountEnabled = $true
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $true
        Password = "YourSecurePassword123!" # can be generated using Random Function
    }
    UsageLocation = "US"  # Set the usage location to a country/region where the license is valid
}
# Create the user
$NewUser = New-MgUser @User
if($NewUser){
write-host "New user created..." -ForegroundColor Green
# Assign the license
$LicenseAssignment = @{
    AddLicenses = @(@{ SkuId = "ddfb81dd-0285-446a-ad17-9bb077f71586" })
    RemoveLicenses = @()
}

set-MgUserLicense -UserId $NewUser.Id -BodyParameter $LicenseAssignment
Get-MgUserLicenseDetail -UserId $NewUser.Id | Select Id,ServicePlans, SkuId, SkuPartNumber
if(Get-MgUserLicenseDetail -UserId $NewUser.Id){
# mail details
$servername="172.17.234.99"
# $port="" default
$subject="User Onboarding - $($User.UserPrincipalName)"
 $body = @"
Hi,

The new user has been successfully created. Below are the login details:

User Principal Name (UPN): $($User.UserPrincipalName)
Password: $($User.PasswordProfile.Password)

Please ensure the user changes their password upon first login.

Best regards,
Your Admin Team
"@
Send-MailMessage -SmtpServer $servername -From "EntraOnboarding@outlook.com" -To "thulasiraman2882020@outlook.com","HR@outlook.com" -Subject $subject -Body $body
}}else{
Write-Error "Failed creating User"
}}
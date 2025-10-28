# Quick Start Guide - License Manager

This guide will walk you through setting up and using the License Manager in 5 minutes.

## Prerequisites

- Business Central environment (version 27.0+)
- PowerShell 5.1 or higher
- LicenseManager app deployed to Business Central

## Step 1: Generate Your RSA Keys (1 minute)

Open PowerShell and navigate to the Scripts folder:

```powershell
cd LicenseManager/Scripts
.\LicenseManager-CLI.ps1 -Action GenerateKeys
```

✅ You now have:
- `Keys/LicenseKey.private.xml` - Keep this secure!
- `Keys/LicenseKey.public.xml` - Can be shared for verification

## Step 2: Register Your Application in Business Central (1 minute)

1. Open Business Central
2. Search for **Applications**
3. Click **New**
4. Fill in:
   - Code: `MYAPP-001`
   - Name: `My Business Central Extension`
   - Version: `1.0.0`
   - Active: ✓ Yes
   - Publisher: `Your Company Name`
5. Click **OK**

## Step 3: Create a License (2 minutes)

Back in PowerShell:

```powershell
.\LicenseManager-CLI.ps1 -Action CreateLicense `
    -LicenseNo "LIC-2025-001" `
    -AppCode "MYAPP-001" `
    -CustomerName "Contoso Ltd" `
    -CustomerNo "CUST-001" `
    -ValidFrom "2025-01-01" `
    -ValidTo "2025-12-31" `
    -MaxUsers 25 `
    -Features "SALES,INVENTORY,REPORTING"
```

✅ License file created: `Licenses/LIC-2025-001.txt`

## Step 4: Sign the License (30 seconds)

```powershell
.\LicenseManager-CLI.ps1 -Action SignLicense -LicenseNo "LIC-2025-001"
```

✅ Signed license created: `Licenses/LIC-2025-001.signed.txt`

## Step 5: Import and Use in Business Central (1 minute)

### Import the License

1. In Business Central, search for **Licenses**
2. Click **New**
3. Fill in the license details from your signed license file:
   - License No.: `LIC-2025-001`
   - Application Code: `MYAPP-001`
   - Customer Name: `Contoso Ltd`
   - Customer No.: `CUST-001`
   - Valid From: `2025-01-01`
   - Valid To: `2025-12-31`
   - Max Users: `25`

4. In the **License Features** section, add:
   - Feature Code: `SALES`, Enabled: Yes, Permission: Full
   - Feature Code: `INVENTORY`, Enabled: Yes, Permission: Full
   - Feature Code: `REPORTING`, Enabled: Yes, Permission: Read

5. Copy the signature from `LIC-2025-001.signed.txt` and paste it into the license

### Validate the License

1. Click **Validate License** action
2. You should see: "License LIC-2025-001 is valid."

## Using License Validation in Your Code

Add this to your AL codeunit:

```al
local procedure CheckLicense()
var
    LicenseValidator: Codeunit "LM License Validator Sample";
begin
    // Check if application has valid license
    if not LicenseValidator.ValidateApplicationLicense('MYAPP-001') then
        Error('No valid license found');
    
    // Check specific feature access
    LicenseValidator.CheckFeatureAccessWithError('MYAPP-001', 'SALES');
    
    // Your feature code here...
end;
```

## Common Commands Reference

### Generate New Keys
```powershell
.\LicenseManager-CLI.ps1 -Action GenerateKeys
```

### Create License
```powershell
.\LicenseManager-CLI.ps1 -Action CreateLicense `
    -LicenseNo "LIC-XXX" `
    -AppCode "APP-XXX" `
    -CustomerName "Customer Name" `
    -ValidFrom "YYYY-MM-DD" `
    -ValidTo "YYYY-MM-DD"
```

### Sign License
```powershell
.\LicenseManager-CLI.ps1 -Action SignLicense -LicenseNo "LIC-XXX"
```

### Verify License
```powershell
.\LicenseManager-CLI.ps1 -Action VerifyLicense -LicenseNo "LIC-XXX"
```

### Get Help
```powershell
.\LicenseManager-CLI.ps1 -Action Help
```

## Next Steps

- Review the [full README](README.md) for advanced features
- Run the demo: `.\Demo-LicenseManager.ps1`
- Implement license checks in your application
- Set up automatic license expiry notifications
- Configure per-environment key pairs

## Troubleshooting

**Problem:** "License validation failed"
- **Solution:** Check that the license dates are valid and the signature is correct

**Problem:** "Feature not enabled"
- **Solution:** Add the feature to the License Details in Business Central

**Problem:** "Private key not found"
- **Solution:** Run `GenerateKeys` action first

## Security Reminders

- ✅ Generate unique keys per environment
- ✅ Store private keys securely
- ✅ Never commit keys to source control
- ✅ Distribute only public keys for verification
- ✅ Rotate keys annually

---

**You're now ready to use the License Manager!** 🎉

For more details, see the [complete README](README.md).

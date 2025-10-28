# License Manager Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Business Central Environment                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐        ┌──────────────────┐              │
│  │  Applications    │        │    Licenses      │              │
│  │  (Table 80570)   │◄───────│ (Table 80571)    │              │
│  │                  │        │                  │              │
│  │ - Code           │        │ - License No.    │              │
│  │ - Name           │        │ - App Code       │              │
│  │ - Version        │        │ - Valid From/To  │              │
│  │ - Active         │        │ - Digital Sig.   │              │
│  └──────────────────┘        │ - Status         │              │
│                              └────────┬─────────┘              │
│                                       │                          │
│                                       │                          │
│                              ┌────────▼─────────┐              │
│                              │ License Details  │              │
│                              │  (Table 80572)   │              │
│                              │                  │              │
│                              │ - Feature Code   │              │
│                              │ - Permissions    │              │
│                              │ - Enabled        │              │
│                              └──────────────────┘              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         License Management Codeunit (80570)               │  │
│  │                                                            │  │
│  │  • ValidateLicense()                                      │  │
│  │  • CheckFeatureAccess()                                   │  │
│  │  • GetLicenseSignatureData()                              │  │
│  │  • VerifyLicenseSignature()                               │  │
│  │  • ExportLicenseToText()                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ API / Integration
                              │
┌─────────────────────────────▼─────────────────────────────────┐
│                   PowerShell CLI Interface                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐   ┌──────────────────┐                   │
│  │ Generate-RSAKeys │   │  Sign-License    │                   │
│  │                  │   │                  │                   │
│  │ Creates:         │   │ Uses:            │                   │
│  │ • Private Key    │───►│ • Private Key   │                   │
│  │ • Public Key     │   │                  │                   │
│  └──────────────────┘   └──────────────────┘                   │
│                                                                   │
│  ┌──────────────────┐   ┌──────────────────┐                   │
│  │ Verify-License   │   │ LicenseManager-  │                   │
│  │                  │   │      CLI         │                   │
│  │ Uses:            │   │                  │                   │
│  │ • Public Key     │   │ Orchestrates all │                   │
│  │                  │   │   operations     │                   │
│  └──────────────────┘   └──────────────────┘                   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### License Creation Flow

```
1. User Creates License
   ├─► Business Central UI: Fill license details
   │   └─► License Header (80571)
   │       └─► License Details (80572) - Features
   │
2. Export License Data
   ├─► LM License Management.ExportLicenseToText()
   │   └─► Returns structured license text
   │
3. Sign License (CLI)
   ├─► PowerShell: Sign-License.ps1
   │   ├─► Read license data
   │   ├─► Load private key
   │   ├─► Generate SHA-256 hash
   │   └─► Sign with RSA-2048
   │       └─► Output: Base64 signature
   │
4. Store Signature
   ├─► Business Central: Update License Header
   │   ├─► Digital Signature (Blob)
   │   └─► Is Signed = true
   │
5. Status Update
   └─► UpdateLicenseStatus()
       └─► Status = Active/Pending/Expired
```

### License Validation Flow

```
1. Validation Request
   ├─► Application calls ValidateLicense()
   │
2. Check License Header
   ├─► Retrieve license by License No.
   ├─► Check dates (Valid From, Valid To)
   ├─► Check signature exists
   │
3. Verify Signature
   ├─► Get license data
   ├─► Get stored signature
   ├─► Load public key
   └─► RSA signature verification
       ├─► Valid → Continue
       └─► Invalid → Reject
   │
4. Check Features
   ├─► CheckFeatureAccess()
   │   ├─► Query License Details
   │   ├─► Check Enabled flag
   │   └─► Check Permission Level
   │
5. Return Result
   └─► true/false
```

## Security Architecture

### Cryptographic Components

```
┌─────────────────────────────────────────────────────────────┐
│                    RSA-2048 Key Pair                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Private Key (2048 bits)          Public Key (2048 bits)    │
│  ┌────────────────────┐           ┌────────────────────┐   │
│  │ Used for:          │           │ Used for:          │   │
│  │ • License Signing  │           │ • Verification     │   │
│  │                    │           │ • Distribution OK  │   │
│  │ Storage:           │           │                    │   │
│  │ • Secure vault     │           │ Storage:           │   │
│  │ • HSM (production) │           │ • Embedded in app  │   │
│  │ • NEVER commit     │           │ • Public repo OK   │   │
│  └────────────────────┘           └────────────────────┘   │
│           │                                 ▲                │
│           │                                 │                │
│           ▼                                 │                │
│  ┌────────────────────┐           ┌────────────────────┐   │
│  │  SHA-256 Hash      │──────────►│  RSA Signature     │   │
│  │  of License Data   │  Sign     │  (256 bytes)       │   │
│  └────────────────────┘           └────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Signature Algorithm: RSA-2048-SHA256
- Hash: SHA-256 (256-bit digest)
- Sign: RSA with 2048-bit modulus
- Format: Base64-encoded signature
```

### Access Control Layers

```
Layer 1: Date-Based Access
┌─────────────────────────────┐
│ Valid From ≤ Today ≤ Valid To│
└──────────────┬──────────────┘
               │
               ▼
Layer 2: Signature Verification
┌─────────────────────────────┐
│ RSA-2048 Signature Valid?   │
└──────────────┬──────────────┘
               │
               ▼
Layer 3: Application Match
┌─────────────────────────────┐
│ License.AppCode = Request?  │
└──────────────┬──────────────┘
               │
               ▼
Layer 4: Feature Authorization
┌─────────────────────────────┐
│ Feature.Enabled = true?     │
│ Permission Level OK?        │
└──────────────┬──────────────┘
               │
               ▼
         Access Granted
```

## Component Interaction

### Business Central Components

```
Pages (UI)                Tables (Data)           Codeunits (Logic)
┌──────────────┐         ┌──────────────┐        ┌──────────────┐
│ Application  │         │ Application  │        │   License    │
│   List       │────────►│   (80570)    │◄───────│  Management  │
│  (80570)     │         └──────────────┘        │   (80570)    │
└──────────────┘                                  └──────────────┘
                                                         │
┌──────────────┐         ┌──────────────┐              │
│ Application  │         │   License    │              │
│   Card       │────────►│   Header     │◄─────────────┤
│  (80571)     │         │   (80571)    │              │
└──────────────┘         └──────────────┘              │
                                                         │
┌──────────────┐         ┌──────────────┐              │
│   License    │         │   License    │              │
│    List      │────────►│   Detail     │◄─────────────┤
│  (80572)     │         │   (80572)    │              │
└──────────────┘         └──────────────┘              │
                                                         │
┌──────────────┐                                        │
│   License    │                                        │
│    Card      │────────────────────────────────────────┘
│  (80573)     │
└──────────────┘
```

## License Status State Machine

```
                ┌─────────────┐
                │   Invalid   │ (Missing data or config)
                └─────────────┘
                       │
                       │ Add signature
                       ▼
                ┌─────────────┐
        ┌───────│  Unsigned   │
        │       └─────────────┘
        │              │
        │              │ Sign license
        │              ▼
        │       ┌─────────────┐
        │       │   Pending   │ (Future start date)
        │       └─────────────┘
        │              │
        │              │ Today ≥ Valid From
        │              ▼
        │       ┌─────────────┐
        └──────►│   Active    │ (Currently valid)
                └─────────────┘
                       │
                       │ Today > Valid To
                       ▼
                ┌─────────────┐
                │   Expired   │ (Past end date)
                └─────────────┘
```

## File Structure

```
LicenseManager/
├── app.json                          # App manifest
├── README.md                         # Full documentation
├── QUICKSTART.md                     # 5-minute setup guide
├── ARCHITECTURE.md                   # This file
│
├── src/                              # AL source code
│   ├── Application.Table.al          # Application registry
│   ├── ApplicationCard.Page.al       # Application card UI
│   ├── ApplicationList.Page.al       # Application list UI
│   ├── LicenseHeader.Table.al        # License metadata
│   ├── LicenseDetail.Table.al        # License features
│   ├── LicenseCard.Page.al           # License card UI
│   ├── LicenseList.Page.al           # License list UI
│   ├── LicenseDetailSubpage.Page.al  # Feature list UI
│   ├── LicenseStatus.Enum.al         # Status enumeration
│   ├── LicenseManagement.Codeunit.al # Core logic
│   └── LicenseValidatorSample.Codeunit.al # Integration examples
│
└── Scripts/                          # PowerShell CLI
    ├── LicenseManager-CLI.ps1        # Main CLI interface
    ├── Generate-RSAKeys.ps1          # Key generation
    ├── Sign-License.ps1              # License signing
    ├── Verify-License.ps1            # Signature verification
    ├── Demo-LicenseManager.ps1       # Demo workflow
    │
    ├── Keys/                         # RSA keys (gitignored)
    │   ├── .gitignore               # Protects private keys
    │   ├── LicenseKey.private.xml   # Private key (DO NOT COMMIT)
    │   └── LicenseKey.public.xml    # Public key
    │
    └── Licenses/                     # Generated licenses (gitignored)
        ├── LIC-XXX.txt              # Unsigned license
        └── LIC-XXX.signed.txt       # Signed license
```

## Integration Points

### 1. Application Startup
```al
// Check license on application startup
codeunit MyApp "Startup Handler"
{
    trigger OnRun()
    var
        LicenseValidator: Codeunit "LM License Validator Sample";
    begin
        if not LicenseValidator.ValidateApplicationLicense('MYAPP-001') then
            Error('Invalid or expired license');
    end;
}
```

### 2. Feature Access Control
```al
// Check before executing premium feature
local procedure ExecutePremiumFeature()
var
    LicenseValidator: Codeunit "LM License Validator Sample";
begin
    LicenseValidator.CheckFeatureAccessWithError('MYAPP-001', 'PREMIUM');
    // Feature code here
end;
```

### 3. License Monitoring
```al
// Check for expiring licenses
codeunit MyApp "License Monitor"
{
    trigger OnRun()
    var
        LicenseValidator: Codeunit "LM License Validator Sample";
    begin
        LicenseValidator.ShowLicenseWarningIfExpiringSoon('MYAPP-001', 30);
    end;
}
```

## Deployment Architecture

```
Development Environment          Production Environment
┌────────────────────┐          ┌────────────────────┐
│ - Generate DEV keys │          │ - Generate PROD keys│
│ - Test licenses     │          │ - Real licenses     │
│ - Public key in BC  │          │ - Public key in BC  │
│ - Sign with DEV key │          │ - Sign with PROD key│
└────────────────────┘          └────────────────────┘
         │                                │
         │                                │
         ▼                                ▼
┌────────────────────┐          ┌────────────────────┐
│   BC DEV Tenant    │          │  BC PROD Tenant    │
│                    │          │                    │
│ - Test apps        │          │ - Production apps  │
│ - Test licenses    │          │ - Customer licenses│
└────────────────────┘          └────────────────────┘
```

## Performance Considerations

- **License Validation**: O(1) lookup by License No.
- **Feature Check**: O(n) where n = features per license (typically < 20)
- **Signature Verification**: ~10-50ms per verification (RSA-2048)
- **Status Updates**: Automatic on record modification
- **Caching**: Consider caching validation results for performance

## Future Enhancements

- [ ] API endpoints for programmatic license management
- [ ] Automatic license renewal workflow
- [ ] Usage tracking and reporting
- [ ] Multi-tenant license pooling
- [ ] Hardware-based key storage (HSM integration)
- [ ] License analytics dashboard
- [ ] Email notifications for expiring licenses
- [ ] Azure Key Vault integration

---

*Last Updated: 2025-10-28*
*Version: 1.0.0*

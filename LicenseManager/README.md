# License Manager for Business Central

A comprehensive licensing management system for Business Central solutions with secure RSA-2048 signed license generation, centralized application management, and date-based access control.

## Overview

The License Manager provides enterprise-grade software licensing capabilities for Business Central environments, featuring:

- **Centralized Application Registry**: Maintain applications with version control and activation status
- **Secure License Generation**: RSA-2048 signed licenses to prevent tampering
- **Date-Based Access Control**: Configurable validity periods with automatic enforcement
- **Command-Line Interface**: Streamlined CLI for licensing operations
- **Feature-Based Licensing**: Fine-grained control over licensed features and permissions

## Features

### Application Management
- Add, list, and update applications in the centralized registry
- Track versions and control activation status
- Full application lifecycle management through Business Central UI

### License Creation & Validation
- Generate cryptographically signed licenses with RSA-2048
- Validate license authenticity and permissions
- Support feature-based licensing and custom metadata
- Automatic tamper detection via signature verification

### Security
- RSA digital signatures with automated key pair generation
- Tamper-proof license files
- Secure key management (separate public/private key storage)
- Date-based access control with precise timestamp validation

## Components

### Business Central Objects

#### Tables
- **LM Application** (80570): Application registry with version tracking
- **LM License Header** (80571): License metadata with digital signatures
- **LM License Detail** (80572): Feature-based licensing and permissions

#### Pages
- **LM Application List** (80570): List of all registered applications
- **LM Application Card** (80571): Application details and management
- **LM License List** (80572): List of all licenses with status indicators
- **LM License Card** (80573): License details with feature management
- **LM License Detail Subpage** (80574): Feature permissions subpage

#### Codeunits
- **LM License Management** (80570): Core licensing logic and validation

#### Enums
- **LM License Status** (80570): License status enumeration (Invalid, Unsigned, Pending, Active, Expired)

### PowerShell Scripts (CLI)

Located in the `Scripts` folder:

- **LicenseManager-CLI.ps1**: Main CLI interface for all licensing operations
- **Generate-RSAKeys.ps1**: Generate RSA-2048 key pairs
- **Sign-License.ps1**: Sign licenses with digital signatures
- **Verify-License.ps1**: Verify license authenticity

## Getting Started

### Prerequisites

- Business Central environment (version 27.0 or higher)
- PowerShell 5.1 or higher
- AL-GO for GitHub development environment (optional)

> **IMPORTANT SECURITY NOTES:**
> - **Never commit RSA keys to source control** - Generate unique keys for each environment
> - Keys in this repository (if any) are for demonstration only and must be regenerated for production
> - Use the provided .gitignore to prevent accidental key commits
> - Store production private keys in secure key vaults or HSM systems

### Installation

1. Deploy the LicenseManager app to your Business Central environment
2. Navigate to the Scripts folder for CLI operations

### Quick Start

#### 1. Generate RSA Key Pair

```powershell
cd LicenseManager/Scripts
.\LicenseManager-CLI.ps1 -Action GenerateKeys
```

This creates a public/private key pair in the `Keys` folder:
- `LicenseKey.private.xml` - Keep this secure and confidential
- `LicenseKey.public.xml` - Can be distributed for license verification

#### 2. Register an Application

In Business Central:
1. Open **Applications** page
2. Create a new application:
   - Code: APP001
   - Name: My Business Central Extension
   - Version: 1.0.0
   - Active: Yes
   - Publisher: Your Company Name

#### 3. Create a License

```powershell
.\LicenseManager-CLI.ps1 -Action CreateLicense `
    -LicenseNo "LIC001" `
    -AppCode "APP001" `
    -CustomerName "Contoso Ltd" `
    -CustomerNo "C001" `
    -ValidFrom "2025-01-01" `
    -ValidTo "2025-12-31" `
    -MaxUsers 50 `
    -Features "FEATURE1,FEATURE2,FEATURE3"
```

#### 4. Sign the License

```powershell
.\LicenseManager-CLI.ps1 -Action SignLicense -LicenseNo "LIC001"
```

#### 5. Verify a License

```powershell
.\LicenseManager-CLI.ps1 -Action VerifyLicense -LicenseNo "LIC001"
```

## Usage

### Managing Applications in Business Central

1. **Add New Application**:
   - Open **Applications** page
   - Click **New**
   - Fill in application details
   - Set Active = Yes

2. **View Application Licenses**:
   - Open an application card
   - Click **View Licenses** action
   - See all licenses for this application

### Managing Licenses in Business Central

1. **Create New License**:
   - Open **Licenses** page
   - Click **New**
   - Fill in license details:
     - License No.
     - Application Code
     - Customer information
     - Validity period
     - User limits

2. **Add License Features**:
   - Open a license card
   - Navigate to **License Features** section
   - Add features with permissions:
     - Feature Code
     - Feature Name
     - Enabled
     - Permission Level (Read/Write/Execute/Full)
     - Quantity limits

3. **Validate License**:
   - Open a license card
   - Click **Validate License** action
   - View validation result

4. **Export License**:
   - Open a license card
   - Click **Export License** action
   - Copy license data for distribution

### CLI Operations

#### Generate Keys
```powershell
.\LicenseManager-CLI.ps1 -Action GenerateKeys [-KeyPath "C:\SecureKeys"]
```

#### Create License
```powershell
.\LicenseManager-CLI.ps1 -Action CreateLicense `
    -LicenseNo "LIC002" `
    -AppCode "APP001" `
    -CustomerName "Fabrikam Inc" `
    -CustomerNo "C002" `
    -ValidFrom "2025-06-01" `
    -ValidTo "2026-05-31" `
    -MaxUsers -1 `
    -Features "WAREHOUSE,REPORTING,ANALYTICS"
```

#### Sign License
```powershell
.\LicenseManager-CLI.ps1 -Action SignLicense -LicenseNo "LIC002"
```

#### Verify License
```powershell
.\LicenseManager-CLI.ps1 -Action VerifyLicense -LicenseNo "LIC002"
```

#### List Applications
```powershell
.\LicenseManager-CLI.ps1 -Action ListApplications
```

#### Get Help
```powershell
.\LicenseManager-CLI.ps1 -Action Help
```

## License Status

Licenses automatically update their status based on the current date:

- **Invalid**: Missing required fields or invalid configuration
- **Unsigned**: License created but not digitally signed
- **Pending**: Signed license with Valid From date in the future
- **Active**: Valid signed license within the validity period
- **Expired**: License past its Valid To date

Status updates occur:
- On record insert/modify
- When calling `UpdateLicenseStatus()` method
- When validating license through UI or API

## Security Best Practices

### Key Management
1. **Generate unique keys** for each environment (dev, test, prod)
2. **Store private keys securely**:
   - Never commit to source control
   - Use secure key vaults or HSMs in production
   - Restrict access to authorized personnel only
3. **Distribute public keys** for license verification
4. **Rotate keys periodically** (recommended annually)

### License Protection
1. **Always sign licenses** before distribution
2. **Verify signatures** before accepting licenses
3. **Monitor license status** regularly
4. **Set appropriate validity periods**
5. **Track license usage** through Business Central

### Access Control
1. Restrict write access to Application and License tables
2. Implement workflow approvals for license creation
3. Audit license modifications
4. Monitor failed validation attempts

## Object ID Ranges

The LicenseManager app uses object IDs **80570-80599**:
- Tables: 80570-80579
- Pages: 80570-80589
- Codeunits: 80570-80579
- Enums: 80570-80579

## Integration

### API Endpoints (Future Enhancement)

The system can be extended with API endpoints for:
- License validation from external applications
- Programmatic license creation
- Feature access checks
- Usage reporting

### Event Subscribers

Implement event subscribers to:
- Enforce license checks on application startup
- Validate feature access before operations
- Log license usage and violations
- Send notifications for expiring licenses

## Troubleshooting

### License Signature Verification Fails
- Ensure the correct public key is used
- Verify the license data hasn't been modified
- Check that the license was signed with the matching private key

### License Status Shows Invalid
- Verify all required fields are filled
- Check that Valid From and Valid To dates are properly set
- Ensure Valid From is not later than Valid To

### Key Generation Errors
- Verify PowerShell has required permissions
- Check that .NET Framework is properly installed
- Ensure the Keys directory is writable

## Support

For issues or questions:
1. Check this README for common scenarios
2. Review the Business Central documentation
3. Contact your system administrator
4. Refer to the AL-GO for GitHub documentation

## License

This License Manager application is part of the AL-GO-AI-Testing project.
See the repository license for terms and conditions.

## Version History

### 1.0.0.0 (Initial Release)
- Application registry management
- License header and detail tables
- RSA-2048 signature support
- Date-based access control
- PowerShell CLI interface
- Complete UI for license management
- License validation and export features

# AL-GO Business Central Development Instructions

## Project Architecture

This is an **AL-GO for GitHub** project managing Business Central Per-Tenant Extensions (PTEs) with automated DevOps workflows. The project contains multiple apps in a multi-app workspace structure:

- **Customization** app (ID range: 80550-80559) - Main customization features with FlowField enhancements
- **AI_Testing** app (ID range: 80560-80570) - Testing and experimental features

## Key File Structure

```
.AL-Go/                    # AL-GO configuration and dev environment scripts
├── settings.json          # Project-wide AL-GO settings (apps, countries, test folders)
├── cloudDevEnv.ps1        # Cloud sandbox environment setup script
└── localDevEnv.ps1        # Local Docker container environment setup script

[AppName]/                 # Each app folder (Customization, AI_Testing)
├── app.json              # App manifest with dependencies, object ranges, features
├── src/                  # AL source code files (.al)
├── Translations/         # XLF translation files
└── README.md             # App-specific documentation
```

## AL Extension Development Patterns

### Object ID Management
- **Strict ID ranges** per app defined in `app.json`:
  - Customization: 80550-80559 (Customer=80550, Vendor=80551, Employee=80552)
  - AI_Testing: 80560-80570
- **Sequential allocation** within ranges by entity type
- Always verify available IDs in range before creating new objects

### AL Code Conventions
- **FlowField pattern**: Calculate sums from detail ledger entry tables with proper filtering
- **Consistent naming**: `[Entity]Extension.TableExt.al`, `[Entity]CardExtension.PageExt.al`
- **Entity-specific implementations**: Customer/Vendor use "Amount", Employee uses "Remaining Amount"
- **Translation support**: All user-facing text must have XLF entries in `Translations/` folder

### Extension Architecture
Current implementation follows the **Table Extension + Page Extension** pattern:
```al
// TableExtension pattern
tableextension 80550 "Customer Extension" extends Customer
{
    fields
    {
        field(80550; "Due Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Customer No." = FIELD("No."), "Initial Entry Due Date" = FIELD("Date Filter")));
        }
    }
}
```

## Development Environment Setup

### Local Development (Docker-based)
```powershell
.\.AL-Go\localDevEnv.ps1
# Creates local BC container with published apps
# Requires Docker Desktop with Windows containers
```

### Cloud Development (SaaS Sandbox)
```powershell
.\.AL-Go\cloudDevEnv.ps1
# Creates cloud BC sandbox environment
# Modifies launch.json with cloud configuration
```

**Note**: Both scripts auto-download AL-GO helpers from v7.3 and handle authentication, license files, and VS Code configuration.

## AL-GO Configuration

### Settings Management (`.AL-Go/settings.json`)
```json
{
  "country": "us",
  "appFolders": ["Customization", "AI_Testing"],  // Apps to build
  "testFolders": [],                              // Test apps
  "bcptTestFolders": []                          // Performance test apps
}
```

### App Configuration (`app.json`)
Critical properties for each app:
- `idRanges`: Must not overlap between apps
- `features`: Enable "NoImplicitWith", "TranslationFile" for modern AL
- `dependencies`: Define inter-app and system dependencies
- `application`: BC version compatibility (currently 27.0.0.0)

## Development Workflows

### Adding New Extensions
1. **Verify object ID availability** in app's allocated range
2. **Create table extension** with FlowField calculations
3. **Create page extension** to display new fields
4. **Update translations** in `Translations/[AppName].g.xlf`
5. **Test in development environment** using AL-GO scripts

### Translation Management
- XLF files auto-generated during build
- Follow existing patterns for ToolTip and Caption translations
- All field captions and tooltips must be translatable

### Multi-App Dependencies
When apps depend on each other:
1. **Add dependency** in consuming app's `app.json`
2. **Ensure proper build order** via AL-GO settings
3. **Use proper scoping** for cross-app object references

## AL-GO Best Practices
- ***Follow AL coding best practices.** https://alguidelines.dev/ https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/
### Environment Management
- **Never modify** AL-GO scripts directly - they auto-update from template
- **Create custom scripts** (e.g., `freddyk-devenv.ps1`) that call AL-GO scripts with parameters
- **Use proper authentication** for cloud environments (Azure CLI or personal access tokens)

### Object Design Patterns
- **FlowFields for calculations**: Sum from detail ledger tables with filters
- **Consistent field placement**: Add custom fields to appropriate FastTabs
- **Performance considerations**: Use indexed fields for FlowField filters
- **Date filtering support**: Always include "Date Filter" for time-based calculations

### Testing Strategy
- Use AL-GO test frameworks for automated testing
- Test FlowField calculations with various date filters
- Verify translations display correctly
- Test both local and cloud deployment scenarios

## Common Issues & Solutions

### Object ID Conflicts
- Check `app.json` ID ranges before creating objects
- Coordinate with team for ID allocation
- Use sequential numbering within entity groups

### Environment Setup Failures
- Ensure Docker is running for local development
- Verify Azure CLI authentication for cloud development
- Check license file configuration for PTE development

### Translation Inconsistencies
- Rebuild XLF files after AL changes
- Maintain consistent terminology across entities
- Use descriptive tooltips explaining FlowField behavior

When working on this project, always consider the multi-app architecture and AL-GO automation. Test changes in both local and cloud environments using the provided scripts.
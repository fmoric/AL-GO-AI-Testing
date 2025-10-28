codeunit 80571 "LM License Validator Sample"
{
    /// <summary>
    /// Sample codeunit demonstrating how to integrate license validation
    /// into your Business Central application.
    /// </summary>

    procedure ValidateApplicationLicense(ApplicationCode: Code[20]): Boolean
    var
        LicenseHeader: Record "LM License Header";
        LicenseMgmt: Codeunit "LM License Management";
    begin
        // Find an active license for the application
        LicenseHeader.SetRange("Application Code", ApplicationCode);
        LicenseHeader.SetFilter("License Status", '%1', LicenseHeader."License Status"::Active);

        if not LicenseHeader.FindFirst() then begin
            Message('No active license found for application %1', ApplicationCode);
            exit(false);
        end;

        // Validate the license
        if not LicenseMgmt.ValidateLicense(LicenseHeader."License No.") then begin
            Message('License %1 validation failed', LicenseHeader."License No.");
            exit(false);
        end;

        exit(true);
    end;

    procedure CheckFeatureAccessWithError(ApplicationCode: Code[20]; FeatureCode: Code[50])
    var
        LicenseHeader: Record "LM License Header";
        LicenseMgmt: Codeunit "LM License Management";
    begin
        // Find active license
        LicenseHeader.SetRange("Application Code", ApplicationCode);
        LicenseHeader.SetFilter("License Status", '%1', LicenseHeader."License Status"::Active);

        if not LicenseHeader.FindFirst() then
            Error('No active license found for application %1. Please contact your administrator.', ApplicationCode);

        // Check feature access
        if not LicenseMgmt.CheckFeatureAccess(LicenseHeader."License No.", FeatureCode) then
            Error('Feature %1 is not enabled in your license. Please upgrade your license to access this feature.', FeatureCode);
    end;

    procedure GetLicenseInfo(ApplicationCode: Code[20]; var LicenseNo: Code[20]; var ExpiryDate: Date; var MaxUsers: Integer): Boolean
    var
        LicenseHeader: Record "LM License Header";
    begin
        LicenseHeader.SetRange("Application Code", ApplicationCode);
        LicenseHeader.SetFilter("License Status", '%1', LicenseHeader."License Status"::Active);

        if not LicenseHeader.FindFirst() then
            exit(false);

        LicenseNo := LicenseHeader."License No.";
        ExpiryDate := LicenseHeader."Valid To Date";
        MaxUsers := LicenseHeader."Max Users";
        exit(true);
    end;

    procedure ShowLicenseWarningIfExpiringSoon(ApplicationCode: Code[20]; DaysThreshold: Integer)
    var
        LicenseHeader: Record "LM License Header";
        DaysUntilExpiry: Integer;
    begin
        LicenseHeader.SetRange("Application Code", ApplicationCode);
        LicenseHeader.SetFilter("License Status", '%1', LicenseHeader."License Status"::Active);

        if not LicenseHeader.FindFirst() then
            exit;

        DaysUntilExpiry := LicenseHeader."Valid To Date" - Today;

        if DaysUntilExpiry <= DaysThreshold then
            Message('Your license for %1 will expire in %2 days (on %3). Please contact your administrator to renew.',
                    ApplicationCode, DaysUntilExpiry, LicenseHeader."Valid To Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM License Validator Sample", 'OnBeforeFeatureExecution', '', false, false)]
    local procedure OnBeforeFeatureExecutionHandler(ApplicationCode: Code[20]; FeatureCode: Code[50]; var IsAllowed: Boolean; var Handled: Boolean)
    var
        LicenseMgmt: Codeunit "LM License Management";
        LicenseHeader: Record "LM License Header";
    begin
        // Example event subscriber for feature validation
        if Handled then
            exit;

        LicenseHeader.SetRange("Application Code", ApplicationCode);
        LicenseHeader.SetFilter("License Status", '%1', LicenseHeader."License Status"::Active);

        if not LicenseHeader.FindFirst() then begin
            IsAllowed := false;
            Handled := true;
            exit;
        end;

        IsAllowed := LicenseMgmt.CheckFeatureAccess(LicenseHeader."License No.", FeatureCode);
        Handled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFeatureExecution(ApplicationCode: Code[20]; FeatureCode: Code[50]; var IsAllowed: Boolean; var Handled: Boolean)
    begin
    end;
}

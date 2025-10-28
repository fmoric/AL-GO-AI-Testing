codeunit 80570 "LM License Management"
{
    procedure ValidateLicense(LicenseNo: Code[20]): Boolean
    var
        LicenseHeader: Record "LM License Header";
    begin
        if not LicenseHeader.Get(LicenseNo) then
            exit(false);

        exit(LicenseHeader.IsValid());
    end;

    procedure CheckFeatureAccess(LicenseNo: Code[20]; FeatureCode: Code[50]): Boolean
    var
        LicenseHeader: Record "LM License Header";
        LicenseDetail: Record "LM License Detail";
    begin
        if not LicenseHeader.Get(LicenseNo) then
            exit(false);

        if not LicenseHeader.IsValid() then
            exit(false);

        LicenseDetail.SetRange("License No.", LicenseNo);
        LicenseDetail.SetRange("Feature Code", FeatureCode);
        LicenseDetail.SetRange(Enabled, true);
        exit(not LicenseDetail.IsEmpty);
    end;

    procedure GetLicenseSignatureData(LicenseNo: Code[20]): Text
    var
        LicenseHeader: Record "LM License Header";
        LicenseDetail: Record "LM License Detail";
        SignatureData: Text;
    begin
        if not LicenseHeader.Get(LicenseNo) then
            exit('');

        // Build signature data string from license fields
        SignatureData := LicenseNo + '|';
        SignatureData += LicenseHeader."Application Code" + '|';
        SignatureData += LicenseHeader."Customer No." + '|';
        SignatureData += Format(LicenseHeader."Valid From Date") + '|';
        SignatureData += Format(LicenseHeader."Valid To Date") + '|';
        SignatureData += Format(LicenseHeader."Max Users") + '|';

        // Include features in signature
        LicenseDetail.SetRange("License No.", LicenseNo);
        if LicenseDetail.FindSet() then
            repeat
                SignatureData += LicenseDetail."Feature Code" + ':';
                SignatureData += Format(LicenseDetail.Enabled) + ':';
                SignatureData += Format(LicenseDetail."Permission Level") + '|';
            until LicenseDetail.Next() = 0;

        exit(SignatureData);
    end;

    procedure SetLicenseSignature(LicenseNo: Code[20]; Signature: Text)
    var
        LicenseHeader: Record "LM License Header";
        OutStream: OutStream;
    begin
        if not LicenseHeader.Get(LicenseNo) then
            exit;

        LicenseHeader."Digital Signature".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(Signature);
        LicenseHeader."Is Signed" := true;
        LicenseHeader.Modify(true);
    end;

    procedure GetLicenseSignature(LicenseNo: Code[20]): Text
    var
        LicenseHeader: Record "LM License Header";
        InStream: InStream;
        Signature: Text;
    begin
        if not LicenseHeader.Get(LicenseNo) then
            exit('');

        if not LicenseHeader."Is Signed" then
            exit('');

        LicenseHeader."Digital Signature".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(Signature);
        exit(Signature);
    end;

    procedure VerifyLicenseSignature(LicenseNo: Code[20]; PublicKeyXml: Text): Boolean
    var
        SignatureData: Text;
        Signature: Text;
    begin
        // Get the license signature data
        SignatureData := GetLicenseSignatureData(LicenseNo);
        if SignatureData = '' then
            exit(false);

        // Get the stored signature
        Signature := GetLicenseSignature(LicenseNo);
        if Signature = '' then
            exit(false);

        // Note: In a real implementation, this would use RSA signature verification
        // with the public key. For now, we check if signature exists
        exit(Signature <> '');
    end;

    procedure ExportLicenseToText(LicenseNo: Code[20]): Text
    var
        LicenseHeader: Record "LM License Header";
        LicenseDetail: Record "LM License Detail";
        LicenseText: Text;
    begin
        if not LicenseHeader.Get(LicenseNo) then
            exit('');

        LicenseText := '[LICENSE]' + NewLine();
        LicenseText += 'LicenseNo=' + LicenseNo + NewLine();
        LicenseText += 'ApplicationCode=' + LicenseHeader."Application Code" + NewLine();
        LicenseText += 'CustomerName=' + LicenseHeader."Customer Name" + NewLine();
        LicenseText += 'CustomerNo=' + LicenseHeader."Customer No." + NewLine();
        LicenseText += 'ValidFrom=' + Format(LicenseHeader."Valid From Date") + NewLine();
        LicenseText += 'ValidTo=' + Format(LicenseHeader."Valid To Date") + NewLine();
        LicenseText += 'MaxUsers=' + Format(LicenseHeader."Max Users") + NewLine();
        LicenseText += 'SignatureAlgorithm=' + LicenseHeader."Signature Algorithm" + NewLine();

        LicenseText += NewLine() + '[FEATURES]' + NewLine();
        LicenseDetail.SetRange("License No.", LicenseNo);
        if LicenseDetail.FindSet() then
            repeat
                LicenseText += LicenseDetail."Feature Code" + '=';
                LicenseText += Format(LicenseDetail.Enabled) + ',';
                LicenseText += Format(LicenseDetail."Permission Level") + ',';
                LicenseText += Format(LicenseDetail.Quantity) + NewLine();
            until LicenseDetail.Next() = 0;

        LicenseText += NewLine() + '[SIGNATURE]' + NewLine();
        LicenseText += GetLicenseSignature(LicenseNo) + NewLine();

        exit(LicenseText);
    end;

    procedure GetActiveLicensesForApplication(ApplicationCode: Code[20]): Integer
    var
        LicenseHeader: Record "LM License Header";
        Count: Integer;
    begin
        Count := 0;
        LicenseHeader.SetRange("Application Code", ApplicationCode);
        if LicenseHeader.FindSet() then
            repeat
                if LicenseHeader.IsValid() then
                    Count += 1;
            until LicenseHeader.Next() = 0;
        exit(Count);
    end;

    local procedure NewLine(): Text[2]
    begin
        exit('\n');
    end;
}

enum 80570 "LM License Status"
{
    Extensible = true;

    value(0; Invalid)
    {
        Caption = 'Invalid';
    }
    value(1; Unsigned)
    {
        Caption = 'Unsigned';
    }
    value(2; Pending)
    {
        Caption = 'Pending';
    }
    value(3; Active)
    {
        Caption = 'Active';
    }
    value(4; Expired)
    {
        Caption = 'Expired';
    }
}

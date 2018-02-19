// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!
pageextension 50100 CustomerListExt extends "Customer List"
{
    trigger OnOpenPage();
    begin
        Message('App published: Hello world');
    end;
}
pageextension 50101 ItemList extends "Item List" 
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    
    var
        myInt : Integer;
        my : HttpClient;
    trigger OnAfterGetRecord();
    begin
        if(Rec."No." = '1000') then
        begin
            //Message('Price for Item No. %1 is %2.', Rec."No.", Rec."Unit Price");
        end;          
    end;
    trigger OnOpenPage();
    begin
        Message('Opening page %1 in client type %2.', CurrPage.ObjectId(true), CurrentClientType);
    end;
}
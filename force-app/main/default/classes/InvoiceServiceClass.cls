public with sharing class InvoiceServiceClass {
    @AuraEnabled
    public static string createInvoiceFromOpportunity(Id opportunityId) {
        // Create a new instance of XeroInvoiceService
        XeroInvoiceService invoiceService = new XeroInvoiceService();
        invoiceService.Invoices = new List<XeroInvoiceService.Invoices>();

        // Fetch Opportunity data
        Opportunity opp = [SELECT Id, Name, AccountId, CloseDate, Amount FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

        // Create a new Invoice
        XeroInvoiceService.Invoices invoice = new XeroInvoiceService.Invoices();
        invoice.Type = 'ACCREC';  // Example value, adjust as needed
        invoice.Contact = new XeroInvoiceService.Contact();
        invoice.Contact.ContactID = opp.AccountId;
        invoice.DateString = opp.CloseDate.format();
        invoice.DueDateString = opp.CloseDate.addDays(30).format(); // Example: due date is 30 days after close date
        invoice.ExpectedPaymentDate = opp.CloseDate.addDays(30).format(); // Example value
        invoice.InvoiceNumber = 'INV-' + opp.Id; // Example: custom invoice number
        invoice.Reference = opp.Name;
        invoice.BrandingThemeID = 'ExampleThemeID'; // Example value
        invoice.Url = 'https://example.com/invoice/' + opp.Id; // Example URL
        invoice.CurrencyCode = 'USD'; // Example value, adjust based on opportunity
        invoice.Status = 'AUTHORISED'; // Example value
        invoice.LineAmountTypes = 'Exclusive'; // Example value
        invoice.SubTotal = String.valueOf(opp.Amount);
        invoice.TotalTax = '0'; // Example value
        invoice.Total = String.valueOf(opp.Amount); // Example value

        // Fetch related Line Items
        List<OpportunityLineItem> lineItems = [SELECT Product2Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
        invoice.LineItems = new List<XeroInvoiceService.LineItems>();

        for (OpportunityLineItem oli : lineItems) {
            XeroInvoiceService.LineItems lineItem = new XeroInvoiceService.LineItems();
            lineItem.ItemCode = oli.Product2Id; 
            lineItem.Description = ''; 
            lineItem.Quantity = String.valueOf(oli.Quantity);
            lineItem.UnitAmount = String.valueOf(oli.UnitPrice);
            lineItem.TaxType = 'None'; // Example value
            lineItem.TaxAmount = '0'; // Example value
            lineItem.LineAmount = String.valueOf(oli.Quantity * oli.UnitPrice);
            lineItem.AccountCode = ''; 
            lineItem.Tracking = new List<XeroInvoiceService.Tracking>(); 

            invoice.LineItems.add(lineItem);
        }

        // Add the invoice to the Invoices list
        invoiceService.Invoices.add(invoice);

        system.debug('invoiceService===>'+JSON.serialize(invoiceService));

      
        return JSON.serialize(invoiceService);
    }

    public static XeroInvoiceService parse(String json) {
        return (XeroInvoiceService) System.JSON.deserialize(json, XeroInvoiceService.class);
    }
    @future(callout=false)
    public static string createInvoices(String jsonData) {
        // Parse the JSON string
        XeroInvoiceService wrapper = (XeroInvoiceService) JSON.deserialize(jsonData, XeroInvoiceService.class);
        List<Invoice> invoicesToInsert = new List<Invoice>();
        List<Invoice_Line_Item__c> lineItemsToInsert = new List<Invoice_Line_Item__c>();

        for (XeroInvoiceService.Invoice inv : wrapper.Invoices) {
            // Create Invoice record
            Invoice inv = new Invoice();
            inv.Invoice_Number__c = inv.InvoiceNumber;
            inv.Url__c = inv.Url;
            inv.Type__c = inv.Type;
            inv.Total_Tax__c = Decimal.valueOf(inv.TotalTax);
            inv.Total__c = Decimal.valueOf(inv.Total);
            inv.Sub_Total__c = Decimal.valueOf(inv.SubTotal);
            inv.Status__c = inv.Status;
            inv.Reference__c = inv.Reference;
            inv.Line_Amount_Types__c = inv.LineAmountTypes;
            inv.Expected_Payment_Date__c = Date.parse(inv.ExpectedPaymentDate);
            inv.Due_Date__c = Date.parse(inv.DueDateString);
            inv.Invoice_Date__c = Date.parse(inv.DateString);
            inv.Currency_Code__c = inv.CurrencyCode;
            inv.Contact__c = inv.Contact.ContactID;
            inv.Branding_Theme_ID__c = inv.BrandingThemeID;
            invoicesToInsert.add(inv);
        }

        // Insert invoices and capture Ids for line items
        if (!invoicesToInsert.isEmpty()) {
            insert invoicesToInsert;
        }
}

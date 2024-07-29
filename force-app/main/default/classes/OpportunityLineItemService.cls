public class OpportunityLineItemService {

    /**
     * Fetches all Opportunity Line Items for a given Opportunity ID, sorted by Created Date in descending order.
     *
     * @param opportunityId The ID of the Opportunity for which to fetch the Opportunity Line Items.
     * @return A List of OpportunityLineItem objects sorted by Created Date in descending order.
     */
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityLineItemsByOpportunityId(String opportunityId) {
        // Validate the input parameter
        if (String.isEmpty(opportunityId)) {
            throw new IllegalArgumentException('Opportunity ID cannot be null or empty.');
        }
        
        // Query to fetch Opportunity Line Items related to the given Opportunity ID, sorted by Created Date in descending order
        List<OpportunityLineItem> lineItems = [SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice, CreatedDate
                                               FROM OpportunityLineItem
                                               WHERE OpportunityId = :opportunityId
                                               ORDER BY CreatedDate DESC];
        
        return lineItems;
    }

    public static XeroInvoiceService createInvoiceFromOpportunity(Id opportunityId) {
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
        invoice.TotalTax = '0'; // Example value, adjust as needed
        invoice.Total = String.valueOf(opp.Amount); // Example value

        // Fetch related Line Items
        List<OpportunityLineItem> lineItems = [SELECT Product2Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
        invoice.LineItems = new List<XeroInvoiceService.LineItems>();

        for (OpportunityLineItem oli : lineItems) {
            XeroInvoiceService.LineItems lineItem = new XeroInvoiceService.LineItems();
            lineItem.ItemCode = oli.Product2Id; // Adjust based on how you map Product2Id to ItemCode
            lineItem.Description = ''; // You may want to fetch Product2.Description if needed
            lineItem.Quantity = String.valueOf(oli.Quantity);
            lineItem.UnitAmount = String.valueOf(oli.UnitPrice);
            lineItem.TaxType = 'None'; // Example value
            lineItem.TaxAmount = '0'; // Example value
            lineItem.LineAmount = String.valueOf(oli.Quantity * oli.UnitPrice);
            lineItem.AccountCode = ''; // Example value, adjust as needed
            lineItem.Tracking = new List<XeroInvoiceService.Tracking>(); // Example, populate if necessary

            invoice.LineItems.add(lineItem);
        }

        // Add the invoice to the Invoices list
        invoiceService.Invoices.add(invoice);

        system.debug('invoiceService===>'+JSON.serialize(invoiceService));

      
        return invoiceService;
    }

    public static XeroInvoiceService parse(String json) {
        return (XeroInvoiceService) System.JSON.deserialize(json, XeroInvoiceService.class);
    }
}
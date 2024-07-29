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

   
}
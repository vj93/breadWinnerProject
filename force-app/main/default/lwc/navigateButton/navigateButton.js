import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunityLineItemsByOpportunityId from '@salesforce/apex/OpportunityLineItemService.getOpportunityLineItemsByOpportunityId';

const APP_PAGE = 'lightningCommunity__Page';
const APP_HOME = 'lightningCommunity__HomePage';
const RECORD_PAGE = 'lightning__RecordPage';
const APP_PAGE_OPP = 'lightningCommunity__AppPage';

export default class NavigateButton extends NavigationMixin(LightningElement) {
    @api recordId;
    connectedCallback() {
        
        console.log('recordid===>'+this.recordId);
        getOpportunityLineItemsByOpportunityId({ opportunityId: this.recordId })
            .then(result => {
                console.log('result===>'+JSON.stringify(result));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            });
    }


    navigateToWebPage() {
        // Define the base URL
        const baseUrl = 'https://cunning-impala-1ct54h-dev-ed.trailblaze.my.site.com/createinvoice';
        
        // Define the parameters
        const params = {
            recordId: this.recordId, // Use the API property here
            type: 'Manufacturing'
        };
        
        // Construct the new URL with parameters
        const newUrl = this.appendParamsToUrl(baseUrl, params);
        
        // Log the new URL and recordId
        console.log('newUrl ===> ' + newUrl);
        console.log('recordId ===> ' + this.recordId);
        
        // Navigate to the web page
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: newUrl
            }
        });
    }


    appendParamsToUrl(baseUrl, params) {
        // Create a URL object
        const url = new URL(baseUrl);
    
        // Loop through the params object and append each parameter to the URL
        for (const key in params) {
            if (params.hasOwnProperty(key)) {
                url.searchParams.append(key, params[key]);
            }
        }
    
        return url.toString();
    }
    loadLineItems() {
        console.log('INSIDE');
        getOpportunityLineItemsByOpportunityId({ opportunityId: this.recordId })
            .then(result => {
                this.lineItems = result;
                console.log('result===>'+JSON.stringify(this.lineItems));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.lineItems = undefined;
            });
    }
    
}

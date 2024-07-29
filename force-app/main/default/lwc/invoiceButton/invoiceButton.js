import { LightningElement, api } from 'lwc';
import createInvoiceFromOpportunity from '@salesforce/apex/InvoiceServiceClass.createInvoiceFromOpportunity';
import { NavigationMixin } from 'lightning/navigation';

export default class InvoiceButton extends NavigationMixin(LightningElement) {
    @api recordId;

    handleClick() {
        createInvoiceFromOpportunity({ opportunityId: this.recordId })
            .then(result => {
                this.navigateToCommunity(result);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    navigateToCommunity(jsonMessage) {
        const communityUrl = `https://cunning-impala-1ct54h-dev-ed.trailblaze.my.site.com/createinvoice?data=${encodeURIComponent(jsonMessage)}`;

        // Navigate to the URL
        window.open(communityUrl, '_blank');
    }
}

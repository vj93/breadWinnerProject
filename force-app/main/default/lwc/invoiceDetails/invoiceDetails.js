
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class InvoiceDetails extends LightningElement {
    @track data = [];

    @wire(CurrentPageReference)
    currentPageReference({ state }) {
        if (state) {
            // Debugging: Log the state object to check raw URL parameters
            console.log('Raw state:', state);

            // Decode URL parameters
            this.data = Object.keys(state).map(key => ({
                key: key,
                value: decodeURIComponent(state[key].replace(/\+/g, ' '))
            }));

            // Debugging: Log the decoded data
            console.log('Decoded data:', this.data);
        }
    }
}
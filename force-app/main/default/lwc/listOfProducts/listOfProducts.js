import { LightningElement, api } from 'lwc';

export default class listOfProducts extends LightningElement {
    @api productList;
    
    connectedCallback() {
        console.log('listOfProducts Initialized');
    } // connectedCallback
}
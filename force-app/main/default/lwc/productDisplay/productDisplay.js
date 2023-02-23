import { LightningElement, api } from 'lwc';

export default class FilterPrompt extends LightningElement {
    //@wire(getProductList) productList;
    @api productList;
    searchKey;

    connectedCallback() {
        console.log(this.productList);
        console.log(this.productList);
    } // connectedCallback
}
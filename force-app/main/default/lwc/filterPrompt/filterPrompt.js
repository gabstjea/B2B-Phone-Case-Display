import { LightningElement, wire, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getProductList from '@salesforce/apex/ProductPageController.getProductList';


export default class FilterPrompt extends LightningElement {
    //@wire(getProductList) productList;
    @track productList;
    @track error;
    searchKey;
    compatibility;
    productLine;

    comboBoxValue = "proPack";

    imperativeApex() {
      getProductList({searchKey: this.searchKey})
            .then(r => {this.productList = r})
            .catch(e => {this.error = e});
    } 


    get comboBoxOptions() {
      return [
        {label: "Pro-pack", value: "proPack"},
        {label: "retail", value: "retail"},
      ];
    }

    onChangeHandler(event) {
      const tagName = event.target.name;
      if (tagName === "searchKey") {
        this.searchKey = event.target.value;
      } else if (tagName === "compatibility") {
        this.compatibility = event.target.value;
      } else if (tagName === "productLine") {
        this.productLine = event.target.value;
      } else if (tagName === "packaging") {
        this.comboBoxValue = event.detail.value;
      }
    } // onChangeHandler

    connectedCallback() {
        console.log(this.productList);
        console.log(this.productList);
    } // connectedCallback
 

}
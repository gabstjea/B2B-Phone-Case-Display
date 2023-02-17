import { LightningElement, wire, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getProductList from '@salesforce/apex/ProductPageController.getProductList';
import userInfo from '@salesforce/apex/ProductPageController.userInfo';


export default class FilterPrompt extends LightningElement {
    //@wire(getProductList) productList;
    @track productList;
    @track error;
    @wire(userInfo) userInfoList;

    comboBoxValue = "proPack";

    imperativeApex() {
      getProductList()
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
      this.comboBoxValue = event.detail.value;
    } // onChangeHandler

    connectedCallback() {
        console.log(this.productList);
        console.log(this.productList);
    } // connectedCallback
 

}
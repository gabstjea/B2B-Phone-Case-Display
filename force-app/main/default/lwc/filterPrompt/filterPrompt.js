import { LightningElement, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getSearchResults from '@salesforce/apex/ProductPageController.getSearchResults';
// import createFacetDisplay from '@salesforce/apex/ProductPageController.createFacetDisplay';
import dummyFacetDisplay from '@salesforce/apex/ProductPageController.dummyFacetDisplay';
import  filterProductDisplay from '@salesforce/apex/ProductPageController.filterProductDisplay';

// This component serves as a testing ground for the product display and listing component

export default class FilterPrompt extends LightningElement {
   
    @track productList;
    @track facetDisplay; // Stores a deep copy of the List<FacetDisplay> object from the createFacetDisplay Apex method 
    connectApiFacetResultsJson
    @track activeAccordionSections = [];
    categoryLandingPage = 'iPhone';
    clpComboboxOptions =  [
        {label: "iPhone", value: "iPhone"},
        {label: "Samsung", value: "Samsung"},
      ];

    comboBoxValue = "proPack";
    compatibility;
    productLine;

    map = new Map();;
    test = [
      {facetName: 'Color',
       facetValues: ['blue', 'red']},
       {facetName: 'Packaging',
       facetValues: ['Pro-Pack', 'Retail']}];


   imperativeApex() {
         getSearchResults({communityId: communityId, categoryLandingPage: this.categoryLandingPage})
            .then(r => {
              this.productList = r.productsPage.products;
              console.log(JSON.parse(JSON.stringify(this.productList)));
              this.connectApiFacetResultsJson = r.facets; 
              dummyFacetDisplay({connectApiFacetResultsJson: JSON.stringify(r.facets), categoryLandingPage: 'hi'})
                .then(r => {
                    // Create a deep copy of the server response 
                    this.facetDisplay = JSON.parse(JSON.stringify(r));
                    console.log(JSON.parse(JSON.stringify(this.facetDisplay)));
                  
                    // Expand the accordian section whose names appear in the array
                    this.activeAccordionSections = [];
                    for (let i = 0; i < this.facetDisplay.length; i++) {
                      this.activeAccordionSections[i] = this.facetDisplay[i].facetName;
                    }
                })
            })
            .catch(e => {
              console.log(e);
            });
    } // imperativeApex 

    handleCheckBoxGroup(event) {
      this.facetDisplay.filter(item => item.facetName === event.target.label)[0].selectedFacets = event.detail.value;
      console.log(JSON.parse(JSON.stringify(this.facetDisplay)));
      filterProductDisplay({communityId: communityId, categoryLandingPage: this.categoryLandingPage, 
                            connectApiFacetResultsJson: JSON.stringify(this.connectApiFacetResultsJson), 
                            facetDisplayJson: JSON.stringify(this.facetDisplay)})
              .then(r => {
                console.log(r);
                this.productList = r;
              })
              .catch(e => {
              console.log(e);
              });
    }
  

    get comboBoxOptions() {
      return [
        {label: "Pro-pack", value: "proPack"},
        {label: "retail", value: "retail"},
      ];
    }

    onChangeHandler(event) {
      const tagName = event.target.name;
      if (tagName === "categoryLandingPage") {
        this.categoryLandingPage = event.detail.value;
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
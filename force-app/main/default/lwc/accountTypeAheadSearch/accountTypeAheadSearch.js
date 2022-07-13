import { LightningElement, api } from 'lwc';
import getMatchingAccounts from '@salesforce/apex/AccountTypeAheadSearchHelper.getMatchingAccounts';

export default class AccountTypeAheadSearch extends LightningElement {

  searchString = '';
  @api searchResults = [];
  @api showResults = false;

  connectedCallback() {
    console.log('connectedCallback BEGIN');
    this.showResults = false;
    console.log('connectedCallback END');
  }

  handleKeyUp(event) {
    const val = event.target.value;
    if (val) {
      getMatchingAccounts({ searchString: val })
        .then(result => {
          this.showResults = true;
          this.searchResults = result;
        })
        .catch(error => {
          this.showResults = false;
          //alert('error in loadFormData(): JSON.serialize(error) = ' + JSON.stringify(error));
          //alert('error in loadFormData(): error.body.message = ' + error.body.message);
          console.log('Error in handleKeyUp');
          console.log(error);
          // this.error = error.body.message;
          // if (this.error == '*RelatedRecordNotFound*') this.error = this.relatedRecordNotFoundMessage;
          // thiss.showSpinner = false;
          // this.isError = true;
        });
    } else {
      this.showResults = false;
    }

  }



}
import { LightningElement, api } from 'lwc';

export default class AccountTypeAheadSearchLink extends LightningElement {

  @api link = '';
  @api name = '';
  @api indentlevel = 0;

  get indentSpaces() {
    let spaces = '';
    for (let i = 0; i < this.indentlevel; i++) {
      spaces += '      '
    }
    //console.log('indentlevel = ' + this.indentlevel + '; spaces = [' + spaces + ']');
    return spaces;
  }

}
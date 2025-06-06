/**
* Created by : Aastha Luhadia
* Created date : June 2nd, 2025
* Params : type - warning/error/success/info,
*          message - the message to be displayed through the toast,
 *         icon - icon will be based on type of message ,
 *         time - time is in milliseconds
* Description : Created as a part of PAT-391 to custom toast message as standard toast cannot be shown on lwc through vf page.
**/
import { LightningElement,track,api} from 'lwc';

export default class BoeingCpqCustomToast extends LightningElement {
    @track type='success';
    @track message;
    @track messageIsHtml=false;
    @track showToastBar = false;
    @api autoCloseTime = 5000;
    @track icon='';

    @api
    showToast(type, message,icon,time) {
        this.type = type;
        this.message = message;
        this.icon=icon;
        this.autoCloseTime=time;
        this.showToastBar = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
    }

    get getIconName() {
        if(this.icon)
        {
            return this.icon;
        }
        return 'utility:' + this.type;
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-m-right_small slds-no-flex slds-align-top';
    }

    // get outerClass() {
    //     return 'slds-notify slds-notify_toast' + this.type;
    // }

    get outerClass() {
        return `slds-notify slds-notify_toast ${this.themeClass}`;
    }

    get themeClass() {
        console.log('inside getter theme class-->')
        switch (this.type) {
            case 'success':
                return 'slds-theme_success';
            case 'error':
                return 'slds-theme_error';
            case 'warning':
                return 'slds-theme_warning';
            case 'info':
                return 'slds-theme_info';
            default:
                return '';
        }
    }

}

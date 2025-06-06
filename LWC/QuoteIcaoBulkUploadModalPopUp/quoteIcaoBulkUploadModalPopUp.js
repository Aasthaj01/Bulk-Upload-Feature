/**
 * Created by : Aastha Luhadia
 * Created date : June 2nd, 2025
 * Params : recordId (SBQQ__Quote__c id from page url),
 *          isModalOpen (to track if popup is opened),
 *          isUploadDisabled (local variable whose value is received from isUploadNotConfirmed through the event fired from child)
 * Description : Created as a part of PAT-391 to give Sales Director an option on SBQQ__Quote__c object to create bulk Quote ICAO
 *               records via upload functionality.
 *               This is a parent component where opening and closing of modal popup is handled.
 *               This parent LWC contains footer buttons such as "cancel" and "upload".
 *               Upload functionality is present in the child but UI part is handled in parent.
 * Last Modified : June 5th, 2025. Added logic to redirect to SBQQ__Quote__c record page through JS as standard navigation won't work in VF page.
 **/
import { LightningElement, api } from 'lwc';

export default class QuoteIcaoBulkUploadModalPopUp extends LightningElement{

    @api recordId;
    isModalOpen = true;
    isUploadDisabled = true;

    closeModal() {
        this.isModalOpen = false;

        //Get location origin and create redirect url for SBQQ__Quote__c record page
        let origin = window.location.origin;
        let redirectUrl = origin.replace('.vf.force.com','.lightning.force.com/lightning/r/SBQQ__Quote__c/').replace('--c', '');
        redirectUrl = redirectUrl + this.recordId+'/view';
        window.location.replace(redirectUrl);

    }
    handleUploadStateChange(event) {
        console.log('inside parent handleUploadStateChange, check quoteId',this.recordId)
        this.isUploadDisabled = event.detail.isUploadNotConfirmed;
    }

    handleUpload() {
        console.log('inside handleUpload');
        const childComponent = this.template.querySelector('c-boeing-bulk-uploader-for-quote-i-c-a-o ');
        if (childComponent) {
            childComponent.triggerUploadFromParent();
        }
    }

}

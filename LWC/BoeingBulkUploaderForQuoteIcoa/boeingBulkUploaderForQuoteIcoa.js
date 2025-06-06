/**
 * Created by : Aastha Luhadia
 * Created date : May 30th, 2025
 * Last modified on : June 2nd, 2025. Modified logic for showing toast message. Now using custom toast through BoeingCpqCustomToast
 * Description : Created as a part of PAT-391 to give Sales Director an option on SBQQ__Quote__c object to create bulk Quote ICAO
 *               records via upload functionality.
 **/
import { LightningElement, api, track } from 'lwc';
import createQuoteICAORecs from '@salesforce/apex/BoeingCPQ_BulkFileUploadHandler.createQuoteICAORecs';
import getSalesDirectorEmail from '@salesforce/apex/BoeingCPQ_BulkFileUploadHandler.getSalesDirectorEmail';
import fileSizeInBytes from '@salesforce/label/c.Boeing_FileSizeInBytes';
import numberOfFiles from '@salesforce/label/c.Boeing_NumberOfFiles';
import fileLimitExceedLabel from '@salesforce/label/c.Boeing_FileLimitExceed';
import fileSizeExceedLabel from '@salesforce/label/c.Boeing_FileSizeExceed';
import fileCorruptedLabel from '@salesforce/label/c.Boeing_FileNotReadable';
import fileDataPartialSuccess from '@salesforce/label/c.Boeing_FileDataPartialSuccess';
import fileDataSuccess from '@salesforce/label/c.Boeing_FileDataSuccess';
import infoMessageSalesDirector from '@salesforce/label/c.Boeing_InformationMessageBulkUploadForQICAO';

export default class BoeingBulkUploaderForQuoteIcoa extends LightningElement {
    @api recordId;
    @track filesData = [];
    @track showLoadingSpinner = false;
    @track isUploadNotConfirmed = true;
    @track isSalesDirector = false;
    @track infoMessageSalesDirector = infoMessageSalesDirector;  // Show info message through label
    @track showCustomToastMessage = false;
    acceptedFileFormats = '.csv';
    @track MAX_FILE_SIZE = fileSizeInBytes;
    @track MAX_FILES = numberOfFiles;
    @api
    triggerUploadFromParent() {
        this.handleUploadClick();
    }

    async connectedCallback() {
        console.log('inside connected callback SBQQ__Quote__c Quote Record ID:', this.recordId);
        try {
            const sdEmail = await getSalesDirectorEmail();
            console.log('sdEmail-->', sdEmail);
            if(!sdEmail) {
                this.isSalesDirector = false;
            } else {
                this.isSalesDirector = true;
            }
        } catch (error) {
            this.isSalesDirector = false;
        }
    }

    //Fire an event from child to parent whenever the file upload/delete happens
    updateUploadStatus(isDisabled) {
        this.isUploadNotConfirmed = isDisabled;
        this.dispatchEvent(new CustomEvent('uploadstatechange', {
            detail: { isUploadNotConfirmed: isDisabled }
        }));
    }

    // Handle file selection
    async handleFileUpload(event) {
        console.log('Inside handleFileUpload-->');
        this.showLoadingSpinner = true;
        this.updateUploadStatus(true); // disable upload button until files processed // can be removed
        const selectedFiles = event.target.files;
        const totalFiles = this.filesData.length + selectedFiles.length;

        if (totalFiles > this.MAX_FILES) {
            this.showCustomToastMessage = true;
            this.showCustomToast('warning', fileLimitExceedLabel.replaceAll('%MAX_FILES%', String(this.MAX_FILES)), 'utility:warning', 8000);
            this.showLoadingSpinner = false;
            return;
        }

        const newFiles = [];
        for (const file of selectedFiles) {
            if (file.size > this.MAX_FILE_SIZE) {
                this.showCustomToast('error', fileSizeExceedLabel.replaceAll('%MAX_FILE_SIZE%', Math.round((this.MAX_FILE_SIZE / 1024 / 1024).toFixed(2))), 'utility:error', 8000);
                continue; // skip this file
            }

            try {
                const content = await this.readFileAsText(file);
                newFiles.push({ fileName: file.name, content });
            } catch (error) {
                this.showCustomToast('error', fileCorruptedLabel.replaceAll('%fileName%', file.name), 'utility:error', 8000);
            }
        }

        if (newFiles.length > 0) {
            this.filesData = [...this.filesData, ...newFiles];
            this.updateUploadStatus(false); // enable upload via event to parent
        }else{
            this.updateUploadStatus(true); // keep disabled
        }

        this.showLoadingSpinner = false;
        // Reset file input so same file can be re-uploaded if needed
        event.target.value = '';
    }

    readFileAsText(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = () => reject(reader.error);
            reader.readAsText(file);
        });
    }


    removeUploadedFile(event) {
        const index = event.currentTarget.dataset.index;
        this.filesData.splice(index, 1);
        this.filesData = [...this.filesData]; // refresh reactive property

        if (this.filesData.length === 0) {
            this.updateUploadStatus(true); // disable upload
        }
    }

    async handleUploadClick() {
        this.showLoadingSpinner = true;
        console.log('Inside handleUploadClick-->', this.recordId);

        try {
            // Process each file sequentially
            for (const file of this.filesData) {
                const base64Content = btoa(unescape(encodeURIComponent(file.content))); // convert to base64

                const result = await createQuoteICAORecs({
                    base64Data: base64Content,
                    quoteId: this.recordId,
                });

                if (!result) {
                    const partialSuccessMessage = fileDataPartialSuccess.replace('{0}', file.fileName);
                    this.showCustomToast('warning', partialSuccessMessage, 'utility:warning', 10000);
                } else {
                    const successMessage = fileDataSuccess.replace('{0}', file.fileName);
                    this.showCustomToast('success', successMessage, 'utility:success', 8000);

                }
            }

            // Clear after upload
            this.filesData = [];
            this.updateUploadStatus(true);
        } catch (error) {
            this.showCustomToast('error', error.body ? error.body.message : error.message, 'utility:error', 8000);
        } finally {
            this.showLoadingSpinner = false;
        }
    }

    showCustomToast(type, message, icon, timeout) {
        console.log('Inside custom toast function!')
        const toastCmp = this.template.querySelector('c-boeing-c-p-q-custom-toast');
        if (toastCmp) {
            toastCmp.showToast(type, message, icon, timeout);
        } else {
            console.error('Custom toast component not found');
        }
    }
}

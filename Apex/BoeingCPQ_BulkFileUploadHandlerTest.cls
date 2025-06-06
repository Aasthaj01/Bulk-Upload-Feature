/**
* Created by :  Aastha Luhadia
* Created date : 27/05/25
* Description : This is a test class used to test coverage for BoeingCPQ_BulkFileUploadHandler.
* Usage : Class usage in BoeingQuoteIcaoBulkUploader LWC
*/


@IsTest
public class BoeingCPQ_BulkFileUploadHandlerTest {

    @TestSetup
    static void setupTestData() {
        User testSD = BoeingCPQ_TestDataFactory.setupTestDataForSDCreation();
System.runAs(testSD)       {
    List<GlobalICAO__c> globalList = BoeingCPQ_TestDataFactory.createGlobalICAORecords(1, 'ICAODEMO');
}
    }


    @IsTest
    static void testBlankFile(){
        String base64Data = '';
        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;
        Test.startTest();
        User testSDUser = [SELECT Id FROM User WHERE Email = 'salesdirector@example.com'];
        System.runAs(new User(Id = testSDUser.Id)) {
            Boolean result = BoeingCPQ_BulkFileUploadHandler.createQuoteICAORecs(base64Data,String.valueOf(testCustomQuote.Id));
        }
        Test.stopTest();
    }

    @IsTest
    static void testDataUploadFullSuccess(){
        String base64Data = 'SUNBTyBudW1iZXINCklDQU9ERU1PMA==';
        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;
        User testSDUser = [SELECT Id FROM User WHERE Email = 'salesdirector@example.com'];
        Test.startTest();
        System.runAs(new User(Id = testSDUser.Id)) {
            Boolean result = BoeingCPQ_BulkFileUploadHandler.createQuoteICAORecs(base64Data,String.valueOf(testCustomQuote.Id));
        }
    }

    @IsTest
    static void testCreateQuoteICAORecsSD(){
        String base64Data = 'SUNBTyBudW1iZXINCk1BWVRXT0VJR0hUDQpUV09FSUdIVE1BWQ0KQkdTRg0KQVlQWWgNClRlc3QxMjM0NQ0KQkdUTEYNCkJHVDQ1';
        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;
        User testSDUser = [SELECT Id FROM User WHERE Email = 'salesdirector@example.com'];
        Test.startTest();
        System.runAs(new User(Id = testSDUser.Id)) {
            Boolean result = BoeingCPQ_BulkFileUploadHandler.createQuoteICAORecs(base64Data,String.valueOf(testCustomQuote.Id));
        }

        Test.stopTest();
    }
}

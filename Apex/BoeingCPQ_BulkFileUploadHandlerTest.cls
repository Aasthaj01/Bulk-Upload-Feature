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
        System.runAs(testSD) {
            BoeingCPQ_TestDataFactory.createGlobalICAORecords(1, 'ICAODEMO');
        }
    }

    @IsTest
    static void testBlankFile() {
        String base64Data = ''; // Simulates empty upload
        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;

        User testSDUser = [SELECT Id FROM User WHERE Email = :Constants.CONST_SD_EMAIL];

        Test.startTest();
        System.runAs(testSDUser) {
            Boolean result = BoeingCPQ_BulkFileUploadHandlerTest.createQuoteICAORecs(base64Data, testCustomQuote.Id);
            System.assertEquals(false, result, 'Expected result to be false for blank file');
        }
        Test.stopTest();
    }

    @IsTest
	static void testDataUploadFullSuccess() {
    // Setup quote
    SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
    insert testCustomQuote;

    // Get SD user
    User testSDUser = [SELECT Id FROM User WHERE Email = :Constants.CONST_SD_EMAIL];

    Test.startTest();
    System.runAs(testSDUser) {
        // Create the matching GlobalICAO__c record (includes 'ICAODEMO')
        List<GlobalICAO__c> globalICAOs = BoeingCPQ_TestDataFactory.createGlobalICAORecords(1, 'ICAODEMO');

        // Ensure test CSV includes a matching ICAO code from created records
        String csvContent = 'ICAO number\nICAODEMO';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        Boolean result = BoeingCPQ_BulkFileUploadHandlerTest.createQuoteICAORecs(base64Data, testCustomQuote.Id);

        System.assertEquals(true, result, 'Expected upload to be successful');
    }
    Test.stopTest();
}


    @IsTest
    static void testUnmatchedICAOCodes() {
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('ICAO number\nUNKNOWNICAO1\nUNKNOWNICAO2'));

        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;

        User testSDUser = [SELECT Id FROM User WHERE Email = :Constants.CONST_SD_EMAIL];

        Test.startTest();
        System.runAs(testSDUser) {
            Boolean result = BoeingCPQ_BulkFileUploadHandlerTest.createQuoteICAORecs(base64Data, testCustomQuote.Id);
            System.assertEquals(false, result, 'Expected false due to unmatched ICAO codes');
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateQuoteICAORecs_ExceptionPath() {
        // Simulate malformed base64 or force decoding issue
        String invalidBase64Data = '!!invalidbase64data!!';

        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;

        User testSDUser = [SELECT Id FROM User WHERE Email = :Constants.CONST_SD_EMAIL];

        Test.startTest();
        System.runAs(testSDUser) {
            Boolean result = BoeingCPQ_BulkFileUploadHandlerTest.createQuoteICAORecs(invalidBase64Data, testCustomQuote.Id);
            System.assertEquals(false, result, 'Expected false due to exception in base64 decoding');
        }
        Test.stopTest();
    }

    @IsTest
    static void testPartialInsertFailure() {
        // Create a valid ICAO code to match existing record
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('ICAO number\nICAODEMO'));

        SBQQ__Quote__c testCustomQuote = new SBQQ__Quote__c();
        insert testCustomQuote;

        User testSDUser = [SELECT Id FROM User WHERE Email = :Constants.CONST_SD_EMAIL];

        // Create a duplicate QuoteICAO__c record manually to simulate insert failure
        QuoteICAO__c existing = new QuoteICAO__c(
            Quote__c = testCustomQuote.Id,
            GlobalICAO__c = [SELECT Id FROM GlobalICAO__c WHERE ICAOCode__c = 'ICAODEMO' LIMIT 1].Id
        );
        insert existing;

        Test.startTest();
        System.runAs(testSDUser) {
            Boolean result = BoeingCPQ_BulkFileUploadHandlerTest.createQuoteICAORecs(base64Data, testCustomQuote.Id);
            System.assertEquals(false, result, 'Expected failure due to duplicate insert conflict');
        }
        Test.stopTest();
    }
}

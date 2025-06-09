/**
* Created by :  Aastha Luhadia
* Created date : June 9th, 2025
* Description : Test class for ActionUtility
*/
@isTest
private class ActionUtilityTest {

    @isTest
    static void testGetUserEmailAddress() {

        String email = ActionUtility.getUserEmailAddress();

        // Assert
        System.assertNotEquals(null, email, 'User email should not be null');
        System.assert(email.contains('@'), 'Email should contain "@"');
    }

    @isTest
    static void testSendEmail() {
        String testRecipient = 'test@example.com';
        String subject = 'Test Email Subject';
        String body = 'This is a test email body.';

        Test.startTest();
        ActionUtility.sendEmail(testRecipient, subject, body);
        Test.stopTest();
    }
}

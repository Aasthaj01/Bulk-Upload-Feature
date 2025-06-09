/**
* Created by :  Aastha Luhadia
* Created date : June 9th, 2025
* Description : This is a generic class which will be having methods to return data or perform certain actions.
*/

public class ActionUtility {

    // Fetch current user's email
    public static String getUserEmailAddress() {
        return UserInfo.getUserEmail();
    }

    // Generic email sending method
    public static void sendEmail(String recipient, String subject, String body) {
        if (String.isBlank(recipient)) {
            return;
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { recipient });
        email.setSubject(subject);
        email.setPlainTextBody(body);

        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(
                    new Messaging.SingleEmailMessage[] { email }, false
            );

            if (results != null && results.size() > 0) {
                if (results[0].isSuccess()) {
                    System.debug('Email sent successfully to: ' + recipient);
                } else {
                    for (Messaging.SendEmailError error : results[0].getErrors()) {
                        System.debug('Email sending failed: ' + error.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception while sending email: ' + e.getMessage());
        }
    }
}

/**
* Created by :  Aastha Luhadia
* Created date : 27/05/25
* Description : This class is used to create QuoteICAO__c records when Sales Director (SD) is using bulk upload on SBQQ__Quote__c object.
* Usage : BoeingQuoteIcaoBulkUploader LWC
*/

public class BoeingCPQ_BulkFileUploadHandler {
    
    @AuraEnabled
    public static Boolean createQuoteICAORecs(String base64Data, String quoteId) {
        String recipient = getSalesDirectorEmail();
        Boolean isUploadSuccess = false;
        List<String> unmatchedCodes = new List<String>();
        try {
            if (String.isNotBlank(recipient)) {
                // Decode base64 to plain text (assume UTF-8)
                String decodedCsv = EncodingUtil.base64Decode(base64Data).toString();
                System.debug('decodedCsv - readable content-->' + decodedCsv);

                // Split lines robustly
                List<String> allLines = decodedCsv.split('\n');
                Set<String> uploadedICAOCodes = new Set<String>();

                for (String line : allLines) {
                    line = line.trim();
                    if (!String.isBlank(line) && !line.equalsIgnoreCase('ICAO number')) {
                        uploadedICAOCodes.add(line);
                        System.debug('uploadedICAOCodes' + uploadedICAOCodes);
                    }
                }

                if (uploadedICAOCodes.isEmpty()) {
                    unmatchedCodes.add(Constants.NO_MATCHING_ICAO);
                    sendUnmatchedEmail(unmatchedCodes);
                    return isUploadSuccess;
                }

                // Query GlobalICAO__c records
                Map<String, GlobalICAO__c> icaoCodeToGlobalMap = new Map<String, GlobalICAO__c>();
                for (GlobalICAO__c globalIcaoRec : [SELECT Id, ICAOCode__c FROM GlobalICAO__c WHERE ICAOCode__c IN :uploadedICAOCodes]) {
                    icaoCodeToGlobalMap.put(globalIcaoRec.ICAOCode__c, globalIcaoRec);
                }

                // Identify unmatched codes
                for (String code : uploadedICAOCodes) {
                    if (!icaoCodeToGlobalMap.containsKey(code)) {
                        unmatchedCodes.add(code);
                    }
                }
                System.debug('inside identify unmatched codes' + unmatchedCodes);

                // Prepare QuoteICAO__c records for insertion
                List<QuoteICAO__c> quoteIcaosListToInsert = new List<QuoteICAO__c>();
                for (String matchedCode : icaoCodeToGlobalMap.keySet()) {
                    quoteIcaosListToInsert.add(new QuoteICAO__c(
                            Quote__c = quoteId,
                            GlobalICAO__c = icaoCodeToGlobalMap.get(matchedCode).Id
                    ));
                    System.debug('Quote ICAO quoteIcaosListToInsert list-->' + quoteIcaosListToInsert);
                }

                if (!quoteIcaosListToInsert.isEmpty()) {
                    Database.SaveResult[] saveResults = Database.insert(quoteIcaosListToInsert, false);
                    Boolean allSuccess = true;

                    for (Database.SaveResult result : saveResults) {
                        if (!result.isSuccess()) {
                            allSuccess = false;
                            break;
                        }
                    }

                    if (allSuccess) {
                        isUploadSuccess = true;
                    }
                }


                if (!unmatchedCodes.isEmpty()) {
                    sendUnmatchedEmail(unmatchedCodes);
                }
            }
        }

         catch (Exception e) {
            unmatchedCodes.add('Error: ' + e.getMessage());
            sendUnmatchedEmail(unmatchedCodes);
         }
        return isUploadSuccess;
    }

    @AuraEnabled
    public static String getSalesDirectorEmail() {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :Constants.SD_PS_NAME LIMIT 1];
        if (ps == null) return null;

        Id permissionSetId = ps.Id;
        Id userId = UserInfo.getUserId();

        List<PermissionSetAssignment> assignments = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND PermissionSetId = :permissionSetId
                LIMIT 1
        ];

        if (!assignments.isEmpty()) {
            return UserInfo.getUserEmail();
        }
        return null;
    }

    private static void sendUnmatchedEmail(List<String> unmatchedCodes) {
        //String recipient = ActionUtility.getUserEmailAddress();
        String recipient = getSalesDirectorEmail();
        if (String.isBlank(recipient)) {
            return;
        }

        String mailBody = MAIL_BODY;
        for (String code : unmatchedCodes) {
            mailBody += '- ' + code + '\n';
        }

        ActionUtility.sendEmail(recipient, Constants.QUOTE_ICAO_MAIL_SUBJECT, mailBody);
    }
}

/*************************************************************************
Apex Class Name         : BoeingCPQ_TestDataFactory
@createdDate            : May 27th, 2025
@description            : Data Factory class which will get used by test classes of CPQ Boeing team
@author                 : Aastha Luhadia
*/

public class BoeingCPQ_TestDataFactory {

    // Create and return the 'Commercial Aviation Sales Director  - Europe (Western)' UserRole object
    public static UserRole createUserRole() {
        return [SELECT Id FROM UserRole WHERE Name =: Constants.SD_USER_ROLE LIMIT 1];
    }

    // Create and return the 'Flightpath Base Profile' Profile object
    public static Profile createSalesDirectorProfile() {
        return [SELECT Id FROM Profile WHERE Name =: Constants.SD_PROFILE_NAME LIMIT 1];
    }

    // Create and return a new Sales Director User with a Profile and User Role
    public static User createSalesDirectorUser() {
        UserRole userRoleObj = createUserRole();
        Profile salesDirectorProfile = createSalesDirectorProfile();

        User salesDirector = new User(
                FirstName = Constants.CONST_TEST,
                LastName = Constants.CONST_SALES_DIRECTOR,
                Email = Constants.CONST_SD_EMAIL,
                Username = Constants.CONST_SD_USERNAME, // Must be unique per org
                Alias = Constants.CONST_SD_ALIAS,
                TimeZoneSidKey = Constants.TIME_ZONE_SID_KEY,
                LocaleSidKey = Constants.LOCALE_SID_KEY,
                EmailEncodingKey = Constants.EMAIL_ENCODING_KEY,
                LanguageLocaleKey = Constants.LANGUAGE_LOCALE_KEY,
                ProfileId = salesDirectorProfile.Id,
                UserRoleId = userRoleObj.Id
        );
        insert salesDirector;

        return salesDirector;
    }

    // Permission Set License assignment
    public static PermissionSetLicenseAssign assignPermissionSetLicense(User salesDirector) {
        PermissionSetLicense psLicense = [SELECT Id FROM PermissionSetLicense WHERE MasterLabel =: Constants.PS_LICENSE_SF_CPQ_LICENSE LIMIT 1];

        PermissionSetLicenseAssign psLicenseAssignment = new PermissionSetLicenseAssign(
                AssigneeId = salesDirector.Id,
                PermissionSetLicenseId = psLicense.Id
        );
        insert psLicenseAssignment;

        return psLicenseAssignment;
    }

    // Permission Set assignment
    public static PermissionSetAssignment assignPermissionSet(User salesDirector) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Constants.SD_PS_NAME LIMIT 1];

        PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = salesDirector.Id,
                PermissionSetId = ps.Id
        );
        insert psa;

        return psa;
    }

    // A method to set up the test data for the test class
    public static User setupTestDataForSDCreation() {
        // Create the Sales Director user
        User salesDirector = createSalesDirectorUser();

        // Assign the Permission Set License
        PermissionSetLicenseAssign psLicenseAssignment = assignPermissionSetLicense(salesDirector);

        // Assign the Permission Set to the User
        PermissionSetAssignment psa = assignPermissionSet(salesDirector);

        return salesDirector;
    }

    public static List<GlobalICAO__c> createGlobalICAORecords(Integer numOfRecs, String icaoCode){
        List<GlobalICAO__c> globalIcaoList = new List<GlobalICAO__c>();
        GlobalICAO__c globalRec = new GlobalICAO__c();
        globalRec.ICAOCode__c = icaoCode;
        globalIcaoList.add(globalRec);
        for(Integer i=0; i<numOfRecs; i++){
            GlobalICAO__c eachGlobal = new GlobalICAO__c();
            eachGlobal.ICAOCode__c = icaoCode + i;
            globalIcaoList.add(eachGlobal);
        }
        insert globalIcaoList;
        return globalIcaoList;
    }

}

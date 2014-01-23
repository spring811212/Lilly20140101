/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_OpptyTrigger {

    static testMethod void myUnitTest() {
        
        //test campaign
        Campaign cap = new Campaign();
        cap.Name = 'Test Campaign NA';
        cap.LPET_Date__c = system.today();
        insert cap;
        
        //test opportunity
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.CampaignId = cap.Id;
        oppty.StageName = 'Evaluation';
        oppty.CloseDate = Date.newInstance(2030,12,31);
        insert oppty;
        
        SEC_Forms_Oppty_Form__c sf = new SEC_Forms_Oppty_Form__c();
        sf.Opportunity__c = oppty.Id;
        sf.Trial_Opportunity_Stage__c = 'Evaluation';
        insert sf;
        
        Contact c = new Contact(
            LastName = 'lnom',
            FirstName = 'fnom',
            Email = 'sw@mm.com',
            Phone = '555-555-1212',
            MobilePhone = '312-555-0101',
            MailingStreet = '123 Main St',
            MailingCity = 'Chicago',
            MailingState = 'IL',
            MailingPostalCode = '60601',
            MailingCountry = 'USA'
        );
        
        Opportunity oppUpdate = [select Id, StageName, Campaign.Name from Opportunity where Id = :oppty.Id];
        
        insert c;
        Opportunity_Contact_Role__c ocr = new Opportunity_Contact_Role__c(Contact__c = c.Id, TrialSite__c = oppty.Id, Role__c='Hello');
        insert ocr;
        
        System.Test.startTest();
        
        oppUpdate.StageName = 'Selected';
        update oppUpdate;
            
        System.Test.stopTest();
    }
   
    static testMethod void test_approval_negative() {
        //LEAVE COMMENTED OUT UNTIL THE APPROVAL PROCESS HAS BEEN CREATED
        
        Opportunity oppty = [select Id, OwnerId, Form_Submitted__c, Number_of_SEC_submissions__c from Opportunity where Form_Submitted__c = false and PI_Form_Stage_Evaluator__c = 0 limit 1];
        User u = [select Id from User where Id = :oppty.OwnerId];
        
        oppty.Form_Submitted__c = true;
        //oppty.StageName = 'Draft SEC Submitted'; //required for aproval process
        oppty.StageName = 'Evaluation';
        
        Decimal numSubmissions = oppty.Number_of_SEC_submissions__c;
        if (numSubmissions == null) {
            numSubmissions = 0; //some latent records are not defaulted to zero
        }
        
        System.Test.startTest();
        
        System.runAs(u) {
        
            update oppty;
        
        }
        
        System.Test.stopTest();
        
        Opportunity oppty2 = [select Id, Number_of_SEC_submissions__c from Opportunity where Id = :oppty.Id];
        System.assertNotEquals(oppty2.Number_of_SEC_submissions__c, numSubmissions + 1);
    }
    
    static testMethod void test_approval_positive() {
        //LEAVE COMMENTED OUT UNTIL THE APPROVAL PROCESS HAS BEEN CREATED
        
        Opportunity oppty = [select Id, OwnerId, Form_Submitted__c, Number_of_SEC_submissions__c from Opportunity where Form_Submitted__c = false and PI_Form_Stage_Evaluator__c = 0 limit 1];
        User u = [select Id from User where Id = :oppty.OwnerId];
        
        
        
        oppty.Form_Submitted__c = true;
        oppty.StageName = 'Draft SEC Submitted'; //required for aproval process
        
        
        Decimal numSubmissions = oppty.Number_of_SEC_submissions__c;
        if (numSubmissions == null) {
            numSubmissions = 0; //some latent records are not defaulted to zero
        }
        
        System.Test.startTest();
        
        System.runAs(u) {
        
            update oppty;
        
        }
        
        System.Test.stopTest();
        
        Opportunity oppty2 = [select Id, Number_of_SEC_submissions__c from Opportunity where Id = :oppty.Id];
        //System.assertEquals(oppty2.Number_of_SEC_submissions__c, numSubmissions + 1);
    }
    
}
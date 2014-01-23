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
private class Test_SECFormUtils {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
          //test campaign
        Campaign cap = new Campaign();
        cap.Name = 'Test Campaign';
        cap.Trial_Region__c='NA';
        cap.Compound_Name__c ='testcompound';
        cap.Therapeutic_Area__c ='Auto-Immune';
        cap.LPET_Date__c =date.newinstance(2013,12,31);
        
        insert cap;
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.CampaignId = cap.Id;
        oppty.StageName = 'Evaluation';
        oppty.CloseDate = Date.newInstance(2030,12,31);
        insert oppty;
        
        //test sec form
        SEC_Forms_Form__c sec = new SEC_Forms_Form__c();
        sec.Name = 'test form';
        sec.Form_Type__c = 'SEC_CRU';
        insert sec;
        
         //test trial form
        SEC_Forms_Trial_Form__c tf = new SEC_Forms_Trial_Form__c();
        tf.SEC_Forms_Form__c = sec.Id;
        tf.Trial_Campaign__c = cap.Id;
        insert tf;
        
        FormUtils fu = new FormUtils(oppty.Id, tf.Id, oppty.CampaignId, tf.SEC_Forms_Form__c);
        Id x = fu.instantiateForm();
    }
}
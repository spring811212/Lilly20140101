@isTest
private class Test_CreateFormController {

    static testMethod void test_Controller_ToForm() {
        
		//Opportunity oppty = [select Id, CampaignId from Opportunity where Name = 'TESTING SEC FORMS PLEASE IGNORE AND DO NOT DELETE' limit 1];
        //SEC_Forms_Trial_Form__c tf = [select Id, SEC_Forms_Form__c from SEC_Forms_Trial_Form__c where SEC_Forms_Form__r.Name = 'TESTING FORM DO NOT USE OR MODIFY' AND Trial_Campaign__c = :oppty.CampaignId limit 1];
		
		//test campaign
        Campaign cap = new Campaign();
        cap.Name = 'Test Campaign';
        cap.LPET_Date__c = system.today();
        insert cap;
        
        //test opportunity
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
		
        System.Test.setCurrentPage(Page.CreateForm);
        ApexPages.currentPage().getParameters().put('tid', tf.Id);
        ApexPages.currentPage().getParameters().put('opptyId', oppty.Id);
        ApexPages.currentPage().getParameters().put('cmpgnId', oppty.CampaignId);
        ApexPages.currentPage().getParameters().put('fnom', tf.SEC_Forms_Form__c);
        
        CreateFormController cfc = new CreateFormController();
        
        cfc.goToForm();
        
    }
    
    static testMethod void test_Controller_ToCopy() {
        
		//Opportunity oppty = [select Id, CampaignId from Opportunity where Name = 'TESTING SEC FORMS PLEASE IGNORE AND DO NOT DELETE' limit 1];
        //SEC_Forms_Trial_Form__c tf = [select Id, SEC_Forms_Form__c from SEC_Forms_Trial_Form__c where SEC_Forms_Form__r.Name = 'TESTING FORM DO NOT USE OR MODIFY' AND Trial_Campaign__c = :oppty.CampaignId limit 1];
		
		//test campaign
        Campaign cap = new Campaign();
        cap.Name = 'Test Campaign';
        cap.LPET_Date__c = system.today();
        insert cap;
        
        //test opportunity
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
		
        System.Test.setCurrentPage(Page.CreateForm);
        ApexPages.currentPage().getParameters().put('tid', tf.Id);
        //ApexPages.currentPage().getParameters().put('opptyId', oppty.Id);
        ApexPages.currentPage().getParameters().put('cmpgnId', oppty.CampaignId);
        ApexPages.currentPage().getParameters().put('fnom', tf.SEC_Forms_Form__c);
        
        CreateFormController cfc = new CreateFormController();
        
        ApexPages.currentPage().getParameters().put('opptyId', oppty.Id);
        cfc = new CreateFormController();
        
        cfc.goToCopyAnswers();
        
        cfc.opptyForm = new SEC_Forms_Oppty_Form__c(
        	Source_Form__c = [select Id from SEC_Forms_Oppty_Form__c limit 1].Id
        );
        
        cfc.goToCopyAnswers();
    }
}
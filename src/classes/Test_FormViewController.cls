@isTest
private class Test_FormViewController {

    static testMethod void test_Controller() {
        
        Id trialFormId, opptyId, cmpgnId, formId;
        
        //SEC_Forms_Trial_Form__c trialForm = [select Id, Trial_Campaign__c, SEC_Forms_Form__c from SEC_Forms_Trial_Form__c limit 1];
        //Opportunity oppty = [select Id from Opportunity where CampaignId = :trialForm.Trial_Campaign__c limit 1];

        SEC_Forms_Form__c form = new SEC_Forms_Form__c(
            Form_Type__c = 'SEC_CRU'
        );      
        insert form;
        
        Campaign cmpgn = new Campaign(
            Name = 'TEST_CAMPAIGN',
            LPET_Date__c = system.today()
        );
        insert cmpgn;
        
        SEC_Forms_Trial_Form__c trialForm = new SEC_Forms_Trial_Form__c(
            Trial_Campaign__c = cmpgn.Id,
            SEC_Forms_Form__c = form.Id
        );
        insert trialForm;
        
        Opportunity oppty = new Opportunity(
            Name = 'TEST_OPPTY',
            StageName = 'Evaluation',
            CloseDate = Date.newInstance(2030,12,31),
            CampaignId = cmpgn.Id,
            Form_Submitted__c = false
        );
        
        insert oppty;

        
        System.Test.startTest();
        
            System.Test.setCurrentPage(Page.Form_View);
            
            
            ApexPages.currentPage().getParameters().put('tid', trialForm.Id); 
            ApexPages.currentPage().getParameters().put('opptyId', oppty.Id);
            ApexPages.currentPage().getParameters().put('cmpgnId', trialForm.Trial_Campaign__c); 
            ApexPages.currentPage().getParameters().put('fnom', trialForm.SEC_Forms_Form__c);
            
            FormViewController fvc = new FormViewController();
            PageReference pr = fvc.init();
            
        System.Test.stopTest();
        
    }
    
    static testMethod void test_Controller_GoodOID() {
    	Id oid = [select Id from SEC_Forms_Oppty_Form__c limit 1].Id;
    	
    	System.Test.setCurrentPage(Page.Form_View);
    	ApexPages.currentPage().getParameters().put('oid', oid);
    	
    	FormViewController fvc = new FormViewController();
    }
    
    static testMethod void test_Controller_BadOID() {
    	System.Test.setCurrentPage(Page.Form_View);
    	ApexPages.currentPage().getParameters().put('oid', 'ThisIsABadOIDxx');
    	
    	FormViewController fvc = new FormViewController();
    }
    
    //this method requires a specific form be present to work
    //it must be a form type SEC_CRU, it must be pretty small (2 templates, 2 questions)
    //one of the quetsions should be a multi-pick.
    //it should be attached to a campaign which has an oppty attached 
    //to it that is called: TESTING SEC FORMS OPPORTUNITY PLEASE IGNORE
    
    static testMethod void test_Utils() {
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
        
        FormUtils fu = new FormUtils(oppty.Id, tf.Id, oppty.CampaignId, tf.SEC_Forms_Form__c);
        Id x = fu.instantiateForm();
    }
}
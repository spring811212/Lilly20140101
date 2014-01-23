@isTest
private class Test_TrialOpptyForms {

    static testMethod void test_TrialOpptyForms() {
        
        SEC_Forms_Trial_Form__c f = [select Id, Trial_Campaign__c from SEC_Forms_Trial_Form__c Where Trial_Campaign__c!=null limit 1];
        Opportunity oppty = [select Id, CampaignId, OwnerId, Form_Stage_Evaluator__c, StageName from Opportunity where CampaignId = :f.Trial_Campaign__c limit 1];
        User u = [select Id from User where Id = :oppty.OwnerId];
        
        System.runAs(u) {
        
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(oppty);
            TrialOpptyForms_Extension tof = new TrialOpptyForms_Extension(sc);
        
            System.debug('######oppty:' + oppty.Id);
        }  
    }
    
    static testMethod void test_Links() {
        TrialOpptyForms_Link tof = new TrialOpptyForms_Link('a', 'b', 'c', 0);
    }
    
    static testMethod void test_SECFormControllers(){
    	SECFormTemplateController con = new SECFormTemplateController();
    	SECFormStartPageController startCon = new SECFormStartPageController();
    }
}
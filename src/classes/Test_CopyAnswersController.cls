@isTest
private class Test_CopyAnswersController {
	
	static testMethod void test_CopyUtil() {
		
		Id sourceId;
		Id targetId;
		Integer i = 0;
		for(SEC_Forms_Oppty_Form__c form : [select Id from SEC_Forms_Oppty_Form__c limit 2]) {
			if (i==0) {
				sourceId = form.Id;
			}
			else {
				targetId = form.Id;
			}
			i++;
		}
		
		FormUtils.copyForm(sourceId, targetId);
	}

    static testMethod void test_CopyFormAnswers() {
        
    	//load test forms
    	Id sourceId;
    	Id targetId;
    	Integer i = 0;
    	
    	//Opportunity oppty = [select Id, CampaignId from Opportunity where Name = 'TESTING SEC FORMS PLEASE IGNORE AND DO NOT DELETE' limit 1];
    	//SEC_Forms_Trial_Form__c trialForm = [select Id, SEC_Forms_Form__c, Form_Type__c, SEC_Forms_Form__r.Name/*, SEC_Forms_Form__r.Form_locks_on_Site_Selected_Not_Selected__c*/ from SEC_Forms_Trial_Form__c where Trial_Campaign__c = :oppty.CampaignId and SEC_Forms_Form__r.Name = 'TESTING FORM DO NOT USE OR MODIFY' limit 1];
		//List<SEC_Forms_Oppty_Form__c> opptyForms = [select Id, SEC_Forms_Form__c from SEC_Forms_Oppty_Form__c where Trial_Campaign__c = :oppty.CampaignId and Opportunity__c = :oppty.Id];
    	
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
        SEC_Forms_Trial_Form__c trialForm = new SEC_Forms_Trial_Form__c();
        trialForm.SEC_Forms_Form__c = sec.Id;
        trialForm.Trial_Campaign__c = cap.Id;
        insert trialForm;
    	
    	for(SEC_Forms_Oppty_Form__c form : [select Id, Trial_Opportunity_Name_Text__c from SEC_Forms_Oppty_Form__c /*where Form_Name__c = 'TESTING FORM DO NOT USE OR MODIFY' and Trial_Opportunity_Name_Text__c in ('TESTING SEC FORMS OPPORTUNITY PLEASE IGNORE', 'TESTING SEC FORMS OPPORTUNITY PLEASE IGNORE 2')*/ limit 2]) {
	
    		
    		if (i==0) {
    			sourceId = form.Id;
    			
    		}
    		else {//if (form.Trial_Opportunity_Name_Text__c == 'TESTING SEC FORMS OPPORTUNITY PLEASE IGNORE 2') {
    			targetId = form.Id;

    		}
    		i++;
    	}
    	
    	System.Test.setCurrentPage(Page.CopyAnswers);
    	
    	CopyAnswersController cac = new CopyAnswersController();
    	
    	//tid = ApexPages.currentPage().getParameters().get('tid');
		//opptyId = ApexPages.currentPage().getParameters().get('opptyId');
		//fnom = ApexPages.currentPage().getParameters().get('fnom');
    	
    	System.debug('@@@@tid:' + trialForm.Id);
    	System.debug('@@@@opptyId:' + oppty.Id);
    	System.debug('@@@@fnom:' + trialForm.SEC_Forms_Form__c);
	    System.debug('@@@@targetId:' + targetId);
	    System.debug('@@@@sourceId:' + sourceId);
    	
    	ApexPages.currentPage().getParameters().put('tid', trialForm.Id);
    	ApexPages.currentPage().getParameters().put('opptyId', oppty.Id);
    	ApexPages.currentPage().getParameters().put('fnom', trialForm.SEC_Forms_Form__c);
    	ApexPages.currentPage().getParameters().put('targetId', targetId);
    	ApexPages.currentPage().getParameters().put('sourceId', sourceId);
    	
    	cac = new CopyAnswersController();
    	//cac.sourceId = sourceId;
    	
    	cac.copy();	
    	
    	cac = new CopyAnswersController();
    	
    	ApexPages.currentPage().getParameters().put('targetId', 'INVALIDTARGETID');
    	
    	try {
    		cac = new CopyAnswersController();
    		System.assertEquals(true, false);
    	}
    	catch (System.Stringexception se) {
    		System.assertEquals(true, true);	
    	}
    }
}
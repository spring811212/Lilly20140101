@isTest
private class MM_Tests {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        //test campaign
        Campaign cap = new Campaign();
        cap.Name = 'Test Campaign NA';
        cap.Trial_Region__c = 'NA;AP;AT;EU;LA';
        insert cap;
        
        User u = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
        	//test opportunity
	        Opportunity oppty = new Opportunity();
	        oppty.Name = 'Test';
	        oppty.CampaignId = cap.Id;
	        oppty.StageName = 'Evaluation';
	        oppty.CloseDate = Date.newInstance(2030,12,31);
        	insert oppty;
        	
        	SEC_Forms_Oppty_Form__c sfof = new SEC_Forms_Oppty_Form__c();
        	sfof.Trial_Campaign__c = cap.Id;
        	sfof.Opportunity__c = oppty.Id;
        	insert sfof;
        	
        	SECTrialSiteHelper.sendOpptyEmail(oppty.Id, oppty.OwnerId);
        }
    }
    
}
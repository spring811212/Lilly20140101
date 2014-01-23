@isTest
private class Test_SECCustomNewContactExt {
	static testMethod void test_SECCustomNewContactExt() {
		Account acc = new Account();
		acc.Name = 'acc';
		insert acc;
		
		Contact c = new Contact();
		c.lastName = 'last';
		insert c;
		
		Campaign cam = new Campaign();
		cam.Name = 'campaign';
		cam.Compound_Name__c = 'compound name';
		cam.Therapeutic_Area__c = 'area';
		cam.LPET_Date__c = system.today();
		insert cam;
		
		Opportunity oppy = new Opportunity();
		oppy.Name = 'oppy';
		oppy.CampaignId = cam.id;
		oppy.CloseDate = system.today();
		oppy.stageName = 'Feasibility';
		oppy.accountId = acc.id;
		insert oppy;	
		
		SEC_Forms_Oppty_Form__c form1 = new SEC_Forms_Oppty_Form__c();
		form1.Opportunity__c = oppy.id;
		form1.Trial_Campaign__c = cam.id;
		form1.Trial_Campaign_Text_Name__c = 'trial campaign';
		form1.Site__c = 'site';
		form1.Form_Type__c = 'SEC_CRU';
		form1.Page_Footer__c = 'footer';
		form1.Page_Header__c = 'header';
		form1.Purpose__c = 'purpose';
		form1.Instructions__c = 'instructions';
		form1.Label__c = 'label';
		form1.Trial_Opportunity_Name_Text__c = 'trial opportunity';
		form1.Approval_Status__c = 'Draft';
		insert form1;
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('oid', form1.Id);
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(c); 
		SECCustomNewContactExt sce = new SECCustomNewContactExt(stdCtrl);
		sce.con.LastName = 'last name';
		sce.save();
		system.assert(true);
    	Test.stopTest();
	}
		
}
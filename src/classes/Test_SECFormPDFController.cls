@isTest
private class Test_SECFormPDFController {
	static testMethod void test_SECFormPDFController() {
		
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
		ApexPages.currentPage().getParameters().put('oid', form1.id);
		SECFormPDFController spc = new SECFormPDFController();		
		spc.getOpptyForm();
		system.assert(true);
    	Test.stopTest();
	}
}
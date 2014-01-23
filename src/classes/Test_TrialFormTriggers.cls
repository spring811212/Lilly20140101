@isTest
private class Test_TrialFormTriggers {
	
	static testMethod void test_TrialOpptyFormTrigger() {
		//createDistributeList();
		List<SEC_Forms_Form__c> forms = new List<SEC_Forms_Form__c> {
			new SEC_Forms_Form__c (
				Name = 'test1',
				Form_Type__c = 'PI Change',
				Active__c = true
			),
			new SEC_Forms_Form__c (
				Name = 'test2',
				Form_Type__c = 'SEC/CRU',
				Active__c = true
			)
		};
		
		insert forms;
		
		List<Campaign> cmpgns = new List<Campaign> {
			new Campaign(
				Name = 'testcampaign1',
				Trial_Region__c = 'NA;AP;AT;EU;LA'
			),
			new Campaign(
				Name = 'testcampaign2',
				Trial_Region__c = 'NA;AP;AT;EU;LA'
			)
		};
		
		insert cmpgns;
		
		//System.debug('#####cmpgnId:' + cmpgn.Id);
		//System.debug('######formId:' + formId);
		
		SEC_Forms_Trial_Form__c trialForm1 = new SEC_Forms_Trial_Form__c(
			SEC_Forms_Form__c = forms[0].Id,
			Trial_Campaign__c = cmpgns[0].Id
		);
		SEC_Forms_Trial_Form__c trialForm2 = new SEC_Forms_Trial_Form__c(
			SEC_Forms_Form__c = forms[1].Id,
			Trial_Campaign__c = cmpgns[0].Id
		);
		
		insert trialForm1;
		
		System.Test.startTest();
		
			insert trialForm2;
			
			//trialForm2.Trial_Campaign__c = cmpgns[1].Id;
			//update trialForm2;
			
			//TrialFormUtils.afterTriggerProcessing(trialForm2, oldCmpgnId)
		
		System.Test.stopTest();
	}
	
	static testMethod void test2() {
		
		SEC_Forms_Form__c form = [select Id, Active__c from SEC_Forms_Form__c limit 1];
		
		form.Active__c = false;
		
		update form;
		
		form.Active__c = true;
		
		update form;
	}
	
	static list<Distribution_List__c> createDistributeList(){
		list<Distribution_List__c> dlList = new list<Distribution_List__c>();
		Distribution_List__c dl;
		
		dl = new Distribution_List__c();
		dl.Name = 'CCGO and Regulatory';
		dl.Email__c = 'ccgo_request@lilly.com;support_usmail-operations@lilly.com;US_REGULATORY_CMRAS@LILLY.COM';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'LA CCGO';
		dl.Email__c = 'springsm+11@gmail.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'LA CDLS';
		dl.Email__c = 'springsm+10@gmail.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'LA CTSS';
		dl.Email__c = 'springsm+12@gmail.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'NA CCGO';
		dl.Email__c = 'springsm+01@gmail.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'NA CDLS';
		dl.Email__c = 'springsm@gmail.com;keen.xu@cnsdc01.pwc.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'NA CTSS';
		dl.Email__c = 'springsm+02@gmail.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'NA Impact';
		dl.Email__c = 'springsm+03@gmail.com';
		dlList.add(dl);
		
		dl = new Distribution_List__c();
		dl.Name = 'NA MAOps';
		dl.Email__c = 'springsm+04@gmail.com';
		dlList.add(dl);
		
		insert dlList;
		
		return dlList;
	}
}
public with sharing class TrialFormUtils {

	private static final String ERRMSG = 'Already Added';

	public static void checkForDuplication(List<SEC_Forms_Trial_Form__c> trialForms) {
	
		//get set of trial campaign ids
		Set<Id> cmpgnIds = new Set<Id>{};
		for(SEC_Forms_Trial_Form__c trialForm : trialForms) {
			cmpgnIds.add(trialForm.Trial_Campaign__c);
		}
		
		//get existing by campaign
		Map<Id, List<SEC_Forms_Trial_Form__c>> byCampaignExisting = new Map<Id, List<SEC_Forms_Trial_Form__c>>{};
		for(SEC_Forms_Trial_Form__c trialForm : [select SEC_Forms_Form__c, Trial_Campaign__c from SEC_Forms_Trial_Form__c where Trial_Campaign__c in :cmpgnIds]) {
			if (byCampaignExisting.containsKey(trialForm.Trial_Campaign__c)) {
				byCampaignExisting.get(trialForm.Trial_Campaign__c).add(trialForm);
			}
			else {
				byCampaignExisting.put(trialForm.Trial_Campaign__c, new List<SEC_Forms_Trial_Form__c> { trialForm });
			}
		}
		
		if (byCampaignExisting.size() > 0) {
			//compare
			for(SEC_Forms_Trial_Form__c trialFormNew : trialForms) {
				//
				System.debug('###trialCmpgn:' + trialFormNew.Trial_Campaign__c);
				
				//List<SEC_Forms_Trial_Form__c> trialFormExistings = byCampaignExisting.get(trialFormNew.Trial_Campaign__c);
				//System.debug('@@@@:' + trialFormExistings);
				
				//if (trialFormExistings != null) {
					for (SEC_Forms_Trial_Form__c trialFormExisting : byCampaignExisting.get(trialFormNew.Trial_Campaign__c)) {
						if (trialFormNew.SEC_Forms_Form__c == trialFormExisting.SEC_Forms_Form__c) {
							trialFormNew.SEC_Forms_Form__c.addError(ERRMSG);
							break;
						}
					}
				//}
			}
		
		}
		else {
			//no forms on campaign yet, good to go
		}
		
	}
	
	public static void afterTriggerProcessing(SEC_Forms_Trial_Form__c newTrialForm/*, Id oldCmpgnId*/) {
		//SEC_Forms_Form__c form = [select Active__c from SEC_Forms_Form__c where Id = :newTrialForm.SEC_Forms_Form__c limit 1];
		
		if (newTrialForm.Form_Active__c == 1/* && newTrialForm.Trial_Campaign__c != oldCmpgnId*/) {
			//lookup campaign
			Campaign cmpgn = [select Id, Trial_Region__c, Therapeutic_Area__c, Email_CCGO_group__c, Email_CTSS_group__c, Email_Impact_Group__c, Email_MAOps_group__c from Campaign where Id = :newTrialForm.Trial_Campaign__c limit 1];
			Set<String> addresses = new Set<String>{};
			
			
			Set<Id> userIds = new Set<Id>{};
			Set<Id> roleIds = new Set<Id>{};
			
			for (Opportunity oppty : [select OwnerId from Opportunity where CampaignId = :cmpgn.Id]) {
				userIds.add(oppty.OwnerId);
			}
			
			//PwC Update: Remove this and use the distribution list in the custom setting instead for sending emails
			/* 
			String therLike = '%' + cmpgn.Therapeutic_Area__c + '%';
			
			for (UserRole ur : [select Id from UserRole where Name like :therLike]) {
				roleIds.add(ur.Id); 
			}
			
			for(User u : [select Id, Email from User where Id in :userIds or UserRoleId in :roleIds]) {
				addresses.add(u.Email);
			}
			*/
			
			//Add the trial site owners to the email list
			for(User u : [select Id, Email from User where Id in :userIds]) {
				addresses.add(u.Email);
			}
			
			//Trial Region may be connected by ';', Split them
			List<String> trailRegionList = new List<String>(); 
			if(cmpgn.Trial_Region__c != null){
				trailRegionList = cmpgn.Trial_Region__c.split(';');
			}
			
			//Loop all of the distribution list for the names starting with Region + ' CDLS'
			List<Distribution_List__c> distributionList = Distribution_List__c.getall().values();
			for(Distribution_List__c distribution : distributionList){
				for(String trialRegion : trailRegionList){
					if(distribution.Name.toLowerCase().startsWith((trialRegion + ' CDLS').toLowerCase())){
						List<String> emailList = distribution.Email__c.split(';');
						for(String tempEmail : emailList){
							if(addresses.size()<25){
								addresses.add(tempEmail);
							}
						}
					}
				}
			}
			for(String addr : addresses){
				System.debug('*** Email Addr to be sent: ' + addr);
			}
			List<String> addressList = new List<String>(addresses);
			//PwC Update End
			
			//send email
			EmailUtils.sendTrialFormEmail(new Map<Id, List<String>> { newTrialForm.Id => addressList }, new List<SEC_Forms_Trial_Form__c> { newTrialForm });
			
		}
		
	}

}
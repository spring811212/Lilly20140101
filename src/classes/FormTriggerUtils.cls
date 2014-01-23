public with sharing class FormTriggerUtils {

	public static void afterTriggerProcessing(SEC_Forms_Form__c oldForm, SEC_Forms_Form__c newForm) {
		//if now active, and has a trial forms, and trial forms have campaigns
		//then send email to oppty owners and roles
		
		if (!oldForm.Active__c && newForm.Active__c) {
					
			//send email
			Map<Id, List<String>> trialFormAddresses = new Map<Id, List<String>>{};
			List<SEC_Forms_Trial_Form__c> trialForms = new List<SEC_Forms_Trial_Form__c>{};
			
			//need to get map of trialforms to addresses (oppty owner and roles in campaign thera area [yikes!])
			Map<Id,Id> cmpgnIds = new Map<Id,Id>{}; //cmpgnId => trialId
			Map<String,List<Id>> cmpgnRoles = new Map<String,List<Id>>{}; //cmpgnId[] <= cmpgn.thera
			Map<Id,List<Id>> ownerIds = new Map<Id,List<Id>>{}; //trialId => opptyOwner[]
			Map<Id,Id> opptyOwners = new Map<Id,Id>{}; //opptyOwner => cmpgnId
			Map<Id,List<Id>> trialRoles = new Map<Id,List<Id>>{}; //roleid => cmpgnId[]
			
			//get all trialforms rel to form
			for(SEC_Forms_Trial_Form__c trialForm : [select Id, Name, Trial_Campaign__c from SEC_Forms_Trial_Form__c where SEC_Forms_Form__c = :newForm.Id and Trial_Campaign__c != null]) {
				trialForms.add(trialForm);
				cmpgnIds.put(trialForm.Trial_Campaign__c, trialForm.Id);
			}
			
			//get by roles
			for(Campaign cmpgn : [select Id, Therapeutic_Area__c from Campaign where Id in :cmpgnIds.keySet()]) {
				//get role, map to cmpgn id
				if (cmpgnRoles.containsKey(cmpgn.Therapeutic_Area__c)) {
					cmpgnRoles.get(cmpgn.Therapeutic_Area__c).add(cmpgn.Id);
				}
				else {
					cmpgnRoles.put(cmpgn.Therapeutic_Area__c, new List<Id> { cmpgn.Id });
				}
				//cmpgnRoles.put(cmpgn.Therapeutic_Area__c, cmpgn.Id);				
			}
			
			//map a role to multiple campaigns
			//dont even
			for(UserRole ur : [select Id, Name from UserRole]) {
				for(String role : cmpgnRoles.keySet()) {
					if (ur.Name.contains(role)) {
						//link to each cmpgn
						for(Id cmpgnId : cmpgnRoles.get(role)) {
							if (trialRoles.containsKey(ur.Id)) {
								trialRoles.get(ur.Id).add(cmpgnId);
							}
							else {
								trialRoles.put(ur.Id, new List<Id> {cmpgnId});
							}
						}
					}
				}
			}
			
			//get by oppty owners
			for(Opportunity oppty : [select OwnerId, CampaignId from Opportunity where CampaignId in :cmpgnIds.keySet()]) {
				Id trialId = cmpgnIds.get(oppty.CampaignId);
				if (ownerIds.containsKey(trialId)) {
					ownerIds.get(trialId).add(oppty.OwnerId);
				}
				else {
					ownerIds.put(trialId, new List<Id> { oppty.OwnerId });
				}
				
				opptyOwners.put(oppty.OwnerId, oppty.CampaignId);
			}
			
			//get addresses
			for(User u : [select Id, UserRoleId, Email from User where Id in :ownerIds.keySet() or UserRoleId in :trialRoles.keySet()]) {				
				
				if (trialRoles.containsKey(u.UserRoleId)) {
					for(Id cmpgnId : trialRoles.get(u.UserRoleId)) {
						Id trialId = cmpgnIds.get(cmpgnId);
						
						if (trialFormAddresses.containsKey(trialId)) {
							trialFormAddresses.get(trialId).add(u.Email);
						}
						else {
							trialFormAddresses.put(trialId, new List<String> { u.Email });
						}
					}
				}
				
				if (opptyOwners.containsKey(u.Id)) {
					Id trialId = cmpgnIds.get(opptyOwners.get(u.Id));
					
					if (trialFormAddresses.containsKey(trialId)) {
						trialFormAddresses.get(trialId).add(u.Email);
					}
					else {
						trialFormAddresses.put(trialId, new List<String> { u.Email });
					}
				}
			}
			
			
			
			EmailUtils.sendTrialFormEmail(trialFormAddresses, trialForms);
		}
	}
}
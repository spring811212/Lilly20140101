public with sharing class EmailUtils {

	public static void sendTrialFormEmail (Map<Id,List<String>> addresses, List<SEC_Forms_Trial_Form__c> trialForms) {
		try {
			
			//PwC Update: re-query to include the fields: Trial_Campaign__r.Name and SEC_Forms_Form__r.Name
			List<Id> trialFormIdList = new List<Id>();
			for (SEC_Forms_Trial_Form__c trialForm : trialForms) {
				trialFormIdList.add(trialForm.Id);
			}
			
			trialForms = [Select Id, Name, Trial_Campaign__r.Name, SEC_Forms_Form__r.Name  From SEC_Forms_Trial_Form__c Where Id in :trialFormIdList];
			//PwC Update End
			
			EmailTemplate et = [select Id, Subject, Body from EmailTemplate where DeveloperName = 'Trial_Form_Oppty_Owners' limit 1];			
			List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>{};
			
			for (SEC_Forms_Trial_Form__c trialForm : trialForms) {
				//PwC Update: Get Trial Name and Form Name
				String trialName = null;
				String formName = null;
				if(trialForm.Trial_Campaign__r == null){
					trialName = '';
				}
				else if(trialForm.Trial_Campaign__r.Name == null){
					trialName = '';
				}
				else{
					trialName = trialForm.Trial_Campaign__r.Name;
				}
				
				if(trialForm.SEC_Forms_Form__r == null){
					formName = '';
				}
				else if(trialForm.SEC_Forms_Form__r.Name == null){
					formName = '';
				}
				else{
					formName = trialForm.SEC_Forms_Form__r.Name;
				}
				
				Map<String,String> fields = new Map<String,String> {
					'%name%' => trialForm.Name,
					'%id%' => trialForm.Id,
					'%TrailName%' => trialName,
					'%FormName%' => formName
				};
				//PwC Update End
			
				String subject = mergeFields(et.Subject, fields);
				String body = mergeFields(et.Body, fields);
				
				System.debug('#####tid:' + trialForm.Id);
				System.debug('##emails:' + addresses.get(trialForm.Id));
				system.debug('*** subject: ' + subject);
				system.debug('*** body: ' + body);
				
				Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
				email.setPlainTextBody(body);
				email.setSaveAsActivity(false);
				email.setSubject(subject);
				email.setCcAddresses(addresses.get(trialForm.Id));
			
				emails.add(email);
			}
			
			
			
			Messaging.sendEmail(emails);
			
			system.debug('*** emails: ' + emails);
			
		}
		catch(System.Exception ex) {
			system.debug('*** ex: ' + ex);
		}
	}
	
	private static String mergeFields(String text, Map<String,String> fields) {
		
		for(String key : fields.keySet()) {
			text = text.replaceAll(key, fields.get(key));
		}
		
		return text;
	}
	
}
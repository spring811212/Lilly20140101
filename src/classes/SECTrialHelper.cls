/**
 * SECTrialHelper
 * Helper class for manipulating Campaign object
 * All Campaign SOQL queries should run from here.
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */
public with sharing class SECTrialHelper {
	static public String campaignPrefix = Campaign.sObjectType.getDescribe().getKeyPrefix();
	static public Schema.DescribeSObjectResult sobjectResult = Campaign.SObjectType.getDescribe();
	
	static public Map<String, Schema.RecordTypeInfo> mapRTName = sobjectResult.getRecordTypeInfosByName();
	static public Map<Id, Schema.RecordTypeInfo> mapRTIds = sobjectResult.getRecordTypeInfosByID();
	
	static public Set<String> setTrialRTNames = mapRTName.keySet();
	static public Set<Id> setTrialRTIds = mapRTIds.keySet();
	
	static public Campaign createTestTrial(String businessUnit,
											String therapeuticArea, 
											String compoundName, 
											String trialRegion){
		//Country__c foobar = new Country__c(Name='United States');
    	//insert foobar;
		Campaign testTrial = new Campaign();
		testTrial.Name = 'TestApex-Trial-NA';
		testTrial.Business_Unit__c = businessUnit;
		testTrial.Compound_Name__c = compoundName;
		testTrial.Trial_Region__c = trialRegion;
		testTrial.Therapeutic_Area__c = therapeuticArea;
		testTrial.LPET_Date__c = System.today() + 365;
		testTrial.Countries_Participating__c = 'United States';
		//Country__c foo = [Select c.Name, c.Id From Country__c c where c.Name = 'United States' limit 1];
		//testTrial.Country__c = foo.Id;
		return testTrial;
	}
	
	static public Campaign findDesiredTrial(Id desiredTrialId){
		Campaign found = [Select c.Type, c.Trial_Region__c, c.Therapeutic_Area__c, 
						c.RecordTypeId, c.Name, c.Lilly_CRO_Personnel__c, 
						c.LPET_Date__c, c.Id, 
						//c.Country__c, 
						c.Countries_Participating__c, 
						c.Compound_Name__c, c.Business_Unit__c 
						From Campaign c
						Where c.Id =: desiredTrialId limit 1];
		return found;
	}
	
	//Email to be sent out when the trial is created
	static public void sendTrialCreationEmail(Id trialId){
		List<Campaign> cmpgnList = [Select Id, Name, OwnerId, Trial_Region__c 
								From Campaign 
								Where Id = :trialId];
		List<String> addressList = new List<String>();
		
		if(cmpgnList.size()>0){
			Campaign cmpgn = cmpgnList[0];
			String ownerId = cmpgn.OwnerId;
			
			//Here we need to add more to determine the mail addresses to receive. Max is 25.
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
							if(addressList.size()<25){//Make sure the email list will be less than 25.
								addressList.add(tempEmail);
							}
						}
					}
				}
			}

			for(String addr : addressList){
				System.debug('*** Email Addr to be sent: ' + addr);
			}
			
			try {
				//Get the email template
				EmailTemplate et = [Select Id, Subject, Body 
								From EmailTemplate 
								Where DeveloperName = 'Trial_Created' limit 1];	
				List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>{};
				String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
				
				//Merge the fields
				Map<String,String> fields = new Map<String,String> {
					'%id%' => cmpgn.Id,
					'%TrialName%' => cmpgn.Name,
					'%BaseUrl%' => baseUrl
				};
				String subject = mergeFields(et.Subject, fields);
				String body = mergeFields(et.Body, fields);
				
				system.debug('*** subject: ' + subject);
				system.debug('*** body: ' + body);
				
				//Prepare email
				Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
				email.setPlainTextBody(body);
				email.setSaveAsActivity(false);
				email.setSubject(subject);
				email.setCcAddresses(addressList);
			
				//Add to the email queue
				emails.add(email);

				//Send emails
				Messaging.sendEmail(emails);
				system.debug('*** Trial Creation Email Sent Sucessfully.');
			}
			catch(System.Exception ex) {
				system.debug('*** ex: ' + ex);
			}
		}
	}
	//Merge field values with email templates
	private static String mergeFields(String text, Map<String,String> fields) {
		
		for(String key : fields.keySet()) {
			text = text.replaceAll(key, fields.get(key));
		}
		
		return text;
	}

}
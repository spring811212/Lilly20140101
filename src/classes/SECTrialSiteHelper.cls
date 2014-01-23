/**
 * SECTrialSiteHelper
 * Helper class for manipulating Opportunity object
 * All Opportunity SOQL queries should run from here.
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */
public with sharing class SECTrialSiteHelper {
	static public String trialSitePrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
	static public Schema.DescribeSObjectResult sobjectResult = Opportunity.SObjectType.getDescribe();
	
	static public Map<String, Schema.RecordTypeInfo> mapRTName = sobjectResult.getRecordTypeInfosByName();
	static public Map<Id, Schema.RecordTypeInfo> mapRTIds = sobjectResult.getRecordTypeInfosByID();
	
	static public Set<String> setTrialSiteRTNames = mapRTName.keySet();
	static public Set<Id> setTrialSiteRTIds = mapRTIds.keySet();
	
	static public Set<String> setOfRestrictedStageNames = new Set<String> {'SEC In Progress',
		'Draft SEC Submitted',
		'Revision Requested',
		'Revision Request Completed',
		'PI Change Submitted',
		'PI Changed',
		'PI Change Rejected',
		'PIQ Changed',
		'PIQ Submitted',
		'PIQ Rejected',
		'Site Loc Change Submitted',
		'Site Loc Change Rejected',
		'Site Loc Change Approved'
	};
	
	static public List<Opportunity> findTrialSitesForDesiredTrial(Id desiredTrialId){
		List<Opportunity> foundTrialSites = [Select o.Theraputic_Area__c, o.StageName, 
										o.OwnerId, 
										o.Name, o.Lilly_CRO_Personnel__c, 
										o.Id, o.CloseDate, 
										o.CampaignId, 
										o.AccountId, 
										(Select Name, TrialSite__c, Contact__c, Role__c, Primary__c, 
										Full_Name__c, 
										City__c, State_Province__c, Country__c, Street__c, 
										Email__c, Phone__c, 
										Therapeutic_Area__c, Zip_PostalCode__c 
										From Opportunity_Contact_Roles__r) 
										From Opportunity o
										where o.CampaignId =: desiredTrialId];
		return foundTrialSites;
	}
	
	static public Opportunity createTestTrialSite(Id siteId, Id trialId, String trialSiteName, String trialRegion){
		Lilly_CRO_Personnel__c foobar = new Lilly_CRO_Personnel__c(Name='CRA Not Assigned', Role__c='CRA');
		foobar.First_Name__c = 'CRA';
		
		insert foobar;
		Opportunity trialSite = new Opportunity(Name=trialSiteName, StageName='Feasibility');
		trialSite.AccountId = siteId;
		trialSite.CampaignId = trialId;
		trialSite.Trial_Region__c = trialRegion;
		//trialSite.//Select c.Name, c.Id From Country__c c where c.Name = 'United States'
		trialSite.Lilly_CRO_Personnel__c = [Select l.Role__c, l.Name, 
										l.Id From Lilly_CRO_Personnel__c l where l.Role__c = 'CRA' and l.Name = 'CRA Not Assigned' limit 1].Id;
		trialSite.CloseDate = System.today(); // setting this to something different to check if it picks up correctly from Campaign
		return trialSite;
	}
	
	public static void sendOpptyEmail(Id opptyId, Id ownerId) {
		
		system.debug('*** Sending Oppty Email.');
		//if any of the below SOQL calls throw an exception, the email cannot be sent
		try {
			Set<String> emails = new Set<String>{};

			//oppty->campaign->country
			Opportunity oppty = [select Name, Campaign.Trial_Region__c 
								// This was scripted out on request of Lilly by PwC on 10-16-2013 UGP
								//Campaign.Country__r.Distribution_List__c, 
								//Campaign.Distribution_List__c, 
								//Campaign.Parent.Distribution_List__c, 
								//Campaign.Email_CCGO_group__c, 
								//Campaign.Email_CTSS_group__c, 
								//Campaign.Email_Impact_Group__c, 
								//Campaign.Email_MAOps_group__c 
								from Opportunity where Id = :opptyId];
			
			//Remove this and use the distribution list in the custom setting instead for sending emails
			//Only the distribution list ends with 'CCGO', 'CTSS', 'Impact' and 'MAOps' should be included in the email receipients
			List<String> trailRegionList = oppty.Campaign.Trial_Region__c.split(';');
			List<Distribution_List__c> distributionList = Distribution_List__c.getall().values();
			for(Distribution_List__c distribution : distributionList){
				for(String trialRegion : trailRegionList){
					if(distribution.Name.toLowerCase().startsWith((trialRegion + ' CCGO').toLowerCase())
						|| distribution.Name.toLowerCase().startsWith((trialRegion + ' CTSS').toLowerCase())
						|| distribution.Name.toLowerCase().startsWith((trialRegion + ' Impact').toLowerCase())
						|| distribution.Name.toLowerCase().startsWith((trialRegion + ' MAOps').toLowerCase())){
						List<String> emailList = distribution.Email__c.split(';');
						for(String tempEmail : emailList){
							if(emails.size()<25){
								emails.add(tempEmail); 
							}
						}
					}
				}
			}
			
			for(String addr : emails){
				System.debug('*** Email Addr to be sent: ' + addr);
			}
			
			List<String> emailList = new List<String>(emails);
						
			String links = '';
			for(SEC_Forms_Oppty_Form__c opptyForm : [Select Id, 
											SEC_Forms_Form__r.Trial_Form__c, 
											Opportunity__c, SEC_Forms_Form__c, 
											SEC_Forms_Form__r.Name 
											From SEC_Forms_Oppty_Form__c 
											Where Opportunity__c = :opptyId]) {
				
				System.debug('opptyFormId:'+ opptyForm.Id);
				
				String link = Config.URL_FORMVIEW + 
					'?oid=' + opptyForm.Id + 
					'&tid=' + opptyForm.SEC_Forms_Form__r.Trial_Form__c + 
					'&opptyId=' + opptyForm.Opportunity__c + 
					'&fnom=' + opptyForm.SEC_Forms_Form__c;
					
				links += opptyForm.SEC_Forms_Form__r.Name + ': ' + link + '\n';
			}

			//get template
			EmailTemplate et = [select Id, Body, Subject from EmailTemplate where DeveloperName = 'Oppty_Stage_Site_Selected' limit 1];
			
			//merge
			Map<String,String> fields = new Map<String,String> {
				'%name%' => oppty.Name,
				'%id%' => opptyId,
				'%links%' => links
			};
			
			String body = mergeFields(et.Body, fields);
			String subject = mergeFields(et.Subject, fields);
			
			List<Messaging.singleEmailMessage> msgs = new List<Messaging.singleEmailMessage>{};
			Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
			mail.setTargetObjectId(ownerId);
			mail.setCcAddresses(emailList);
			mail.setSubject(subject);
			mail.setPlainTextBody(body);
			mail.setSaveAsActivity(false);
			msgs.add(mail);
			system.debug('*** email receiver: ' + emailList);
			
			Messaging.SendEmailResult[] ser = Messaging.sendEmail(msgs);
			System.debug('###ser:' + ser);
		}
		catch(System.Exception ex) {
			//missing a parm
			System.debug('@@ERROR:'+ex);
		}
	}
	
	//Merge field values with email templates
	private static String mergeFields(String text, Map<String,String> fields) {
		
		for(String key : fields.keySet()) {
			text = text.replaceAll(key, fields.get(key));
		}
		
		return text;
	}
	
	//Set Display_Forms_Flag__c to true, control the display of PI Change form
	public static void setDisplayFormsFlagToTrue(ID trialSiteId){
		Opportunity trialSite = [SELECT Display_Forms_Flag__c FROM Opportunity WHERE ID =:trialSiteId];
		if(trialSite != null){
			trialSite.Display_Forms_Flag__c = true; 
		}
		
		try{
			update trialSite;
		}
		catch(DMLException e){
			system.debug(e);
		}
	}
	
    //Set Display_Forms_Flag__c to false, control the display of PI Change form
	public static void setDisplayFormsFlagToFalse(ID trialSiteId){
		Opportunity trialSite = [SELECT Display_Forms_Flag__c FROM Opportunity WHERE ID =:trialSiteId];
		if(trialSite != null){
			trialSite.Display_Forms_Flag__c = false; 
		}
		
		try{
			update trialSite;
		}
		catch(DMLException e){
			system.debug(e);
		}
	}
	
	//Set Display_Location_Change__c to true, control the display of Location Change form
	public static void setDisplayLocChangeFormsFlagToTrue(ID trialSiteId){
		Opportunity trialSite = [SELECT Display_Location_Change__c FROM Opportunity WHERE ID =:trialSiteId];
		if(trialSite != null){
			trialSite.Display_Location_Change__c = true; 
		}
		
		try{
			update trialSite;
		}
		catch(DMLException e){
			system.debug(e);
		}
	}
	
	//Set Display_Location_Change__c to false, control the display of Location Change form
	public static void setDisplayLocChangeFormsFlagToFalse(ID trialSiteId){
		Opportunity trialSite = [SELECT Display_Location_Change__c FROM Opportunity WHERE ID =:trialSiteId];
		if(trialSite != null){
			trialSite.Display_Location_Change__c = false; 
		}
		
		try{
			update trialSite;
		}
		catch(DMLException e){
			system.debug(e);
		}
	}

}
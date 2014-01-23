/**
 * SECTrialSiteContactRoleHelper
 * Helper class for manipulating Opportunity_Contact_Role__c object
 * All SOQL queries run from here.
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */
public with sharing class SECTrialSiteContactRoleHelper {
	
	static public List<Opportunity_Contact_Role__c>findAllTSCRforTrialSite(Id desiredTrialSiteId){
		List<Opportunity_Contact_Role__c> found = new List<Opportunity_Contact_Role__c>();
		for(Opportunity_Contact_Role__c ocr :[Select o.Zip_PostalCode__c,
						o.TrialSite__r.Trial_Region__c, o.TrialSite__r.StageName, o.TrialSite__r.Name, o.TrialSite__r.AccountId, 
						o.TrialSite__c, 
						o.Therapeutic_Area__c, 
						o.Street__c, 
						o.State_Province__c, 
						o.Role__c, 
						o.Primary__c, 
						o.Phone__c, 
						o.Name, 
						o.Id, 
						o.Email__c, 
						o.Country__c, 
						o.Contact__r.Name, 
						o.Contact__c, 
						o.City__c,
						o.ContactFake__c,
						o.Email_address_for_Safety_Mailings__c ,
						o.Contact__r.Additional_email_address__c
						From Opportunity_Contact_Role__c o
						where o.TrialSite__c =: desiredTrialSiteId]){
			found.add(ocr);					
		}
		return found;
	}
	
	static public List<Opportunity_Contact_Role__c> findAllTSCRforContact(Id desiredContactId){
		List<Opportunity_Contact_Role__c> found = [Select o.Zip_PostalCode__c,
						o.TrialSite__r.Trial_Region__c, o.TrialSite__r.StageName, o.TrialSite__r.Name, o.TrialSite__r.AccountId, 
						o.TrialSite__c, 
						o.Therapeutic_Area__c, 
						o.Street__c, 
						o.State_Province__c, 
						o.Role__c, 
						o.Primary__c, 
						o.Phone__c, 
						o.Name, 
						o.Id, 
						o.Email__c, 
						o.Country__c, 
						o.Contact__r.Name, 
						o.Contact__c, 
						o.City__c,
						o.ContactFake__c,
						o.Email_address_for_Safety_Mailings__c,
						o.Contact__r.Additional_email_address__c 
						From Opportunity_Contact_Role__c o
						where o.Contact__c =: desiredContactId];
		return found;
	}
	static public List<Contact> findAllContactforSite(Id desiredSiteId){
		List<Contact> found = [Select c.Id, 
						c.Name, c.MailingStreet, 
						c.MailingState, 
						c.MailingPostalCode, 
						c.MailingCountry, 
						c.MailingCity, 
						c.Email,
						c.Additional_email_address__c
						From Contact c
						where c.AccountId =: desiredSiteId];
		return found;
	}
	
	static public void checkDuplicateRoleForTheSameContact(List<Opportunity_Contact_Role__c> opptyContactRoleList){
		
		Set<ID> trialSiteIdSet = new Set<ID>();
	    for (Opportunity_Contact_Role__c ocr : opptyContactRoleList){
	        trialSiteIdSet.add(ocr.TrialSite__c);
	    }
	    
	    List<Opportunity_Contact_Role__c> currentOCRList = [SELECT Id, Contact__c, Role__c, TrialSite__c, NameText__c FROM Opportunity_Contact_Role__c WHERE TrialSite__c in: trialSiteIdSet];
	    
	    for(Opportunity_Contact_Role__c newContact : opptyContactRoleList){
	        for(Opportunity_Contact_Role__c ocr : currentOCRList){
	            if(ocr.TrialSite__c == newContact.TrialSite__c && ocr.Role__c == newContact.Role__c && 
	               ocr.Id != newContact.Id && ocr.Contact__c == newContact.Contact__c && newContact.Role__c != 'Principal Investigator'){
	            	String errMsg = 'You have already assign role:' + newContact.Role__c + ' to ' + ocr.NameText__c + '!';
	                newContact.addError(errMsg);
	                return;
	            }
	        
	        }
	    }
	}
	
	static public void checkPIExists(List<Opportunity_Contact_Role__c> opptyContactRoleList){
		String roleName = 'Principal Investigator';
	    List<Id> trialSiteIdList = new List<Id>();
	    for (Opportunity_Contact_Role__c ocr : opptyContactRoleList){
	        trialSiteIdList.add(ocr.TrialSite__c);
	    }
	    
	    List<Opportunity_Contact_Role__c> ocrList = [SELECT Id,TrialSite__c FROM Opportunity_Contact_Role__c WHERE TrialSite__c in :trialSiteIdList and Role__c =:roleName];
	    
	    for (Opportunity_Contact_Role__c ocr : opptyContactRoleList){
	        if(ocr.Role__c == roleName){
	            for(Opportunity_Contact_Role__c o : ocrList){
	                if(ocr.TrialSite__c == o.TrialSite__c && ocr.Id != o.Id){
	                    ocr.addError(Label.Duplicate_PI_Role);
	                    return;
	                }
	            }
	        } 
	    }
	}
	
	static public list<Contact> findContactAddr(String nameCriteria){
		String likeCriteria = '%' + String.escapeSingleQuotes(nameCriteria) + '%';
		List<Contact> found = [Select c.Id, 
				c.Name, c.MailingStreet, 
				c.MailingState, 
				c.MailingPostalCode, 
				c.MailingCountry, 
				c.MailingCity, 
				c.Email,
				c.Additional_email_address__c
				From Contact c
				where c.Name like :likeCriteria];
		return found;
	}
	
	static public list<Opportunity_Contact_Role__c> findContactRoleAddr(String nameCriteria){
		String likeCriteria = '%' + String.escapeSingleQuotes(nameCriteria) + '%';
		List<Opportunity_Contact_Role__c> found = [Select o.Zip_PostalCode__c,
						o.TrialSite__r.Trial_Region__c, o.TrialSite__r.StageName, o.TrialSite__r.Name, o.TrialSite__r.AccountId, 
						o.TrialSite__c, 
						o.Therapeutic_Area__c, 
						o.Street__c, 
						o.State_Province__c, 
						o.Role__c, 
						o.Primary__c, 
						o.Phone__c, 
						o.Name, 
						o.Id, 
						o.Email__c, 
						o.Country__c, 
						o.Contact__r.Name, 
						o.Contact__c, 
						o.City__c,
						o.ContactFake__c,
						o.Email_address_for_Safety_Mailings__c,
						o.Contact__r.Additional_email_address__c 
						From Opportunity_Contact_Role__c o
						where o.Contact__r.Name like :likeCriteria];
		return found;
	}
}
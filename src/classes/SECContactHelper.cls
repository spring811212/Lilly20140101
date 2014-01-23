/**
 * SECContactHelper
 * Helper class for manipulating Contact object
 * All Contact SOQL queries should run from here.
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */
public with sharing class SECContactHelper {
	
	static public String contactPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
	static public Schema.DescribeSObjectResult sobjectResult = Contact.SObjectType.getDescribe();
	
	static public Map<String, Schema.RecordTypeInfo> mapRTName = sobjectResult.getRecordTypeInfosByName();
	static public Map<Id, Schema.RecordTypeInfo> mapRTIds = sobjectResult.getRecordTypeInfosByID();
	
	static public Set<String> setContactRTNames = mapRTName.keySet();
	static public Set<Id> setContactRTIds = mapRTIds.keySet();
	
	static public Contact createTestContact(String firstName, String lastName, String email, 
											String professionalRole,
											String speciality, 
											String therapeuticArea){
		Contact tmpContact = new Contact();
		tmpContact.FirstName = firstName;
		tmpContact.LastName = lastName;
		tmpContact.Email = email;
		tmpContact.Role__c = professionalRole;
		tmpContact.Specialty__c = speciality;
		tmpContact.Therapeutic_Area__c = therapeuticArea;
		return tmpContact;
	}
	
	static public Contact findDesiredContact(Id desiredContactId){
		String desiredIdString = (String) desiredContactId;
		String baseQuery = SECContactHelper.baseQueryString();
		String whereQuery = ' Where c.Id = \'' + String.escapeSingleQuotes(desiredIdString) + '\'';
		String limitQuery = ' Limit 1';
		String fullQuery = baseQuery + whereQuery + limitQuery;
		Contact[] foundList = Database.query(fullQuery);
		
		if (foundList.size() > 1){
    		throw new SECException('findDesiredContact Bad Query returned more than one record '+foundList.size());
    	}
    	
    	return foundList[0];
	}
	
	// PLEASE ADD ADDITIONAL PARAMETERS IN FOLLOWING QUERIES
    // HOPEFULLY WE ARE NOT BUILDING SOQL QUERIES ALL OVER THE PLACE FOR Contact
	
	static public Map<Id, Contact> findDesiredContacts(Set<Id> desiredContactIds){
		Map<Id, Contact> found = new Map<Id, Contact>([Select c.Therapeutic_Area__c, c.Specialty__c, c.Role__c, 
													c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherCountry, c.OtherCity, 
													c.Name, c.LastName, c.Id, c.FirstName, c.Email, 
													c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, 
													c.Lilly_Person_ID__c,  c.Department, c.AccountId, c.Academic_Society_Research_Group__c, 
													c.AP_Academic_Association__c, 
													(Select Name, TrialSite__c, Contact__c, 
													Role__c, Primary__c, Therapeutic_Area__c, 
													City__c, State_Province__c, Country__c, Street__c, Email__c, Phone__c, 
													Zip_PostalCode__c From Opportunity_Contact_Roles__r)
													From Contact c
													Where c.Id in: desiredContactIds]);
		return found;
	}
	
	
    static private String baseQueryString(){
    	String sq = 'Select c.Therapeutic_Area__c, c.Specialty__c, c.Role__c, ';
    	sq += 'c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherCountry, c.OtherCity, ';
    	sq += 'c.Name, c.LastName, c.Id, c.FirstName, c.Email, ';
    	sq += 'c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity,';
    	sq += 'c.Lilly_Person_ID__c,  c.Department, c.AccountId, c.Academic_Society_Research_Group__c, ';
    	sq += 'c.AP_Academic_Association__c, ';
    	sq += '(Select Name, TrialSite__c, Contact__c, ';
    	sq += 'Role__c, Primary__c, Therapeutic_Area__c, ';
    	sq += 'City__c, State_Province__c, Country__c, Street__c, Email__c, Phone__c, ';
    	sq += 'Zip_PostalCode__c From Opportunity_Contact_Roles__r) ';
    	sq += 'From Contact c ';
    	return sq;
    }

}
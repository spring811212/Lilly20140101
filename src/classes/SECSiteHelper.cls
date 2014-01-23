/**
 * SECSiteHelper
 * Helper class for manipulating Account object
 * All Account SOQL queries should run from here.
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */
public with sharing class SECSiteHelper {
	static public String sitePrefix = Account.sObjectType.getDescribe().getKeyPrefix();
	static public Schema.DescribeSObjectResult sobjectResult = Account.SObjectType.getDescribe();
	static public Map<String, Schema.RecordTypeInfo> mapRTName = 
                                            sobjectResult.getRecordTypeInfosByName();
    static public Map<Id, Schema.RecordTypeInfo> mapRTIds = 
                                            sobjectResult.getRecordTypeInfosByID();
	static public Set<String> setAccountRTNames = mapRTName.keySet();
    static public Set<Id> setAccountRTIds = mapRTIds.keySet();
    
    
    
    
    static public Account createTestAccount(String recordTypeName, 
                                            String testName,
                                            String accountType, 
                                            String therapeuticArea){
        Account testAccount = null;
        Schema.RecordTypeInfo rtInfo = SECSiteHelper.mapRTName.get(recordTypeName);
        testAccount = new Account(Name=testName);
        testAccount.RecordTypeId = rtInfo.getRecordTypeId();
        //a.Type, a.Therapeutic_Area__c, a.Name, a.Id
        testAccount.Type = accountType;	//'Hospital';
        testAccount.Therapeutic_Area__c = therapeuticArea;	// 'Oncology'
        
        return testAccount;
    }
    
    static public Account findDesiredSite(Id desiredSiteId){
    	String desiredIdString = (String) desiredSiteId;
    	String baseQuery = SECSiteHelper.baseSiteQueryString();
    	String whereQuery = ' Where a.Id = \'' + String.escapeSingleQuotes(desiredIdString) + '\'';
    	String limitQuery = ' Limit 1';
    	String fullQuery = baseQuery + whereQuery + limitQuery;
    	Account[] foundList = Database.query(fullQuery);
    	
    	if (foundList.size() > 1){
    		throw new SECException('findDesiredSite Bad Query returned more than one record '+foundList.size());
    	}
    	
    	return foundList[0];
    }
    
    // PLEASE ADD ADDITIONAL PARAMETERS IN THIS QUERY
    // HOPEFULLY WE ARE NOT BUILDING SOQL QUERIES ALL OVER THE PLACE FOR Account aka Site
    static private String baseSiteQueryString(){
    	String sq = 'Select a.Type, ';
    	sq += 'a.Therapeutic_Area__c, ';
    	sq += 'a.Name, ';
    	sq += '(Select Id, LastName, FirstName, Name, Email, Department, Role__c, Specialty__c, Therapeutic_Area__c From Contacts), ';
    	sq += 'a.Id ';
    	sq += 'From Account a ';
    	return sq;
    }
}
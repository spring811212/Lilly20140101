/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SECTrialSiteContactRoleHelperTest {

    static testMethod void testFindingTrialSiteContactRoleForGivenContact() {
    	List<User> testClinicalUsers = new List<User>();
    	// Create a fake NA CDL user
    	User testCDL = SECUserHelper.createNACDL();
    	testClinicalUsers.add(testCDL);
    	User testCOPM = SECUserHelper.createNACOPM();
    	testClinicalUsers.add(testCOPM);
    	
    	insert testClinicalUsers;
    	
    	Account testSiteA;
    	Integer numberOfContactsAtSiteA = 14;
    	List<Contact> contactsAtSiteA;
    	Set<Id> setOfContactIdsAtSiteA;
    	Contact testScientist;
    	List<Opportunity_Contact_Role__c> listOfTSCRs;
    	Campaign testTrial;
    	String therapeuticArea = 'Oncology';
    	String compoundName = 'Cool Molecule';
    	String trialRegion = 'NA';
    	String businessUnit = 'Oncology';
    	
		Set<String> setOfRequiredRoles = new Set<String> {'Principal Investigator',
    		'Sub-Investigator',
    		'Primary Study Coordinator',
    		'Other Key Staff',
    		'Regulatory',
    		'Pharmacist',
    		'Ship Lab Supplies to',
    		'Ship CRFs to',
    		'Laboratory',
    		'Ship investigational product (IP) to',
    		'Budgets',
    		'Grant Payments',
    		'Send Contract (LOA) to',
    		'Ltr of Agreement/Study Work Orders(SWO)'
    	};
    	
    	Map<Integer, String> tblOfRequiredRoles = new Map<Integer, String>();
    	tblOfRequiredRoles.put(0, 'Principal Investigator');
    	tblOfRequiredRoles.put(1, 'Sub-Investigator');
    	tblOfRequiredRoles.put(2, 'Primary Study Coordinator');
    	tblOfRequiredRoles.put(3, 'Other Key Staff');
    	tblOfRequiredRoles.put(4, 'Regulatory');
    	tblOfRequiredRoles.put(5, 'Pharmacist');
    	tblOfRequiredRoles.put(6, 'Ship Lab Supplies to');
    	tblOfRequiredRoles.put(7, 'Ship CRFs to');
    	tblOfRequiredRoles.put(8, 'Laboratory');
    	tblOfRequiredRoles.put(9, 'Ship investigational product (IP) to');
    	tblOfRequiredRoles.put(10, 'Budgets');
    	tblOfRequiredRoles.put(11, 'Grant Payments');
    	tblOfRequiredRoles.put(12, 'Send Contract (LOA) to');
    	tblOfRequiredRoles.put(13, 'Ltr of Agreement/Study Work Orders(SWO)');
    	
    	
    	System.runAs(testCOPM){
    		Campaign tmpTrialNA = SECTrialHelper.createTestTrial(businessUnit, therapeuticArea, compoundName, trialRegion);
    		insert tmpTrialNA;
    		testTrial = SECTrialHelper.findDesiredTrial(tmpTrialNA.Id);
    		System.assertEquals(tmpTrialNA.Id, testTrial.Id);
    		System.assertEquals(tmpTrialNA.Business_Unit__c, testTrial.Business_Unit__c);
    		System.assertEquals(tmpTrialNA.Compound_Name__c, testTrial.Compound_Name__c);
    		System.assertEquals(tmpTrialNA.Trial_Region__c, testTrial.Trial_Region__c);
    		System.assertEquals(tmpTrialNA.Therapeutic_Area__c, testTrial.Therapeutic_Area__c);
    		System.assertEquals(tmpTrialNA.LPET_Date__c, testTrial.LPET_Date__c);
    	}
    	
    	System.runAs(testCDL){
    		// Step 1 create a Site
    		String recordTypeName = 'Site (Account) Record Type';
    		String testName = 'Test Hospital';
    		String accountType = 'Hospital';
    		
    		testSiteA = SECSiteHelper.createTestAccount(recordTypeName,
    													testName, 
    													accountType, 
    													therapeuticArea);
    		insert testSiteA;
    		Account foundSiteA = SECSiteHelper.findDesiredSite(testSiteA.Id);
    		System.assertEquals(testSiteA.Id, foundSiteA.Id);
    		System.assertEquals(therapeuticArea, foundSiteA.Therapeutic_Area__c);
    		System.assertEquals(accountType, foundSiteA.Type);
    		System.assert(foundSiteA.Contacts.isEmpty());
    		
    		// Step 2 Create few contacts
    		setOfContactIdsAtSiteA = new Set<Id>();
    		contactsAtSiteA = new List<Contact>();
    		String firstName = 'Testprof';
    		String lastName = 'tApex';
    		String tmpEmail = '@lilly.sec.dev';
    		String professionalRole = 'Director';
    		String speciality = 'All Tumor Types';
    		String contactTherapeuticArea = 'Oncology';
    		for (Integer i=0; i < numberOfContactsAtSiteA; i++){
    			Contact tmp = SECContactHelper.createTestContact(firstName + math.rint(math.random()*1000), //firstName, 
    															lastName, 
    															'tapx'+i+tmpEmail,//email, 
    															professionalRole, 
    															speciality, 
    															contactTherapeuticArea);//therapeuticArea);
    			tmp.AccountId = foundSiteA.Id;
    			setOfContactIdsAtSiteA.add(tmp.Id);
    			contactsAtSiteA.add(tmp);
    		}
    		
    		insert contactsAtSiteA;
    		
    		// Step 3 create a trialSite
    		Opportunity tmpTrialSite = SECTrialSiteHelper.createTestTrialSite(foundSiteA.Id,//siteId, 
    																		testTrial.Id, //trialId, 
    																		'TestApexTrialSite',//trialSiteName, 
    																		'NA');//trialRegion)
    																		
    		System.assertNotEquals(testTrial.LPET_Date__c, tmpTrialSite.CloseDate);
    		insert tmpTrialSite;
    		List<Opportunity> foundTrialSites = SECTrialSiteHelper.findTrialSitesForDesiredTrial(testTrial.Id);
    		System.assert(!foundTrialSites.isEmpty(), 'Impossible expect to find minimum one trial site');
    		System.assert(foundTrialSites.size() == 1);
    		Opportunity foundTrialSite = foundTrialSites[0];
    		System.assertEquals(tmpTrialSite.Id, foundTrialSite.Id);
    		System.assertEquals(tmpTrialSite.AccountId, foundTrialSite.AccountId);
    		System.assertEquals(tmpTrialSite.CampaignId, foundTrialSite.CampaignId);
    		//System.assertNotEquals(tmpTrialSite.CloseDate, foundTrialSite.CloseDate);
    		//System.assertEquals(testTrial.LPET_Date__c, foundTrialSite.CloseDate);
    		
    		
    		listOfTSCRs = new List<Opportunity_Contact_Role__c>();
    		
    		Integer key = 0;
    		for (Contact c : contactsAtSiteA){
    			Opportunity_Contact_Role__c tscr = new Opportunity_Contact_Role__c();
    			tscr.Role__c = tblOfRequiredRoles.get(key);
    			tscr.Contact__c = c.Id;
    			tscr.TrialSite__c = foundTrialSite.Id;
    			
    			key += 1;
    			listOfTSCRs.add(tscr);
    		}
    		
    		System.assertEquals(contactsAtSiteA.size(), listOfTSCRs.size());
    		System.assertEquals(setOfRequiredRoles.size(), listOfTSCRs.size());
    		insert listOfTSCRs;
    		//Select o.Zip_PostalCode__c, o.TrialSite__c, o.Therapeutic_Area__c, o.Street__c, o.State_Province__c, o.Role__c, o.Primary__c, o.Phone__c, o.Name, o.Id, o.Full_Name__c, o.Country__c, o.Contact__c, o.City__c From Opportunity_Contact_Role__c o
    		
    		Test.startTest();
    		List<Opportunity_Contact_Role__c> foundListOfTSCRs = SECTrialSiteContactRoleHelper.findAllTSCRforTrialSite(foundTrialSite.Id);
    		System.assert(!foundListOfTSCRs.isEmpty(), 'Cannot be empty');
    		System.assertEquals(listOfTSCRs.size(), foundListOfTSCRs.size());
    		
    		for (Opportunity_Contact_Role__c tscr : foundListOfTSCRs){
    			System.assertEquals(foundTrialSite.Id, tscr.TrialSite__c);
    			//System.assert(setOfContactIdsAtSiteA.contains(tscr.Contact__c));
    			System.assert(setOfRequiredRoles.contains(tscr.Role__c));
    		}
    		
    		// Now also test finding via given contact
    		Contact desiredContact = contactsAtSiteA.get(0);
    		List<Opportunity_Contact_Role__c> foundListOfTSCRsByContact = SECTrialSiteContactRoleHelper.findAllTSCRforContact(desiredContact.Id);
    		System.assert(!foundListOfTSCRsByContact.isEmpty(), 'Cannot be empty');
    		System.assertEquals(1, foundListOfTSCRsByContact.size());
    		
    		Test.stopTest();
    	}
    	
    }
}
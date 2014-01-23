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
private class SECTrialSiteContactRoleControllerTest {

    static testMethod void testTrialSiteContactRoleCreation() {
    	Test.startTest();
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
    	
    	testTrial = SECTrialHelper.createTestTrial(businessUnit, therapeuticArea, compoundName, trialRegion);
    	insert testTrial;
    	
    	// Step 1 create a Site
		String recordTypeName = 'Site (Account) Record Type';
		String testName = 'Test Hospital';
		String accountType = 'Hospital';
		
		Account testSiteA = SECSiteHelper.createTestAccount(recordTypeName,
													testName, 
													accountType, 
													therapeuticArea);
		insert testSiteA;
    	
    	// Step 2 Create few contacts
		List<Contact> contactsAtSiteA = new List<Contact>();
		String firstName = 'Testprof';
		String lastName = 'tApex';
		String tmpEmail = '@lilly.sec.dev';
		String professionalRole = 'Director';
		String speciality = 'All Tumor Types';
		String contactTherapeuticArea = 'Oncology';
		Integer numberOfContactsAtSiteA = 14;
		for (Integer i=0; i < numberOfContactsAtSiteA; i++){
			Contact tmp = SECContactHelper.createTestContact(firstName + math.rint(math.random()*1000), //firstName, 
															lastName, 
															'tapx'+i+tmpEmail,//email, 
															professionalRole, 
															speciality, 
															contactTherapeuticArea);//therapeuticArea);
			tmp.AccountId = testSiteA.Id;
			contactsAtSiteA.add(tmp);
		}
		
		insert contactsAtSiteA;
    	
    	// Step 3 create a trialSite
		Opportunity tmpTrialSite = SECTrialSiteHelper.createTestTrialSite(testSiteA.Id,//siteId, 
																		testTrial.Id, //trialId, 
																		'TestApexTrialSite',//trialSiteName, 
																		'NA');//trialRegion)
																		
		insert tmpTrialSite;
    	
    	listOfTSCRs = new List<Opportunity_Contact_Role__c>();
    		
		Integer key = 0;
		for (Contact c : contactsAtSiteA){
			if(key>=1){
				break;
			}
			Opportunity_Contact_Role__c tscr = new Opportunity_Contact_Role__c();
			tscr.Role__c = tblOfRequiredRoles.get(key);
			tscr.Contact__c = c.Id;
			tscr.TrialSite__c = tmpTrialSite.Id;
			
			key += 1;
			listOfTSCRs.add(tscr);
		}
		insert listOfTSCRs;
    	
    	SECTrialSiteContactRoleController controller = new SECTrialSiteContactRoleController(new ApexPages.StandardController(listOfTSCRs[0]));
    	controller.retrieveContactRoles();
    	controller.addTrialContactRoles();
    	controller.saveTrialContactRoles();
    	controller.cancelTrialContactRoles();
    	controller.gotoSelectContactAddress();
    	
    	//Delete
    	controller.delIndex = 1;
    	controller.DeleteTrialContactRoles();
    	
    	controller.initContactAddress();
    	
    	//Search
    	controller.searchCriteria = 'Test';
    	controller.searchContactAddress();
    	
    	//Select
    	if(controller.contactAddrList.size()>0){
    		controller.contactAddrList[0].isSelect = true;
    	}    	
    	controller.selectContactAddress();
    	
    	controller.cancelSelectContactAddress();
    	Test.stopTest();
    	
    	SECTrialSiteContactRoleHelper.findAllTSCRforContact(contactsAtSiteA[0].Id);
    }
}
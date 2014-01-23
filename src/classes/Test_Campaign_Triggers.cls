@isTest
private class Test_Campaign_Triggers {

    static testMethod void myUnitTest() {
        
		//insert test data
		Campaign c = new Campaign();
        c.Name = 'TestNA';
        insert c;
        
        test.startTest();
        
        //attempt update of bad emails and catch exception thrown
        try {
        	c.Distribution_List__c = 'test email,test@email';
        	update c;
        } catch(Exception e) {
        	system.debug(Logginglevel.INFO, e);
        }
        
        test.stopTest();
        
        
    }
}
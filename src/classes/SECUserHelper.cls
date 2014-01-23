/**
 * SECUserHelper
 * Helper class that contains common utils for User 
 *
 * @see         User
 * Common place to manage the various Lilly Users
 *
 * Author(s):   PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */
public with sharing class SECUserHelper {
	static public String userPrefix = User.sObjectType.getDescribe().getKeyPrefix();
	
	static public User createNACDL(){
		UserRole desiredRole = [Select u.Name, u.Id From UserRole u where u.Name = 'NA Oncology East CDL' limit 1];
		User cdl = new User();
		cdl.FirstName = 'TestNA';
    	cdl.LastName = 'OncologyCDL';
    	cdl.Username = 'testna.testcdl@lillysec.com.dev';
    	cdl.Email = 'testna.testcdl@lillysec.com.dev';
    	cdl.Alias = 'tCDLapx';
    	cdl.EmailEncodingKey = 'ISO-8859-1';
        cdl.TimeZoneSidKey = 'America/New_York';
        cdl.LocaleSidKey = 'en_US';
        cdl.LanguageLocaleKey = 'en_US';
        cdl.CommunityNickname = 'Test ApexNACDL';
        cdl.ProfileId = SECProfileHelper.getDesiredProfile('NA CDL').Id;
        cdl.UserRoleId = desiredRole.Id;
    	return cdl;
	}
	
	static public User createNACOPM(){
		//NA Oncology East Manager
		UserRole desiredRole = [Select u.Name, u.Id From UserRole u where u.Name = 'NA Oncology East Manager' limit 1];
		User copm = new User();
		copm.FirstName = 'TestNA';
    	copm.LastName = 'OncologyCOPM';
    	copm.Username = 'testna.testcopm@lillysec.com.dev';
    	copm.Email = 'testna.testcopm@lillysec.com.dev';
    	copm.Alias = 'tCOPMapx';
    	copm.EmailEncodingKey = 'ISO-8859-1';
        copm.TimeZoneSidKey = 'America/New_York';
        copm.LocaleSidKey = 'en_US';
        copm.LanguageLocaleKey = 'en_US';
        copm.CommunityNickname = 'Test ApexNACOPM';
        copm.ProfileId = SECProfileHelper.getDesiredProfile('NA COPM').Id;
        copm.UserRoleId = desiredRole.Id;
		return copm;
	}
}
/**
 * SECProfileHelper
 * Helper class that contains common utils for Profiles 
 *
 * @see         Profile
 * Common place to manage the various Lilly Profiles
 *
 * Author(s):   PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 *
 */
public with sharing class SECProfileHelper {
	
	static public Profile getDesiredProfile(String desiredProfileName){
		System.debug(LoggingLevel.info,'PROFILE NAME='+desiredProfileName);
		Profile desiredProfile = null;
		desiredProfile = [Select p.Name, p.Id From Profile p 
							Where p.Name =: desiredProfileName limit 1];
		
		return desiredProfile;
	}
	
	static public Profile getDesiredProfile(Id desiredProfileId){
    	Profile desiredProfile = null;
    	desiredProfile = [Select p.Name, 
    					p.Id
    					From Profile p
    					Where p.Id =: desiredProfileId limit 1];
    	return desiredProfile;
    }
}
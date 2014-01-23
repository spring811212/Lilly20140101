/**
 * SECFormTriggerHelper
 * Helper class for help track whether the trigger has already been fired to ensure it's only fired once
 *
 * Author(s):	PwC (Unni Pillai, Edison Huang, Keen Xu, Jker Wang)
 *
 * Last modified by: $Author:$
 * copyright(c) 2013, 2014 Eli Lilly
 */
public with sharing class SECFormTriggerHelper {
	private static boolean flagvalue = false;
	
	public static boolean hasAlreadyfired() {
		return flagvalue;
	}
	
	public static void setAlreadyfired() {
		flagvalue = true;
	}
}
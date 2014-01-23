public with sharing class CampaignTriggersUtil {
	
	public static void catchBadDistributionListInsert(Campaign[] NewCap) {
		
		list<String> distEmails = new list<String>();
		
		for(Campaign c: NewCap) {
			String cName = c.Name.toLowerCase(); //endswith is case sensitive, using all lower case for comparison
			if( (cName.endsWith('na') || cName.endsWith('us')) && c.Distribution_List__c != null) {
				String[] arrayEmails = c.Distribution_List__c.split(',');
				distEmails.AddAll(arrayEmails);
			}
		}
		
		list<String> badEmails = new list<String>();
		
		//if distribution list has more than one item
		if(distEmails.Size() > 0) {
			for(String e : distEmails) {
				
				//Comparison using pattern match
				String pat = '[a-zA-Z0-9\\.\\!\\#\\$\\%\\&\\*\\/\\=\\?\\^\\_\\+\\-\\`\\{\\|\\}\\~\'._%+-]+@[a-zA-Z0-9\\-.-]+\\.[a-zA-Z]+';
				Boolean goodEmail = Pattern.matches(pat, e);
				
				if(goodEmail == false) {
					badEmails.add(e);
				}
				
			}
		}
		
		//if list of bad emails contains one more more throw an exception on the field
		if(badEmails.Size() > 0) {
			String badEmailsFlat = '';
			for(String e : badEmails) {
				badEmailsFlat = badEmailsFlat + e + ';';
			}
			for(Campaign c : NewCap) {
				c.Distribution_List__c.addError('Please correct the following: ' + badEmailsFlat);
			}
		}
	}

}
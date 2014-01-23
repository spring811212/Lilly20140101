global class ApprovalUtils {

	@future
	global static void approveOpportunity(Set<Id> opptyIds) {
		
		List<Approval.ProcessSubmitRequest> psrs = new List<Approval.ProcessSubmitRequest>{};
		Map<Integer,Id> index = new Map<Integer,Id>{};
		
		//for any possible errors
		Set<Id> badIds = new Set<Id>{};
		
		//System.DMLException dmlex;
		
		for(Id opptyId : opptyIds) {
			Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
			psr.setObjectId(opptyId);
				
			psrs.add(psr);
			index.put(index.size(), opptyId);
		}
		
		try {
			Approval.process(psrs);
		}
		catch (System.DMLException dex) {
			
			//dmlex = dex;
			//ALREADY_IN_PROCESS
			if (!dex.getMessage().contains('ALREADY_IN_PROCESS')) {
				for(Integer i = 0; i < dex.getNumDml(); i++) {
			//		if (!dex.getMessage(i).contains('ALREADY_IN_PROCESS')) {
					badIds.add(index.get(dex.getDmlIndex(i)));
			//		}
				}
			}
		}
		
		if (badIds.size() > 0) {
			String errMsg = 'The SEC Forms application tried to send your form for approval but could not.  There was a problem finding an appropriate approval process.  Please contact your administrator.';
			
			List<Messaging.SingleEmailMessage> errEmails = new List<Messaging.SingleEmailMessage>{};
			
			for(Opportunity oppty : [select Id, Name, Owner.Email, StageName from Opportunity where Id in :badIds]) {
				
				/*
				Form_Type => StageName
				SEC_CRU => Draft SEC Submitted
				PI Change => PI Change Submitted
				Other => ???
				*/
				
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setPlainTextBody(
					errMsg + '\n\n' +
					'Opportunity: ' + oppty.Name + '\n' +
					'Link to Oppty: ' + Config.URL_SFDC + oppty.Id
				);
				email.setToAddresses(new List<String>{ oppty.Owner.Email });
				email.setSubject('Approval Failure');
				
				errEmails.add(email);
			}
			
			try {
				Messaging.sendEmail(errEmails);
			}
			catch (System.EmailException eex) {
				//if the email fails too then??
			}
		}
	}

}
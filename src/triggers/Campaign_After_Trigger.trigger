trigger Campaign_After_Trigger on Campaign (after insert, after update) {
	//PwC Update: Include insert trigger
	if(trigger.isInsert){
		system.debug('*** sending emails for trail creation.');
		SECTrialHelper.sendTrialCreationEmail(trigger.New[0].Id);//It doesn't make sense to send the email when create campaign in bulk, so only send email for the first one
	}
	else if(trigger.isUpdate){
		system.debug('*** campaignOwnerCheck');
		//This is existing functions which only triggers on Trial Update
		SEC_Forms_Service.campaignOwnerCheck(trigger.New, trigger.Old);
	}
	//PwC Update End
}
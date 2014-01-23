trigger Campaign_Before_Trigger on Campaign (before insert, before update) {
	
	if(trigger.isInsert || trigger.isUpdate) {
		CampaignTriggersUtil.catchBadDistributionListInsert(trigger.new);
	}

}
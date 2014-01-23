public with sharing class SEC_Forms_Service {

    //when an opportunity is inserted or updated
    //make sure the field Trial_Owner__c matches the owner of the
    //Campaign that is related to the Opportunity.
    public static void opptySetTrialOwner(List<Opportunity> triggerNew)
    {
        System.debug('Trigger size ='+ triggerNew.size());
        
        Integer i;
        
        //List<Opportunity> oppsToUpdate = new List<Opportunity>(); //<--remove?
        Set<Id> triggerIds = new Set<Id>();

        for (i=0; i<triggerNew.size(); i++) 
        {
         triggerIds.add(triggerNew[i].Id);
         System.debug('Adding Trigger ID='+ triggerNew[i].Id);
        }

        map<Id,Id> oppMap = new map<Id,Id>();
        for (opportunity opp : [Select o.Id, o.Campaign.OwnerId From Opportunity o WHERE o.Id IN :triggerIds])
        {
            oppMap.put(opp.id,opp.Campaign.OwnerId);
            System.debug('Campaign owner id='+ opp.Campaign.OwnerId);
        }
        
        for(Opportunity thisOpp : triggerNew)
        {
            //test to make sure the oppty has a campaign reference
            if (thisOpp.CampaignId != null)
            {
                thisOpp.Trial_Owner__c = oppMap.get(thisOpp.Id);
            }
        }
    }

    //when a campaign has changed owners, find all of the opportunities related to it
    //and change the Trial_Owner__c field to match the new campaign owner
    public static void campaignOwnerCheck(List<Campaign> triggerNew, List<Campaign> triggerOld)
    {
        Integer i;
        System.debug('Trigger size ='+ triggerNew.size());
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<Id> triggerIds = new Set<Id>();

        //loop through the passed Campaigns and find the ones that have changed owners
        for (i=0; i<triggerNew.size(); i++) 
        {
         if (triggerNew[i].OwnerId != triggerOld[i].OwnerId)
         {
            triggerIds.add(triggerNew[i].Id);
            System.debug('Adding Trigger ID='+ triggerNew[i].Id);
         }
        }

        //loop through the campaigns that have changes owners and change the 
        //Trial_Owner__c field to match the new Campaign owner.
        for (opportunity opp : [Select o.Id, o.Campaign.OwnerId From Opportunity o WHERE o.CampaignID IN :triggerIds])        
        {
            Opportunity thisOpp = new Opportunity(Id = opp.Id);
            thisOpp.Trial_Owner__c = opp.Campaign.OwnerId;
            System.debug('Campaign owner id='+ opp.Campaign.OwnerId);
            oppsToUpdate.add(thisOpp);
        }
        
        update oppsToUpdate;
    }

 static testMethod void secFormsUnitTests()
  {
    User u1 = [Select u.Id From User u WHERE u.IsActive = TRUE LIMIT 1];
    User u2 = [Select u.Id From User u WHERE u.IsActive = TRUE AND ID<>:u1.Id and u.Profile.Name = 'System Administrator' LIMIT 1];

    Campaign c = new Campaign();
    c.Name = 'Test Campaign';
    c.Trial_Region__c='NA';
        c.Compound_Name__c ='testcompound';
        c.Therapeutic_Area__c ='Auto-Immune';
        c.LPET_Date__c =system.today();
    insert c;
    
    Account a = new Account();
    a.Name = 'my test account';
    a.BillingCountry = 'US';
    a.ShippingCountry = 'US';
    insert a;
    
    Lilly_CRO_Personnel__c lPer;// =[select l.id from lilly_cro_personnel__c l where l.first_name__c ='CRA Not Assigned'];
    lPer = new Lilly_CRO_Personnel__c();
    lPer.Active__c = true;
    lPer.First_Name__c = 'CRA Not Assigned';
    lPer.Role__c = 'CRA';
    insert lPer;
    
    Opportunity o = new Opportunity();
    o.AccountId = a.Id; 
    o.Trial_Owner__c = u1.Id;
    o.CampaignId = c.Id;
    o.Name = 'test oppty';  
    o.StageName = 'Evaluation';
    o.trial_region__c ='NA';
    o.Lilly_CRO_Personnel__c=lper.id;
    o.CloseDate = system.today();
    o.Form_Submitted__c = false;
    insert o;
    
    c.OwnerId = u2.Id;
    update c;
    
    o.Name = 'testing oppty';
    update o;
    
    }
 

}
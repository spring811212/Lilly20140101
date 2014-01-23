public with sharing class CopyAnswersController {

	public Id targetId;
	public Id sourceId;
	public Id tid;
	public Id opptyId;
	public Id fnom;
	public Boolean renderError {get;private set;}
	public String errorMsg {get;private set;}

	public CopyAnswersController() {
		
		targetId = ApexPages.currentPage().getParameters().get('targetId');
		sourceId = ApexPages.currentPage().getParameters().get('sourceId');
		tid = ApexPages.currentPage().getParameters().get('tid');
		opptyId = ApexPages.currentPage().getParameters().get('opptyId');
		fnom = ApexPages.currentPage().getParameters().get('fnom');
		
		if (targetId == null || sourceId == null || tid == null || opptyId == null || fnom == null) {
			renderError = true;
			errorMsg = 'Required Parameters missing or invalid.';
		}
		else {
			renderError = false;
			errorMsg = '';
		}
		
	}
	
	public PageReference copy() {
		
		if (!renderError) {
			if (formClean()) {
				FormUtils.copyForm(sourceId, targetId);
				//PwC updates: Change from FLEX to web page
				PageReference pr = Page.SECFormStartPage;
				//PageReference pr = Page.Form_View;
				//PwC updates end
				pr.getParameters().putAll(new Map<String,String>{
					'oid' => targetId,
					'tid' => tid,
					'opptyId' => opptyId,
				 	'fnom' => fnom,
				 	'newEval' => '1'
				});
				
				return pr;
			}
			else {
				renderError = true;
				errorMsg = 'Form has already been copied.';
			}
		}
		
		return null;
	}
	
	private Boolean formClean() {
		SEC_Forms_Oppty_Form__c form = [select Source_Form__c from SEC_Forms_Oppty_Form__c where Id = :targetId limit 1];
		return form.Source_Form__c == null;
	}
}
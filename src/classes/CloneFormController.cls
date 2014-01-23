public with sharing class CloneFormController {

	private final Id formId;

	public CloneFormController(){
		formId = ApexPages.currentPage().getParameters().get('id');
	}
	
	public PageReference cloneForm() {
		PageReference pr = null;
		
		if (formId != null) {
			Id newFormId = CloneUtil.cloneForm(formId);
			
			if (newFormId != null) {
				pr = new PageReference('/' + newFormId);
				pr.setRedirect(true);
			}
			else {
				pr = new PageReference('/' + formId);
				pr.setRedirect(true);
			}
		}
		
		return pr;
	}
}
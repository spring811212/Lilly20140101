public with sharing class CloneTemplateController {

	private final Id templateId;

	public CloneTemplateController(){
		templateId = ApexPages.currentPage().getParameters().get('id');
	}
	
	public PageReference cloneTemplate() {
		PageReference pr = null;
		
		if (templateId != null) {
			Id newTemplateId = CloneUtil.cloneTemplate(templateId);
			
			if (newTemplateId != null) {
				pr = new PageReference('/' + newTemplateId);
				pr.setRedirect(true);
			}
			else {
				pr = new PageReference('/' + templateId);
				pr.setRedirect(true);
			}
		}
		
		return pr;
	}
}
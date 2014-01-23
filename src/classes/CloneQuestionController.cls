public with sharing class CloneQuestionController {

	private final Id questionId;

	public CloneQuestionController(){
		questionId = ApexPages.currentPage().getParameters().get('id');
	}
	
	public PageReference cloneQuestion() {
		PageReference pr = null;
		
		if (questionId != null) {
			Id newQuestionId = CloneUtil.cloneQuestion(questionId);
			
			if (newQuestionId != null) {
				pr = new PageReference('/' + newQuestionId);
				pr.setRedirect(true);
			}
			else {
				pr = new PageReference('/' + questionId);
				pr.setRedirect(true);
			}
		}
		
		return pr;
	}
}
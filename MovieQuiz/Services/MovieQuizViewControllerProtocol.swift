protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highLightImageBorder(isCorrectAnswer: Bool)
    
    func loadingIndicatorIsHidden(_ isHidden: Bool)
    
    func showNetworkError(message: String)
    
    func enableButtonsAction(_ enable: Bool)
}

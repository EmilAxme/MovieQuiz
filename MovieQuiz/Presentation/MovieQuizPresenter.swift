import UIKit

final class MovieQuizPresenter {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked(_ sender: Any) {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: Any) {
        didAnswer(isYes: false)
    }
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
        
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        
        guard let currentQuestion else { return }
        
        let viewModel = convert(model: currentQuestion)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.viewController?.show(quiz: viewModel)
        }
        
    }
    
    func didAnswer(isYes: Bool) {
        
        guard let viewController else { return }
        
        viewController.showAnswerResult(isCorrect: isYes)
        viewController.enableButtonsAction(false)
        
    }
    
}

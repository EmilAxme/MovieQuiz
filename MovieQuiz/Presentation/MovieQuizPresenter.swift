import UIKit

final class MovieQuizPresenter {
    
    private var statistics: StatisticServiceProtocol = StatisticServiceImplementation()
    
    var questionFactory: QuestionFactoryProtocol?
    
    var correctAnswers: Int = .zero
    
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
    
    func showNextQuestionOrResults() {
        guard let viewController else { return }
        
        if self.isLastQuestion() {
            statistics.store(correct: correctAnswers, total: self.questionsAmount)
            
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text:"Ваш результат \(correctAnswers)/\(self.questionsAmount) \n Количество сыгранных квизов \(statistics.gamesCount) \n Рекорд: \(statistics.bestGame.correct) / \(statistics.bestGame.total) (\(statistics.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statistics.totalAccuracy))%" ,
                buttonText: "Сыграть еще раз"
            )
            
            viewController.show(quiz: result)
        }
        
        else
        {
            self.switchToNextQuestion()
            guard let questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
        
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
            guard let viewController = self?.viewController else { return }
            
            viewController.show(quiz: viewModel)
        }
        
    }
    
    func didAnswer(isYes: Bool) {
        
        guard let viewController else { return }
        
        viewController.showAnswerResult(isCorrect: isYes)
        viewController.enableButtonsAction(false)
        
    }
    
}

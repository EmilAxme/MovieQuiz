import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties and init
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        statisticService = StatisticServiceImplementation()
        
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader(networkClient: NetworkClient()))
        guard let questionFactory else { return }
        
        questionFactory.loadData()
        viewController.loadingIndicatorIsHidden(false)
    }
    
    // MARK: - Actions
    
    func ButtonClicked(_ answer: Bool) {
        didAnswer(isYes: answer)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        guard let viewController, let questionFactory else { return }
        
        viewController.loadingIndicatorIsHidden(true)
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        guard let viewController else { return }
        
        let message = error.localizedDescription
        viewController.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        currentQuestion = question
        
        guard let currentQuestion else { return }
        
        let viewModel = convert(model: currentQuestion)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            guard let viewController = self.viewController?.show(quiz: viewModel) else { return }
            viewController
        }
        
    }
    
    // MARK: - Functions
    
    private func proceedWithAnswer(isCorrect: Bool) {
        guard let currentQuestion,
                let viewController else { return }
        
        if isCorrect == currentQuestion.correctAnswer {
            correctAnswers += 1
            viewController.highLightImageBorder(isCorrectAnswer: true)
        } else {
            viewController.highLightImageBorder(isCorrectAnswer: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
            viewController.enableButtonsAction(true)
        }
        
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
        
    }
    
    private func didAnswer(isYes: Bool) {
        guard let viewController else { return }
        
        self.proceedWithAnswer(isCorrect: isYes)
        viewController.enableButtonsAction(false)
        
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        guard let viewController else { return }
        
        if self.isLastQuestion() {
            viewController.show(quiz: makeResultMessage())
        } else {
            self.switchToNextQuestion()
            guard let questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
        
    }

    
    //MARK: - Result Alert function
    
    private func makeResultMessage() -> QuizResultsViewModel {
        guard let statisticService else { return QuizResultsViewModel(title: "", text: "", buttonText: "");}
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let result = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text:"Ваш результат \(correctAnswers)/\(questionsAmount) \n Количество сыгранных квизов \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct) / \(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%" ,
            buttonText: "Сыграть еще раз"
        )
        
        return result
    }
    
}

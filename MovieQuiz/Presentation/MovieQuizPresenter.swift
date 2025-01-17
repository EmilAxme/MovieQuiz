import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties and init
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    var correctAnswers: Int = .zero
    
    private var statisticService: StatisticServiceProtocol!
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        statisticService = StatisticServiceImplementation()
        
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader(networkClient: NetworkClient()))
        questionFactory?.loadData()
        viewController.loadingIndicatorIsHidden(false)
    }
    
    // MARK: - Actions
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.loadingIndicatorIsHidden(true)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        
        guard let currentQuestion else { return }
        
        let viewModel = convert(model: currentQuestion)
        
        DispatchQueue.main.async {[weak self] in
            
            self?.viewController?.show(quiz: viewModel)
        }
        
    }
    
    // MARK: - Functions
    
    func proceedWithAnswer(isCorrect: Bool) {
        
        guard let currentQuestion else { return }
        guard let viewController else { return }
        
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
    
    func didAnswer(isYes: Bool) {
        
        guard let viewController else { return }
        
        self.proceedWithAnswer(isCorrect: isYes)
        viewController.enableButtonsAction(false)
        
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func proceedToNextQuestionOrResults() {
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
    
    func makeResultMessage() -> QuizResultsViewModel {
        statisticService.store(correct: correctAnswers, total: self.questionsAmount)
        
        let result = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text:"Ваш результат \(correctAnswers)/\(self.questionsAmount) \n Количество сыгранных квизов \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct) / \(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%" ,
            buttonText: "Сыграть еще раз"
        )
        
        return result
    }
    
}

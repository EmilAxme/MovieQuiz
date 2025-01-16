import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var loadingIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet private weak var yesButtonOutlet: UIButton!
    @IBOutlet private weak var noButtonOutlet: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let presenter = presenter.viewController else { return }
        
        presenter.showAnswerResult(isCorrect: true)
        presenter.enableButtonsAction(false)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let presenter = presenter.viewController else { return }
        
        presenter.showAnswerResult(isCorrect: false)
        presenter.enableButtonsAction(false)
    }

//    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
//    private var currentQuestion: QuizQuestion?
    private var alert: ResultAlertPresenter?
    private var statistics: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
//    private var currentQuestionIndex: Int = .zero
    
    private var correctAnswers: Int = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicatorOutlet.hidesWhenStopped = true
        loadingIndicatorIsHidden(false)
        statistics = StatisticServiceImplementation()
        presenter.viewController = self
        
        alert = ResultAlertPresenter(delegate: self)
        questionFactory = QuestionFactory(delegate: self, moviesLoader:       MoviesLoader(networkClient: NetworkClient()))
        guard let questionFactory else { return }
        
        questionFactory.loadData()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
    }
    
    private func showNetworkError(message: String) {
        
        let errorAlert = AlertModel(
            title: message,
            message: nil,
            buttonText: "Попробуй еще раз",
            
            completion: {[weak self] in
                guard let self else {return}
                guard let factory = self.questionFactory else {return}
//                self.currentQuestionIndex = 0
                presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                factory.requestNextQuestion()
            }
            
        )
        
        guard let alert else { return }
        alert.presentAlert(with: errorAlert)
    }
    
    private func loadingIndicatorIsHidden(_ isHidden: Bool) {
        isHidden ? loadingIndicatorOutlet.stopAnimating() : loadingIndicatorOutlet.startAnimating()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        guard let factory = questionFactory else { return }
        factory.requestNextQuestion()
        loadingIndicatorIsHidden(true)
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        guard let currentQuestion = presenter.currentQuestion else { return }
        
        if isCorrect == currentQuestion.correctAnswer {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        }
        
        else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.enableButtonsAction(true)
        }
        
    }
    
    private func showNextQuestionOrResults() {
        
        if presenter.isLastQuestion() {
            guard let statistics else { return }
            statistics.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text:"Ваш результат \(correctAnswers)/\(presenter.questionsAmount) \n Количество сыгранных квизов \(statistics.gamesCount) \n Рекорд: \(statistics.bestGame.correct) / \(statistics.bestGame.total) (\(statistics.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statistics.totalAccuracy))%" ,
                buttonText: "Сыграть еще раз"
            )
            
            show(quiz: result)
        }
        
        else
        {
            presenter.switchToNextQuestion()
            guard let questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
        
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
    }
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        
//        let questionStep = QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//        
//        imageView.layer.borderColor = UIColor.clear.cgColor
//        return questionStep
//        
//    }
    
    func enableButtonsAction(_ enable: Bool){
        
        if enable {
            noButtonOutlet.isEnabled = true
            yesButtonOutlet.isEnabled = true
        }
        
        else {
            yesButtonOutlet.isEnabled = false
            noButtonOutlet.isEnabled = false
        }
        
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let result  = AlertModel(
            
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                [weak self]  in
                guard let self else { return }
                guard let factory = self.questionFactory else { return }
                self.correctAnswers = 0
                presenter.resetQuestionIndex()
                factory.requestNextQuestion()
            }
        
        )
        
        guard let alert else { return }
        alert.presentAlert(with: result)
    }
    
}

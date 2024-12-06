import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertModelDelegate {
        
    @IBOutlet weak var yesButtonOutlet: UIButton!
    @IBOutlet weak var noButtonOutlet: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: true)
        enableButtonsAction(false)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: false)
        enableButtonsAction(false)
    }

    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alert: ResultAlertPresenter?
    private var statistics: StatisticServiceProtocol?
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statistics = StatisticServiceImplementation()
        alert = ResultAlertPresenter(delegate: self)
        questionFactory = QuestionFactory(delegate: self)
        guard let questionFactory else { return }
        
        questionFactory.requestNextQuestion()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.show(quiz: viewModel)
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        guard let currentQuestion else { return }
        if isCorrect == currentQuestion.correctAnswer {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.enableButtonsAction(true)
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statistics else { return }
            statistics.store(correct: correctAnswers, total: questionsAmount)
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text:"Ваш результат \(correctAnswers)/\(questionsAmount) \n Количество сыгранных квизов \(statistics.gamesCount) \n Рекорд: \(statistics.bestGame.correct) / \(statistics.bestGame.total) (\(statistics.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statistics.totalAccuracy))%" ,
                buttonText: "Сыграть еще раз"
            )
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
            guard let questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        imageView.layer.borderColor = UIColor.clear.cgColor
        return questionStep
    }
    
    private func enableButtonsAction(_ enable: Bool){
        if enable {
            noButtonOutlet.isEnabled = true
            yesButtonOutlet.isEnabled = true
        } else {
            yesButtonOutlet.isEnabled = false
            noButtonOutlet.isEnabled = false
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let result  = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {[weak self]  in
            guard let self else { return }
            guard let factory = self.questionFactory else { return }
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            factory.requestNextQuestion()
})
        guard let alert else { return }
        alert.presentAlert(with: result)
    }
}

import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Outlets and properties
    
    @IBOutlet private weak var loadingIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet private weak var yesButtonOutlet: UIButton!
    @IBOutlet private weak var noButtonOutlet: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    private var alert: ResultAlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.ButtonClicked(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.ButtonClicked(false)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicatorOutlet.hidesWhenStopped = true
        loadingIndicatorIsHidden(false)
        
        presenter = MovieQuizPresenter(viewController: self)
        
        alert = ResultAlertPresenter(delegate: self)
        imageView.layer.cornerRadius = 20
    }
    
    //MARK: - Show functions
    
    func showNetworkError(message: String) {
        
        let errorAlert = AlertModel(
            title: message,
            message: nil,
            buttonText: "Попробуй еще раз",
            
            completion: {[weak self] in
                guard let self else {return}
                presenter.restartGame()
                
                presenter.questionFactory?.requestNextQuestion()
            }
            
        )
        
        guard let alert else { return }
        alert.presentAlert(with: errorAlert)
    }
    
    
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        let result  = AlertModel(
            
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {[weak self]  in
                guard let self else { return }
                
                presenter.restartGame()
            }
        
        )
        
        guard let alert else { return }
        alert.presentAlert(with: result)
    }
    
    //MARK: - Other fu functions
    
    func highLightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.green.cgColor : UIColor.red.cgColor
    }
    
    func loadingIndicatorIsHidden(_ isHidden: Bool) {
        isHidden ? loadingIndicatorOutlet.stopAnimating() : loadingIndicatorOutlet.startAnimating()
    }
    
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
    
}

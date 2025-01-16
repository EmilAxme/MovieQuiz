import UIKit

final class MovieQuizPresenter {
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        imageView.layer.borderColor = UIColor.clear.cgColor
        return questionStep
        
    }
    
}

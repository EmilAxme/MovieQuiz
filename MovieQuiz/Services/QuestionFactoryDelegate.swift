import Foundation
import UIKit

protocol QuestionFactoryDelegate: AnyObject{
    func didReceiveNextQuestion(question: QuizQuestion?)
}

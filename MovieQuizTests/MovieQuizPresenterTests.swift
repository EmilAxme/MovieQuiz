import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func enableButtonsAction(_ enable: Bool) {}
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {}
    func highLightImageBorder(isCorrectAnswer: Bool) {}
    func loadingIndicatorIsHidden(_ isHidden: Bool) {}
    func showNetworkError(message: String) {}
    
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        //Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        //When
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        //Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

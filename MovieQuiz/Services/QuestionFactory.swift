import Foundation

final class QuestionFactory: QuestionFactoryProtocol{
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        
        moviesLoader.loadMovies { [weak self] result in
            
            DispatchQueue.main.async{
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
                
            }
            
        }
        
    }
    
    func requestNextQuestion(){
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            }
            catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            var randNum = Float.random(in: 8...9.9)
            let headsOrTails = Int.random(in: 0...1)
            
            if rating == randNum {
                randNum = headsOrTails == 1 ? randNum + 0.1 : randNum - 0.1
            }
            
            let text = "Рейтинг этого фильма больше чем \(round(randNum * 10) / 10)?"
            
            let correctAnswer = rating > randNum
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
            
        }
        
    }
    
}

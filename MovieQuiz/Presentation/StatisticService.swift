import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correct = storage.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalAnswered.rawValue)
        if gamesCount == 0 {
            return 0
        }
        return Double(correct) / Double(totalQuestions) * 100
    }
    var totalCorrect: Int {
        get {
            storage.integer(forKey: Keys.totalCorrect.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrect.rawValue)
        }
    }
    
    var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalAnswered.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAnswered.rawValue)
        }
    }
    
    
    private enum Keys: String {
        case correct
        case bestGameTotal
        case bestGameDate
        case gamesCount
        case totalCorrect
        case totalAnswered
    }
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalCorrect += count
        totalQuestions += amount
        storage.set(totalCorrect, forKey: Keys.totalCorrect.rawValue)
        storage.set(totalQuestions, forKey: Keys.totalAnswered.rawValue)
        if count > storage.integer(forKey: Keys.correct.rawValue) {
            storage.set(count, forKey: Keys.correct.rawValue)
            storage.set(amount, forKey: Keys.bestGameTotal.rawValue)
            storage.set(Date(), forKey: Keys.bestGameDate.rawValue)
        }
    }
}

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func bestGame(current: GameResult) -> Bool {
        current.correct < correct
    }
}

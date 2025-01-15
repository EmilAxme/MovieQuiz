//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Emil on 12.01.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        let fitsQuestion = app.staticTexts["Question"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondQuestion = app.staticTexts["Question"]
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(fitsQuestion, secondQuestion)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstQuestion = app.staticTexts["Question"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondQuestion = app.staticTexts["Question"]
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstQuestion, secondQuestion)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testAlert() {
        sleep(1)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(2)
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testNewRoundStart() {
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        let index = app.staticTexts["Index"]
        XCTAssertEqual(index.label, "1/10")
    }
}

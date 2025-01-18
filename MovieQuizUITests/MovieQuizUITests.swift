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
        waitForExistence(of: app.staticTexts["Index"])
        sleep(2)
        
        let fitsQuestion = app.staticTexts["Question"]
        let firstPoster = app.images["Poster"]
        waitForExistence(of: firstPoster)
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        
        let secondQuestion = app.staticTexts["Question"]
        let secondPoster = app.images["Poster"]
        waitForExistence(of: secondPoster)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(fitsQuestion, secondQuestion)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        waitForExistence(of: app.staticTexts["Index"])
        sleep(2)
        
        let firstQuestion = app.staticTexts["Question"]
        let firstPoster = app.images["Poster"]
        waitForExistence(of: firstPoster)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        let secondQuestion = app.staticTexts["Question"]
        let secondPoster = app.images["Poster"]
        waitForExistence(of: secondPoster)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstQuestion, secondQuestion)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testAlert() {
        waitForExistence(of: app.staticTexts["Index"])
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            waitForExistence(of: app.images["Poster"])
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        waitForExistence(of: alert)
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testNewRoundStart() {
        waitForExistence(of: app.staticTexts["Index"])
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            waitForExistence(of: app.images["Poster"])
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        waitForExistence(of: app.staticTexts["Index"])
        let index = app.staticTexts["Index"]
        XCTAssertEqual(index.label, "1/10")
    }
    
    func waitForExistence(of element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "\(element) не появился в течение 10 секунд")
        }
}

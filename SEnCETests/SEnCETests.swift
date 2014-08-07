//
//  SEnCETests.swift
//  SEnCETests
//
//  Created by Andreas Kostuch on 04.08.14.
//  Copyright (c) 2014 Andreas Kostuch. All rights reserved.
//

import Cocoa
import XCTest

class SEnCETests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKeyword() {
        let a = SEOKeyword(keyword: "Hundegeschirr", density: 0)
        let seo = SEOContent(content: "<div><p>&nbsp;</></p><p></p><strong>Hundegeschirr</strong> ist nun auch in unserem Repertoire. Unser Anspruch bei <strong>gepolsterten Luxus Hundegeschirr</strong> ist wie immer hoch. Style und  Bequemlichkeit sind für uns die Eckpunkte bei unseren Designs. Alle unsere Produkte sind handgefertigt und mit größter Sorgfalt erstellt. Bei unseren Produkten achten wir auch darauf dass das Hundeschier anlegen nicht zu einer Denksport Aufgabe wird sondern leicht und schnell von Statten geht.</p> <p>Durch unsere sorgfältige Handarbeit können Sie sicher sein dass Ihr <strong>Hundegeschirr individuell</strong> gestaltet wurde und dies wirklich Ihr persönliches Unikat basierend auf unserem Design ist.</p> <p>Wie auch bei unseren anderen Produkten ist unser Luxus Hundegeschirr für kleine Hunde ausgelegt. Wir bieten deswegen auch keine Hundehalsbänder an da wir der Meinung sind dass Hundehalsbänder für kleine Hunde, wie zum Beispiel Chihuahuas, nicht angebracht ist.</p></div>", key)
        XCTAssertTrue(a.keyword == "Hundegeschirr", "")
        seo.keywords = [a]
        seo.countKeywords()
        XCTAssertTrue(a.density==4, "Density has wrong number - maybe regex is bad")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

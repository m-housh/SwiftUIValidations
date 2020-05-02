//
//  ErrorViewModifierTests.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import XCTest
import ViewInspector
import SwiftUI

@testable import ValidatableTextField

final class ErrorViewModifier2Tests: XCTestCase {

    func test_ErrorModifier_should_show_error() throws {
        var sut = ErrorViewModifier(value: .constant(""), shouldEvaluate: .constant(true), validator: !.empty)
        let exp = XCTestExpectation(description: #function)

        sut.didAppear = { body in
            body.inspect { view in
                let errorText = try view.vStack().forEach(1).text(0).string()
                XCTAssertEqual(errorText, "Required")
            }
            ViewHosting.expel()
            exp.fulfill()
        }

        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)

        wait(for: [exp], timeout: 1)

    }

    func test_ErrorModifier_should_not_show_error() throws {
        var sut = ErrorViewModifier(value: .constant("foo"), shouldEvaluate: .constant(true), validator: !.empty)
        let exp = XCTestExpectation(description: #function)

        sut.didAppear = { body in
            body.inspect { view in
                let count = try view.vStack().forEach(1).count
                XCTAssertEqual(count, 0)
            }
            ViewHosting.expel()
            exp.fulfill()
        }

        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)

        wait(for: [exp], timeout: 1)
    }

//    func test_ErrorModifier_ignores_with_no_error_text() throws {
//        var sut = ErrorViewModifier(errors: [String](), value: .constant(""), shouldEvaluate: .constant(true), validate: { _ in return false })
//
//        let exp = XCTestExpectation(description: #function)
//
//        sut.didAppear = { body in
//            body.inspect { view in
//                let count = try view.vStack().forEach(1).count
//                XCTAssertEqual(count, 0)
//            }
//            ViewHosting.expel()
//            exp.fulfill()
//        }
//
//        let view = EmptyView().modifier(sut)
//        ViewHosting.host(view: view)
//
//        wait(for: [exp], timeout: 1)
//    }

    func test_ErrorModifier_with_trailing_closure() throws {
        let sut = ErrorModifierWithTrailingClosure()
        let exp = sut.inspection.inspect { view in
            let text = try view.actualView().text
            XCTAssertEqual(text, "")
        }

        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1)
    }
}

//final class ErrorViewModifierTests: XCTestCase {
//
//    func test_ErrorModifier_should_show_error() throws {
//        var sut = ErrorViewModifier(value: .constant(""), shouldEvaluate: .constant(true), validator: Validators<String>().notEmpty)
//        let exp = XCTestExpectation(description: #function)
//
//        sut.didAppear = { body in
//            body.inspect { view in
//                let errorText = try view.vStack().forEach(1).text(0).string()
//                XCTAssertEqual(errorText, "Required")
//            }
//            ViewHosting.expel()
//            exp.fulfill()
//        }
//
//        let view = EmptyView().modifier(sut)
//        ViewHosting.host(view: view)
//
//        wait(for: [exp], timeout: 1)
//
//    }
//
//    func test_ErrorModifier_should_not_show_error() throws {
//        var sut = ErrorViewModifier(value: .constant("foo"), shouldEvaluate: .constant(true), validator: Validators<String>().notEmpty)
//        let exp = XCTestExpectation(description: #function)
//
//        sut.didAppear = { body in
//            body.inspect { view in
//                let count = try view.vStack().forEach(1).count
//                XCTAssertEqual(count, 0)
//            }
//            ViewHosting.expel()
//            exp.fulfill()
//        }
//
//        let view = EmptyView().modifier(sut)
//        ViewHosting.host(view: view)
//
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_ErrorModifier_ignores_with_no_error_text() throws {
//        var sut = ErrorViewModifier(errors: [String](), value: .constant(""), shouldEvaluate: .constant(true), validate: { _ in return false })
//
//        let exp = XCTestExpectation(description: #function)
//
//        sut.didAppear = { body in
//            body.inspect { view in
//                let count = try view.vStack().forEach(1).count
//                XCTAssertEqual(count, 0)
//            }
//            ViewHosting.expel()
//            exp.fulfill()
//        }
//
//        let view = EmptyView().modifier(sut)
//        ViewHosting.host(view: view)
//
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_ErrorModifier_with_trailing_closure() throws {
//        let sut = ErrorModifierWithTrailingClosure()
//        let exp = sut.inspection.inspect { view in
//            let text = try view.actualView().text
//            XCTAssertEqual(text, "")
//        }
//
//        ViewHosting.host(view: sut)
//        wait(for: [exp], timeout: 1)
//    }
//}

struct ErrorModifierWithTrailingClosure: View, Inspectable {

    @State var text: String = ""

    let inspection = Inspection<Self>()

    var body: some View {
        Text("")
            .errorModifer(value: $text, shouldEvaluate: .constant(true)) {
                !.empty
            }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }

    }
}

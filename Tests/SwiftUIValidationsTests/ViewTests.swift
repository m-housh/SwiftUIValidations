import XCTest
import ViewInspector
import Combine
import SwiftUI
@testable import SwiftUIValidations

final class ValidatableTextFieldTests: XCTestCase {

    func test_TestContentView_text_changes() throws {
        let publisher = PassthroughSubject<String, Never>()
        let sut = ContentView(publisher: publisher)

        let exp1 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().text, "")
            publisher.send("Foo")
        }

        let exp2 = sut.inspection.inspect(after: 0.2) { view in
            XCTAssertEqual(try view.actualView().text, "Foo")
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 1)
    }

    func test_SingleErrorView_displays_only_first_error() throws {
        let sut = SingleErrorViewContent(["foo", "bar"], displaying: .first)
        let text = try sut.inspect().view(SingleErrorView.self).group().text(0).string()
        XCTAssertEqual(text, "Foo")
    }

    func test_SingleErrorView_displays_only_last_error() throws {
        let sut = SingleErrorViewContent(["foo", "bar"], displaying: .last)
        let text = try sut.inspect().view(SingleErrorView.self).group().text(0).string()
        XCTAssertEqual(text, "Bar")
    }

    func test_SingleErrorView_does_not_display_error_with_empty_list() throws {
        let sut = SingleErrorViewContent([], displaying: .first)
        let groupCount = try sut.inspect().view(SingleErrorView.self).group().count
        XCTAssertEqual(groupCount, 0)
    }

    func test_MultiErrorView_displays_multiple_errors() throws {
        let sut = MultiErrorView(["foo", "bar"])
        let forEach = try sut.inspect().forEach()
        XCTAssertEqual(forEach.count, 2)

        let shouldBeFoo = try forEach.text(0).string()
        let shouldBeBar = try forEach.text(1).string()

        XCTAssertEqual(shouldBeFoo, "Foo")
        XCTAssertEqual(shouldBeBar, "Bar")
    }

    func test_String_capitalizedFirstLetter() {
        XCTAssertEqual("foo bar".capitalizedFirstLetter(), "Foo bar")
    }

    static var allTests = [
        ("test_TestContentView_text_changes", test_TestContentView_text_changes)
    ]
}

struct ContentView: View, Inspectable {

    @State var text: String = ""
    internal let inspection = Inspection<Self>()

    let publisher: PassthroughSubject<String, Never>

    var body: some View {
        VStack {
            // Can't test the error modifier because we can't enter the field.
            ValidatingTextField("Name", text: $text, validator: !.empty)

            // Custom error view builder.
            ValidatingTextField("name", text: $text, validator: !.empty) { errors in
                Group {
                    if errors.first != nil {
                        Text(errors.first!)
                    }
                }
            }

            // This should always evaluate.
            TextField("Not Validatable", text: $text)
                .errorModifer(value: $text, validator: !.empty)

            TextField("Not Validatable", text: $text)
                .errorModifer(value: $text) {
                    !.empty && .email
                }

            TextField("Not Validatable", text: $text)
                .errorModifer(value: $text) {
                    !.empty && .email
                }

            TextField("Not Validatable", text: $text)
                .errorModifer(value: $text, validator: !.empty) { errors in
                    ForEach(errors, id: \.self) { error in
                        Text(error)
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }

        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { self.text = $0 }
    }
}

internal final class Inspection<V> where V: View {

    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

extension Inspection: InspectionEmissary where V: Inspectable { }

struct SingleErrorViewContent: View, Inspectable {

    let inspection = Inspection<Self>()
    let errors: [String]
    let display: SingleErrorView.DisplayError

    init(_ errors: [String], displaying display: SingleErrorView.DisplayError) {
        self.errors = errors
        self.display = display
    }

    var body: some View {
        SingleErrorView(errors, displaying: display)
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

extension SingleErrorView: Inspectable { }
extension MultiErrorView: Inspectable { }

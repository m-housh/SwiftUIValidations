import XCTest
import ViewInspector
import Combine
import SwiftUI
@testable import SwiftUIValidations

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

    static var allTests = [
        ("test_TestContentView_text_changes", test_TestContentView_text_changes)
    ]
}

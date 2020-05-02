# ValidatableTextField

![CI](https://github.com/m-housh/ValidatableTextField/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/m-housh/ValidatableTextField/branch/master/graph/badge.svg)](https://codecov.io/gh/m-housh/ValidatableTextField)
![iosBadge](https://img.shields.io/badge/iOS-%3E%3D%2013-orange)
![macBadge](https://img.shields.io/badge/macOS-%3E%3D%2010.15-blue)

A swift package that adds validation to views.


![example](.github/Example.gif)

## Installation
-------------------------
Add to your project using `swift package manager`.


## Usage
----------------

There are 4 main things this package exposes. `Validator`, `Validators`, `ValidatableTextField`, and an `errorModifier` view modifiier.

### ValidatableTextField

The validatable text field is similar to a norma text field however it adds the abilitiy to validate the text value, and display an error message(s) if invalid.  There are two ways to create a validatable text field.

#### Key Path

Use a key path(s) on the `Validators` to derive the validator for the text - field

``` swift

extension Validators where Value == String {
    
    var validEmail: Validator<String> {
        Validator(errorText: "Invalid email address.") { email in
            let regularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let testEmail = NSPredicate(format: "SELF MATCHES %@", regularExpression)
            return testEmail.evaluate(with: email)
        }
    }
}
    
struct ContentView: View {
    
    @State private var nameText: String
    @State private var emailText: String
    
    var body: some View {
        Form {
            ValidatableTextField("Name", text: $nameText, validator: \.notEmpty)
            ValidatableTextField("Email", text: $emailText, validator: \.notEmpty, \.validEmail)
        }
    }
}
```

#### Supplied Validator

You can also provide your own validator.

```swift
struct ContentView: View {
    
    @State private var nameText: String
    private var nameValidator = Validator<String>(errorText: "My custom name error.") { string in 
        // do validation here, return `true` if valid and `false` if invalid.
        return !string.isEmpty
    }
    
    var body: some View {
        Form {
            ValidatableTextField("Name", text: $nameText, validator: nameValidator)
        }
    }
}
```

### errorModifier

The `errorModifier` is an extension on `View` and will add the ability for any view to be validated.  There are several ways to create add an error modifier to a view, below is just one example of using a key path on `Validators` to derive the validation from.

```swift

struct MyValidatableView: View {

    // control when the error is evaluated.
    @State private var shouldEvaluate: Bool = true
    
    @State private var value: String = ""
    
    var body: some View {
        Form {
            // display the error in the section header.
            Section(header: errorView) {
                TextField("Value", text: $value)
            }
        }
    }
    
    private var errorView: some View {
        Text("")
            .errorModifier(value: $value, shouldEvaluate: $shouldEvaluate, validator: \.notEmpty)
    }
}

```

### Validators

The `Validators` is a namespace to extend and add your own `Validator`'s to.   There is one default validator, shown below.

``` swift

/// A namespace for validators to be added to.
public struct Validators<Value> {
    public init() { }
}

/// Add validators for specific binding values.
extension Validators where Value == String {

    public var notEmpty: Validator<String> {
        Validator(errorText: "Required") { (string: String) -> Bool in
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty
        }
    }
}

```

### Validator

`Validator` is a type that can validate a `Binding` value on a view.  

A validator holds the text to be displayed and the validation method.  A validator also has the ability to be combined with other validators, making a chain of error messages that will be displayed, depending on the result.

```swift

let notFoo: Validator<String> = Validator(errorText: "Can not be 'foo'") { string in 
    return string.lowercased() != "foo"
}

/// use the `validate(_:)` method to test a value
let invalidResult = notFoo.validate("foo")
assert(result.isValid == false)
assert(result.errors.first! == "Can not be 'foo'")

let validResult = notFoo.validate("not foo")
assert(result.isValid == true)
assert(result.errors.count == 0)

```

They can be combined to generate multiple messages, depending on result.

```swift

let notEmptyOrFoo = Validators<String>().notEmpty.combined(with: notFoo)

let invalidBecauseEmptyResult = notEmptyOrFoo.validate("")
assert(invalidBecauseEmptyResult.isValid == false)
assert(invalidBecauseEmptyResult.errors.first! == "Required")
assert(invalidBecauseEmptyResult.errors.count == 1)

let invalidBecauseFooResult = notEmptyOrFoo.validate("Foo")
assert(invalidBecauseFooResult.isValid == false)
assert(invalidBecauseFooResult.errors.first! == "Can not be 'foo'")
assert(invalidBecauseFooResult.errors.count == 1)

```

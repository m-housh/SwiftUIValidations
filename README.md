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

The first `Validator` is a type that can validate a `Binding` value on a view.  The second `Validators` is a namespace to extend and add your own `Validator`'s to.   There is one default validator, shown below.

### Validators

``` swift

/// A namespace for validators to be added to.
public struct Validators<T> {
    public init() { }
}

/// Add validators for specific binding values.
extension Validators where T == String {

    public var notEmpty: Validator<String> {
        Validator(errorText: "Required") { (string: String) -> Bool in
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty
        }
    }
}

```

### Validator

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

let notEmptyOrFoo = Validators<String>().notEmpty.combined(with: myValidator)

let invalidBecauseEmptyResult = notEmptyOrFoo.validate("")
assert(invalidBecauseEmptyResult.isValid == false)
assert(invalidBecauseEmptyResult.errors.first! == "Required")
assert(invalidBecauseEmptyResult.errors.count == 1)

let invalidBecauseFooResult = notEmptyOrFoo.validate("Foo")
assert(invalidBecauseFooResult.isValid == false)
assert(invalidBecauseFooResult.errors.first! == "Can not be 'foo'")
assert(invalidBecauseFooResult.errors.count == 1)

```

# SwiftUIValidations

![CI](https://github.com/m-housh/SwiftUIValidations/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/m-housh/SwiftUIValidations/branch/master/graph/badge.svg)](https://codecov.io/gh/m-housh/SwiftUIValidations)
![iosBadge](https://img.shields.io/badge/iOS-%3E%3D%2013-orange)
![macBadge](https://img.shields.io/badge/macOS-%3E%3D%2010.15-blue)

A swift package that adds validation to views.


![example](.github/Example-1.gif)

## Installation
-------------------------
Add to your project using `swift package manager`.

## Basic Usage
--------------------------

There are 3 main things this package exposes. `Validator`, `ValidatingTextField`, and an `errorModifier` view modifiier.

### ValidatingTextField

The validatable text field is similar to a normal text field however it adds the abilitiy to validate the text value, and display an error message(s) if invalid.  There are two ways to create a validatable text field.

You can use a single validator, or combine validators with `&&`, `||`, and `!` operators.

``` swift
    
struct ContentView: View {
    
    @State private var nameText: String
    @State private var emailText: String
    
    var body: some View {
        Form {
        
            // Error texts would be `["Required: not empty", "Required: at least 5 characters"]`
            ValidatingTextField("Name", text: $nameText, validator: .prefix("Required: ", !.empty && .count(5...)))
            
            // Hook in and create custom error view, only showing the first error.
            //
            // Error texts would be `["Required", "invalid email"]`
            ValidatingTextField("Email", text: $emailText, validator: .custom("Required", !.empty) && .email) { errors in 
                Group {
                    // Only show the first error.
                    if errors.first != nil {
                        Text(errors.first!.capitalized)
                            .modifier(ErrorTextModifier()) 
                            // add default style, font = .callout, foregroundColor = .red
                    }
                }
            }
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
            .errorModifier(value: $value, shouldEvaluate: $shouldEvaluate, validator: !.empty)
    }
    
    // You can also hook into and customize the error view used.
    private var errorView2: some View {
        Text("")
            .errorModifier(value: $value, shouldEvaluate: $shouldEvaluate, validator: !.empty) { errors in  
                Group {
                    // Only show the first error.
                    if errors.first != nil {
                        Text($0)
                            .modifier(ErrorTextModifier())
                    }
                }
            }
    }
}

```

### Validator

`Validator` is a type that can validate a `Binding` value on a view.  

A validator holds the text to be displayed and the validation method.  A validator also has the ability to be combined with other validators, making a chain of error messages that will be displayed, depending on the result.

The default validator error messages are generic (and lowercased), as they expect to have a `prefix` or `custom` wrapper around
them.

``` swift

/// Set a custom error, this will replace all errors with the custom error,
/// so should typically just be used to wrap a single validator.
let notEmpty: Validator<String> = .custom("Required", !.empty)

do {
    try notEmpty.validate("")
} catch validationError as ValidationError {
    assert(validationError.first! == "Required")
}

/// Set an error prefix, this will prefix all errors with the custom error prefix,
/// so should typically just be used to wrap a single validator.
let prefixedNotEmpty: Validator<String> = .prefix("Required: ", !.empty)

do {
    try prefixedNotEmpty.validate("")
} catch validationError as ValidationError {
    assert(validationError.first! == "Required: not empty")
}

```

Validators can be combined with the following operators `&&`, `||`, and `!` .

-   `&&`:  Combine two validators together using `AND`
-   `||`:  Combine two validators together using `OR`
-   `!`:  Use the inverse of a validator using `NOT`

## Documentation
-------------------------------

See the [Documentation](https://m-housh.github.io/SwiftUIValidations) for available validators.

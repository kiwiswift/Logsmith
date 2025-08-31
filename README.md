# Logsmith

Ergonomic, zero-boilerplate logging for Swift types via a Swift macro.

Logsmith provides a type-attached macro, `@Loggable`, that injects a preconfigured `Logger` and convenience logging methods into your classes, structs, enums, and actors. It uses Apple’s unified logging (os.Logger) under the hood and works across Apple platforms.

[![Swift 6.1](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://www.swift.org)
![Platforms iOS | macOS | tvOS | watchOS | Mac Catalyst](https://img.shields.io/badge/platforms-iOS%2015%2B%20%7C%20macOS%2013%2B%20%7C%20tvOS%2013%2B%20%7C%20watchOS%206%2B%20%7C%20Mac%20Catalyst%2013%2B-blue)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)
<!-- Optional: Uncomment after adding to Swift Package Index
[![SPI Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FYOUR_ORG_OR_USER%2FLogsmith%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/YOUR_ORG_OR_USER/Logsmith)
[![SPI Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FYOUR_ORG_OR_USER%2FLogsmith%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/YOUR_ORG_OR_USER/Logsmith)
-->
<!-- Optional: CI badge (replace workflow name and org/user)
[![Build](https://github.com/YOUR_ORG_OR_USER/Logsmith/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_ORG_OR_USER/Logsmith/actions/workflows/ci.yml)
-->

## Table of contents
- Features
- Requirements
- Installation
- Usage
  - What gets generated
  - Customization
  - Supported declarations
- Example executable
- Development
  - Building
  - Running tests
- Contributing
- Getting started
- Code of Conduct
- License

## Features

- Simple: Add `@Loggable` to a type to get a ready-to-use `Logger`.
- Configurable:
  - Category defaults to the annotated type’s name (e.g., “Example”, “Worker”, “Inner”, “Box”).
  - Subsystem defaults to `Bundle.main.bundleIdentifier` (with a fallback of `com.unknown.app`).
  - Customize category, subsystem, and the injected property name.
  - Optionally generate only a static logger (no instance property).
- Convenient helpers:
  - Injected methods for common levels: debug, info, error, warning, verbose, critical, and general log.
  - Emoji-prefixed output for fast visual scanning in logs.
- Works with classes, structs, enums, and actors (protocols and unnamed extensions are not supported).
- Thoroughly tested with macro snapshot tests.

## Requirements

- Swift 6.1 toolchain
- Xcode 15 or later recommended
- Platforms:
  - macOS 13+
  - iOS 15+
  - tvOS 13+
  - watchOS 6+
  - Mac Catalyst 13+

Note: Macro plugins build on macOS, so use a recent macOS version to match plugin requirements.

## Installation

Using Swift Package Manager, add Logsmith to your dependencies.

Option A: Xcode
- File > Add Packages…
- Enter repository URL: https://github.com/YOUR_ORG_OR_USER/Logsmith
- Add the “Logsmith” library to your target.

Option B: Package.swift
```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/YOUR_ORG_OR_USER/Logsmith.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Logsmith", package: "Logsmith")
        ]
    )
]
```

## Usage

### What gets generated

When you annotate a type with `@Loggable`, Logsmith generates a preconfigured `Logger` instance and a set of convenient logging methods attached to that type. By default, it injects:

- An instance property `logger` of type `Logger`.
- A static property `logger` of type `Logger`.
- Convenience methods for logging at various levels: `debug()`, `info()`, `error()`, `warning()`, `verbose()`, `critical()`, and a general `log()` method.

The logger is configured with a category matching the type name and a subsystem derived from your app’s bundle identifier.

### Customization

You can customize the generated logger by specifying parameters in the `@Loggable` macro:

```swift
@Loggable(category: "MyCategory", subsystem: "com.example.myapp", propertyName: "myLogger", staticOnly: true)
struct Example {
    // Your code here
}
```

- `category`: Sets the category for the logger (defaults to the type name).
- `subsystem`: Sets the subsystem string (defaults to `Bundle.main.bundleIdentifier` or `com.unknown.app`).
- `propertyName`: Changes the name of the injected logger property (defaults to `logger`).
- `staticOnly`: If true, only a static logger is generated; no instance property or methods are injected.

### Supported declarations

Logsmith supports the following Swift declarations:

- Classes
- Structs
- Enums
- Actors

Protocols and unnamed extensions are not supported.

### Example

```swift
import Logsmith

@Loggable
struct Worker {
    func doWork() {
        info("Starting work...") // Logs with info level and emoji prefix
        debug("Detailed debug info")
        error("An error occurred!")
    }
}

let worker = Worker()
worker.doWork()

// Static logging
Worker.logger.warning("Static warning message")
```

## Example executable

A sample executable demonstrating Logsmith usage is included in the repository under the `Example` target. It showcases:

- Applying `@Loggable` to various types.
- Using the generated logging methods.
- Customizing logger properties.

To run the example:

```bash
swift run Example
```

## Development

### Building

To build the Logsmith package:

```bash
swift build
```

### Running tests

Run the full test suite, including macro snapshot tests, with:

```bash
swift test
```

# Contributing to Logsmith

Thanks for your interest in contributing!

## Ways to contribute
- Report bugs and request features via GitHub Issues.
- Improve documentation (README, examples, comments).
- Add tests for uncovered cases.
- Implement enhancements with focused PRs.

## Getting started
1. Fork the repo and create your branch from `main`.
2. Ensure you have Swift 6.1+ and Xcode 15+.
3. Build and test:
   ```bash
   swift build
   swift test
    ```
#License

## MIT License

Copyright (c) 2025 kiwiSwift

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

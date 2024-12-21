# CardliftKit SDK

The **CardliftKit SDK** is a comprehensive framework designed to simplify form data management, validation, and secure storage for apps and Safari web extensions. With a single entry point for all functionalities, developers can easily integrate the SDK into their codebase.

---

## Features

-   **Shared Data Configuration**: Store and retrieve sensitive card metadata securely using a shared App Group.
-   **Web Extension Handlers**: Enable Safari web extensions to communicate with the main app effortlessly.
-   **Form Data Validation**: Validate user input for correctness and completeness.
-   **Metadata Parsing**: Compute `CardMetaData` from user-provided form data.

---

## Table of Contents

0. [Adding a Safari Extension Target](#0-adding-a-safari-extension-target)
1. [Integration Steps](#integration-steps)
2. [Why App Groups Are Important](#why-app-groups-are-important)
3. [Public API Overview](#public-api-overview)
4. [Validation and Parsing](#validation-and-parsing)
5. [Example Usage](#example-usage)

---

## Integration Steps

To integrate `CardliftKit` into your project, follow these steps:

### 0. Adding a Safari Extension Target

You will need to have a Safari Web Extension target added to your iOS project to use the Card Lift iOS SDK. You can do so using the following steps:

1. **Create a New Safari Web Extension Target**:

    - In Xcode, go to **File > New > Target**.
    - Select **Safari Web Extension** from the list of available targets.
    - Click **Next** and configure the target:
        - Provide a **Product Name** (e.g., `MyAppExtension`).
        - Ensure the **Team** and **Bundle Identifier** match your app.
        - Click **Finish**.

2. **Enable App Groups for the Extension**:

    - Select your new Safari web extension target in the **Project Navigator**.
    - Go to the **Signing & Capabilities** tab.
    - Add the **App Groups** capability.
    - Select the same App Group (e.g., `group.com.mycompany.myapp`) that you configured for the main app.

3. **Modify the Principal Class**:

    - Open the extension’s `Info.plist` file.
    - Locate the `NSExtensionPrincipalClass` key.
    - Set the value to your handler class, typically `$(PRODUCT_MODULE_NAME).SafariWebExtensionHandler`.

4. **Set Up the Web Extension Handler**:

    - Replace the default `SafariWebExtensionHandler.swift` with the following:

        ```swift
        import CardliftKit
        import SafariServices

        class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
            private let router = WebExtensionMessageRouter()

            override init() {
                super.init()
                // Register CardliftKit handlers
                CardliftKit.setup(router: router)
            }

            func beginRequest(with context: NSExtensionContext) {
                guard let request = context.inputItems.first as? NSExtensionItem,
                      let message = request.userInfo?[SFExtensionMessageKey] as? [String: Any],
                      let name = message["name"] as? String else {
                    context.completeRequest(returningItems: nil)
                    return
                }

                let data = message["data"] ?? [String: Any]()
                router.handleMessage(name: name, data: data) { response in
                    let responseItem = NSExtensionItem()
                    responseItem.userInfo = [SFExtensionMessageKey: response]
                    context.completeRequest(returningItems: [responseItem])
                }
            }
        }
        ```

5. **Build and Run**:
    - Build your project to ensure the Safari web extension target is correctly configured.
    - Run the app, and verify that the extension is listed under **Safari > Preferences > Extensions**.

This setup enables seamless communication between your Safari web extension and the main app using `CardliftKit`.

### 1. Install the Package

Use Swift Package Manager (SPM) to add `CardliftKit` to your project:

1. Open Xcode.
2. Go to **File > Add Packages**.
3. Enter the Git repository URL for `CardliftKit`.
4. Select the target(s) where you want to add the package.

### 2. Configure App Groups

1. In your Xcode project, go to your app's **Signing & Capabilities** tab.
2. Add a new capability for **App Groups**.
3. Create or select an App Group (e.g., `group.com.mycompany.myapp`).
4. Ensure the same App Group is added to both the **main app** and **Safari web extension** targets.

### 3. Configure `CardliftKit`

Call `CardliftKit.configure` at app launch (e.g., in `@main` or `AppDelegate`):

```swift
import CardliftKit

@main
struct MyApp: App {
    init() {
        CardliftKit.configure(sharedDataGroupIdentifier: "group.com.mycompany.myapp")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## Why App Groups Are Important

App Groups enable secure data sharing between the main app and extension targets. `CardliftKit` uses App Groups to:

-   Store card metadata securely in a shared container (`UserDefaults`).
-   Allow the Safari web extension to access this metadata.

Without configuring App Groups, your app and extension won’t be able to share data, breaking the integration.

---

## Public API Overview

### 1. Configuration

```swift
CardliftKit.configure(sharedDataGroupIdentifier: String)
```

Sets the shared App Group for storing and retrieving card metadata.

### 2. Web Extension Setup

```swift
CardliftKit.setup(router: WebExtensionMessageRouter)
```

Registers message handlers for Safari web extensions.

### 3. Card Metadata Access

```swift
CardliftKit.saveCardMetaData(_ metaData: CardMetaData)
CardliftKit.getCardMetaData() -> CardMetaData?
CardliftKit.clearCardMetaData()
```

-   **`saveCardMetaData`**: Saves metadata to the shared storage.
-   **`getCardMetaData`**: Retrieves saved metadata, if any.
-   **`clearCardMetaData`**: Clears the stored metadata.

### 4. Validation

```swift
CardliftKit.validateAllFields(_ formData: CardliftCardFormData) -> [String: String]
CardliftKit.validateField(_ field: String, in formData: CardliftCardFormData, errors: inout [String: String])
```

-   **`validateAllFields`**: Validates all fields in `CardliftCardFormData` and returns errors.
-   **`validateField`**: Validates a single field and updates an errors dictionary.

### 5. Metadata Parsing

```swift
CardliftKit.computeCardMetaData(from formData: CardliftCardFormData) -> CardMetaData?
```

Parses and computes `CardMetaData` from the provided form data.

---

## Validation and Parsing

### Validation

Use `validateAllFields` to validate the entire form at once:

```swift
let errors = CardliftKit.validateAllFields(formData)
if errors.isEmpty {
    print("All fields are valid.")
} else {
    print("Validation errors:", errors)
}
```

Or validate individual fields as they change:

```swift
CardliftKit.validateField("firstName", in: formData, errors: &errors)
```

### Metadata Parsing

Parse user-provided form data into `CardMetaData`:

```swift
if let metaData = CardliftKit.computeCardMetaData(from: formData) {
    print("Computed CardMetaData:", metaData)
    CardliftKit.saveCardMetaData(metaData)
} else {
    print("Invalid form data. Unable to compute metadata.")
}
```

---

## Example Usage

### App Setup

```swift
import CardliftKit

@main
struct MyApp: App {
    init() {
        CardliftKit.configure(sharedDataGroupIdentifier: "group.com.mycompany.myapp")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Validating Form Data

```swift
var formData = CardliftCardFormData()
formData.firstName = "John"
formData.lastName = "Doe"

let errors = CardliftKit.validateAllFields(formData)
if errors.isEmpty {
    print("All fields are valid.")
} else {
    print("Validation errors:", errors)
}
```

### Computing and Saving Metadata

```swift
if let metaData = CardliftKit.computeCardMetaData(from: formData) {
    CardliftKit.saveCardMetaData(metaData)
    print("Metadata saved successfully.")
}
```

### Clearing Metadata

```swift
CardliftKit.clearCardMetaData()
```

### Web Extension Integration

In your Safari web extension target:

```swift
import CardliftKit
import Foundation
import SafariServices

// That’s it!
// This minimal file is all you need to maintain in your target.
final class SafariWebExtensionHandler: CardliftWebExtensionHandler {}

// The extension Info.plist typically references "$(PRODUCT_MODULE_NAME).SafariWebExtensionHandler"
// as the NSExtensionPrincipalClass, so this extension will be recognized.

```

---

# CardliftKit SDK

The **CardliftKit SDK** is a comprehensive framework designed to simplify form data management, validation, and secure storage for apps and Safari web extensions. With a single entry point for all functionalities, developers can easily integrate the SDK into their codebase.

---

## Features

- **Secure Storage**: Store and retrieve sensitive card metadata securely using iOS Keychain
- **Web Extension Handlers**: Enable Safari web extensions to communicate with the main app effortlessly
- **Form Data Validation**: Validate user input for correctness and completeness
- **Metadata Parsing**: Compute `CardMetaData` from user-provided form data with comprehensive field support

---

## Table of Contents

1. [Integration Steps](#integration-steps)
2. [Security & Data Storage](#security--data-storage)
3. [Public API Overview](#public-api-overview)
4. [Card Data Models](#card-data-models)
5. [Validation and Parsing](#validation-and-parsing)
6. [Example Usage](#example-usage)
7. [Troubleshooting](#troubleshooting)
8. [Requirements](#requirements)
9. [License](#license)

---

## Integration Steps

### 1. **Create a New Safari Web Extension Target**:

- In Xcode, go to **File > New > Target**
- Select **Safari Web Extension** from the list of available targets
- Click **Next** and configure the target:
  - Provide a **Product Name** (e.g., `MyAppExtension`)
  - Ensure the **Team** and **Bundle Identifier** match your app
  - Click **Finish**

### 2. Install the Package

Add CardliftKit to your project using CocoaPods:

1. If you haven't already, install CocoaPods:

   ```bash
   sudo gem install cocoapods
   ```

2. Create a Podfile in your project directory if you don't have one:

   ```bash
   pod init
   ```

3. Add CardliftKit to your Podfile:

   ```ruby
   target 'YourApp' do
      pod 'CardliftKit', :git => 'https://github.com/augmentinc/CardliftKit.git', :branch => 'main'
   end

   target 'YourAppExtension' do
     pod 'CardliftKit', :git => 'https://github.com/augmentinc/CardliftKit.git', :branch => 'main'
   end
   ```

4. Install the dependencies:

   ```bash
   pod install
   ```

5. Open the `.xcworkspace` file that CocoaPods created (not the `.xcodeproj`).

### 3. Configure Keychain Sharing

1. In your Xcode project, select your app target
2. Go to the **Signing & Capabilities** tab
3. Add a new capability for **Keychain Sharing**
4. Create or select an Keychain Groups (e.g., `com.mycompany.myapp.keychain`)
5. Ensure the same Keychain Group is added to both the **main app** and **Safari web extension** targets

### 4. Enable Background Modes for PiP

1. In your Xcode project, select your app target
2. Go to the **Signing & Capabilities** tab
3. Add a new capability for **Background Modes**
4. Check the option for **Audio, AirPlay, and Picture in Picture**

This enables Picture-in-Picture (PiP) support for video playback in your app.

### 5. Configure CardliftKit

1. In you App's entry file, `@main`

**UIKit**

```swift
//AppDelegate.swift

import UIKit
import CardliftKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CardliftKit.configure(serviceIdentifier: "com.augument.chime.keychain")
        ....
    }

}
```

**SwiftUI**

```swift
import SwiftUI
import CardliftKit

@main
struct CardLiftApp: App {

    init () {
        CardliftKit.configure(serviceIdentifier: "keychain.co.cardlift.demo.CardLift")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 6. Enable Extension Prompt

CardliftKit comes with beautiful enable extension prompt / overlay

```swift
import SwiftUI
import CardliftKit

struct ContentView: View {
    @State var showInstallPrompt: Bool = false

    var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .padding()
        .overlay {
            CardliftKit.InstallPrompt(slug: "your-slug")($showInstallPrompt)
        }
    }
}
```

### 7. Safari Extension Build Files

`extension-build-<version>.zip` file containing the necessary Safari extension files. Follow these steps to add them to your project:

1. **Extract Build Files**:

   - Unzip the `extension-build-<version>.zip` file
   - You'll see the following structure:
     ```
     extension-build/
     ├── manifest.json
     ├── background.js
     ├── content.js
     ├── _locales/
     └── images/
     ... // other files
     ```

2. **Add to Your Extension**:

   - In Xcode, locate your Safari Extension target
   - Find the `Resources` folder in your extension target
   - Drag and drop all files from `extension-build/` into the `Resources` folder
   - When prompted, ensure:
     - [x] "Copy items if needed" is checked
     - [x] Your extension target is selected
     - [x] "Create groups" is selected

3. **Verify Structure**:
   After adding, your extension's Resources folder should look like this:

   ```
   YourAppExtension/
   └── Resources/
       ├── manifest.json       // From extension-build
       ├── background.js      // From extension-build
       ├── content.js         // From extension-build
       ├── _locales/         // From extension-build
       └── images/           // From extension-build
       ... // other files    // From extension-build
   ```

4. **Build and Run**:
   - Clean (Cmd + Shift + K) and build (Cmd + B) your project
   - The extension should now be ready to use

> **Note**: Do not modify the provided build files unless instructed, as they are specifically configured to work with CardliftKit.

---

## Security & Data Storage

CardliftKit uses iOS Keychain for secure storage:

- **Encrypted Storage**: All sensitive card data is encrypted in the Keychain
- **Access Control**: Only authorized app components can access the data
- **Keychain Sharing**: Keychain items are scoped to your app group
- **Automatic Data Protection**: Leverages iOS's built-in Keychain security

---

## Card Data Models

### CardMetaData

The SDK provides a comprehensive `CardMetaData` model that includes:

- Card Details:

  - `cardNumber`
  - `cardExpirationDate` (multiple formats)
  - `cardCvc`
  - `cardType`

- Personal Information:

  - `firstName`, `lastName`, `name`, `title`
  - `email`, `phone`
  - `nickname`

- Address Information:
  - `address`, `address2`
  - `city`, `state`, `stateFull`
  - `country`, `countryFull`
  - `zip`

### Supported Card Types

```swift
public enum CardType: String {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case american = "AMERICAN"
    case discover = "DISCOVER"
}
```

---

## Public API Overview

### 1. Configuration

```swift
CardliftKit.configure(serviceIdentifier: String)
```

### 2. Web Extension Setup

```swift
CardliftKit.setup(router: WebExtensionMessageRouter)
```

### 3. Card Metadata Management

```swift
// Save metadata
CardliftKit.saveCardMetaData(_ metaData: CardMetaData)

// Retrieve metadata
let metadata = CardliftKit.getCardMetaData()

// Clear metadata
CardliftKit.clearCardMetaData()
```

### 4. Validation

```swift
// Validate all fields
let errors = CardliftKit.validateAllFields(formData)

// Validate specific field
CardliftKit.validateField("fieldName", in: formData, errors: &errors)
```

### 5. Upsell / Enable Prompt

```swift
CardliftKit.InstallPrompt(slug: String, config: UpsellButtonConfig)
```

---

## Example Usage

### App Setup

```swift
import CardliftKit

@main
struct MyApp: App {
    init() {
        CardliftKit.configure(serviceIdentifier: "com.mycompany.myapp.keychain")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Safari Web Extension Setup

```swift
import CardliftKit
import SafariServices

// That’s it!
// This minimal file is all you need to maintain in your target.
final class SafariWebExtensionHandler: CardliftWebExtensionHandler {
    override init() {
        super.init()
        CardliftKit.configure(serviceIdentifier: "com.mycompany.myapp.keychain")
    }
}
// The extension Info.plist typically references "$(PRODUCT_MODULE_NAME).SafariWebExtensionHandler"
// as the NSExtensionPrincipalClass, so this extension will be recognized.
```

### Form Validation

```swift
var formData = CardliftCardFormData()
formData.firstName = "John"
formData.lastName = "Doe"
formData.cardNumber = "4111111111111111"
formData.expiry = "12/25"
formData.cvv = "123"

let errors = CardliftKit.validateAllFields(formData)
if errors.isEmpty {
    if let metaData = CardliftKit.computeCardMetaData(from: formData) {
        CardliftKit.saveCardMetaData(metaData)
    }
}
```

### **Promt User to Enable the Extension**

You can prompt user to enable the safari extension

```swift
CardliftKit.InstallPrompt(
    slug: "heb",
    config: UpsellButtonConfig(
        backgroundColor: Color.black,
        foregroundColor: Color.white
    )
)
```

---

## Troubleshooting

### Build Error with Script Sandboxing

If you encounter this error:

```
Sandbox: rsync.samba(xxxxx) deny(1) file-write-create /Users/.../DerivedData/.../Build/Products/Debug-iphonesimulator/[AppName].app/Frameworks/CardliftKit.framework/...
```

**Solution:**

1. In Xcode, select your project in the navigator
2. Go to **Build Settings**
3. Search for "User Script Sandboxing"
4. Set its value to **No**

---

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

---

## License

CardliftKit is available under the MIT license. See the LICENSE file for more info.

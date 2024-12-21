//
//  CardliftWebExtensionHandler.swift
//  CardliftKit
//
//  Created by Sriram Hariharan on 12/20/24.
//

import Foundation
import SafariServices

/// A handler class for managing web extension requests in the Cardlift application.
///
/// This class conforms to the `NSExtensionRequestHandling` protocol and is responsible for
/// processing requests from web extensions.
///
/// - Note: This class is open, allowing it to be subclassed outside of the module.
open class CardliftWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    private let router: WebExtensionMessageRouter

    override public init() {
        // 1. Create the router
        router = WebExtensionMessageRouter()
        super.init()
        // 2. Setup your message handlers
        CardliftKit.setup(router: router)
    }

    public func beginRequest(with context: NSExtensionContext) {
        // Standard Safari Extension flow
        guard let request = context.inputItems.first as? NSExtensionItem,
            let message = request.userInfo?[SFExtensionMessageKey] as? [String: Any],
            let name = message["name"] as? String
        else {
            return sendResponse(
                ["type": "error", "data": "invalid message format"], context: context)
        }

        let data = message["data"] ?? [String: Any]()

        // Use the router to handle the message
        router.handleMessage(name: name, data: data) { response in
            self.sendResponse(
                response as? [String: Any] ?? ["type": "error", "data": "unexpected error"],
                context: context
            )
        }
    }

    // Helper to send a response back to Safari
    private func sendResponse(_ response: [String: Any], context: NSExtensionContext) {
        let responseItem = NSExtensionItem()
        responseItem.userInfo = [SFExtensionMessageKey: response]
        context.completeRequest(returningItems: [responseItem])
    }
}

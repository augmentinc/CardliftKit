import Foundation
import os.log

// Protocol for typed message handlers
public protocol MessageHandler {
    /**
      The Data that is being sent from the web extension to this native iOS app. This data will be Serialized
     */
    associatedtype MessageData: Codable
    /**
      The Data that is being sent back to the web extension as a response to this specific message. Will be Serialized.
     */
    associatedtype MessageResponse: Codable

    /**
      The name of the message (i.e on the web extension side this is being called as `native.[MESSAGE_NAME]()`
     */
    static var name: String { get }

    /**
     This is the actual handler function, do all of your message handling work here!
     */
    func handle(data: MessageData) throws -> MessageResponse
}

// Extension for serializing Codable types into dictionaries
extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}

// Extension for decoding dictionaries into Codable types
extension Decodable {
    static func fromDictionary(_ dictionary: [String: Any]) -> Self? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
              let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        return decoded
    }
}

public class WebExtensionMessageRouter {
    private var handlers: [String: (Any) throws -> Any] = [:]

    public func registerHandler<H: MessageHandler>(_ handler: H) {
        handlers[H.name] = { rawData in
            guard let dictionary = rawData as? [String: Any],
                  let typedData = H.MessageData.fromDictionary(dictionary)
            else {
                return ["type": "error", "data": "invalid data (could not be encoded)"]
            }
            return try handler.handle(data: typedData).toDictionary() as Any
        }
    }

    public func handleMessage(name: String, data: Any, sendResponse: @escaping (Any) -> Void) {
        guard let handler = handlers[name] else {
            return sendResponse(["type": "error", "data": "name: \(name) not found"])
        }

        do {
            let response = try handler(data)
            sendResponse(response)
        } catch {
            sendResponse(["type": "error", "data": error.localizedDescription])
        }
    }
}

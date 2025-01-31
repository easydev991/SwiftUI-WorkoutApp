import Foundation

/// Делает `body` для запроса
public enum BodyMaker {
    public struct Parameter<T: Hashable & RawRepresentable> where T.RawValue == String {
        let key: String
        let value: String

        public init(from element: Dictionary<T, String>.Element) {
            self.key = element.key.rawValue
            self.value = element.value
        }

        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    /// Делает `body` из словаря
    public static func makeBody(
        with parameters: [Parameter<some Hashable & RawRepresentable>]
    ) -> Data? {
        parameters.isEmpty
            ? nil
            : parameters
                .map { $0.key + "=" + $0.value }
                .joined(separator: "&")
                .data(using: .utf8)
    }

    /// Делает `body` из словаря и медиа-файлов
    public static func makeBodyWithMultipartForm(
        with parameters: [Parameter<some Hashable & RawRepresentable>],
        and media: [MediaFile]?
    ) -> Data? {
        let boundary = "FFF"
        let lineBreak = "\r\n"
        var body = Data()
        if !parameters.isEmpty {
            parameters.forEach { element in
                body.append("--\(boundary)\(lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(element.key)\"\(lineBreak + lineBreak)")
                body.append("\(element.value)\(lineBreak)")
            }
        }
        if let media, !media.isEmpty {
            media.forEach { photo in
                body.append("--\(boundary)\(lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType)\(lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        if !body.isEmpty {
            body.append("--\(boundary)--\(lineBreak)")
            return body
        } else {
            return nil
        }
    }

    /// Медиа-файл для отправки на сервер
    public struct MediaFile: Codable, Equatable, Sendable {
        public let key: String
        public let filename: String
        public let data: Data
        public let mimeType: String

        public init(key: String, filename: String, data: Data, mimeType: String) {
            self.key = key
            self.filename = filename
            self.data = data
            self.mimeType = mimeType
        }
    }
}

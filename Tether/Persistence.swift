import Foundation

/// Tiny JSON file store in Application Support. Everything stays on-device.
enum Store {
    static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory,
                                            in: .userDomainMask).first!
        let dir = base.appendingPathComponent("com.rtmalikian.tether", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func load<T: Codable>(_ name: String, default defaultValue: T) -> T {
        let url = directory.appendingPathComponent("\(name).json")
        guard let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(T.self, from: data)
        else { return defaultValue }
        return value
    }

    static func save<T: Codable>(_ value: T, as name: String) {
        let url = directory.appendingPathComponent("\(name).json")
        if let data = try? JSONEncoder().encode(value) {
            try? data.write(to: url, options: .atomic)
        }
    }

    static func deleteAll() {
        try? FileManager.default.removeItem(at: directory)
    }
}

import Foundation

struct Recording: Identifiable, Codable {
    let id = UUID()
    let name: String
    let date: Date
    let duration: TimeInterval
    let filePath: String
    let fileSize: Int64
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}
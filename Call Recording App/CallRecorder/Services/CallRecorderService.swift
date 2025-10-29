import Foundation
import AVFoundation
import CallKit

class CallRecorderService: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let callObserver = CXCallObserver()
    
    @Published var isRecording = false
    @Published var recordings: [Recording] = []
    @Published var storageLocation: String = "Local Storage"
    
    private var iCloudDocumentsURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    override init() {
        super.init()
        setupCallObserver()
    }
    
    func requestPermissions() {
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Microphone permission granted")
            } else {
                print("Microphone permission denied")
            }
        }
    }
    
    private func setupCallObserver() {
        callObserver.setDelegate(self, queue: nil)
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let storageURL = getStorageURL()
            let audioFilename = storageURL.appendingPathComponent("recording_\(Date().timeIntervalSince1970).mp3")
            
            // Create directory if it doesn't exist
            try FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEGLayer3),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let url = audioRecorder?.url {
            saveRecording(url: url)
        }
    }
    
    private func saveRecording(url: URL) {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            
            let asset = AVURLAsset(url: url)
            let duration = CMTimeGetSeconds(asset.duration)
            
            let recording = Recording(
                name: "Call Recording \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))",
                date: Date(),
                duration: duration,
                filePath: url.path,
                fileSize: fileSize
            )
            
            recordings.append(recording)
            saveRecordingsToUserDefaults()
            
        } catch {
            print("Error saving recording: \(error)")
        }
    }
    
    func getRecordings() -> [Recording] {
        loadRecordingsFromUserDefaults()
        syncWithiCloud()
        return recordings
    }
    
    private func getStorageURL() -> URL {
        // Try iCloud first, fallback to local storage
        if let iCloudURL = iCloudDocumentsURL {
            DispatchQueue.main.async {
                self.storageLocation = "iCloud Drive"
            }
            return iCloudURL.appendingPathComponent("CallRecordings")
        } else {
            DispatchQueue.main.async {
                self.storageLocation = "Local Storage"
            }
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return localURL.appendingPathComponent("CallRecordings")
        }
    }
    
    private func syncWithiCloud() {
        guard let iCloudURL = iCloudDocumentsURL else { return }
        
        do {
            let recordingsPath = iCloudURL.appendingPathComponent("CallRecordings")
            let files = try FileManager.default.contentsOfDirectory(at: recordingsPath, includingPropertiesForKeys: nil)
            
            for file in files where file.pathExtension == "mp3" {
                // Start downloading if not already local
                try FileManager.default.startDownloadingUbiquitousItem(at: file)
            }
        } catch {
            print("iCloud sync error: \(error)")
        }
    }
    
    func deleteRecording(_ recording: Recording) {
        // Remove file
        try? FileManager.default.removeItem(atPath: recording.filePath)
        
        // Remove from array
        recordings.removeAll { $0.id == recording.id }
        saveRecordingsToUserDefaults()
    }
    
    func playRecording(_ recording: Recording) {
        let url = URL(fileURLWithPath: recording.filePath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing recording: \(error)")
        }
    }
    
    private func saveRecordingsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(encoded, forKey: "SavedRecordings")
        }
    }
    
    private func loadRecordingsFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "SavedRecordings"),
           let decoded = try? JSONDecoder().decode([Recording].self, from: data) {
            recordings = decoded
        }
    }
}

// MARK: - CXCallObserverDelegate
extension CallRecorderService: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected && !call.hasEnded {
            // Call started - automatically start recording
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startRecording()
            }
        } else if call.hasEnded {
            // Call ended - stop recording
            if isRecording {
                stopRecording()
            }
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension CallRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
        }
    }
}
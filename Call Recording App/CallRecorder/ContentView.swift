import SwiftUI
import AVFoundation
import CallKit

struct ContentView: View {
    @StateObject private var callRecorder = CallRecorderService()
    @State private var recordings: [Recording] = []
    @State private var isRecording = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Recording Status
                VStack {
                    Circle()
                        .fill(isRecording ? Color.red : Color.gray)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                        .onTapGesture {
                            toggleRecording()
                        }
                    
                    Text(isRecording ? "Recording..." : "Tap to Record")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Text(callRecorder.storageLocation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recordings List
                List {
                    ForEach(recordings) { recording in
                        RecordingRow(recording: recording)
                    }
                    .onDelete(perform: deleteRecording)
                }
                .refreshable {
                    loadRecordings()
                }
            }
            .navigationTitle("Call Recorder")
            .onAppear {
                setupPermissions()
                loadRecordings()
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            callRecorder.stopRecording()
            isRecording = false
        } else {
            callRecorder.startRecording()
            isRecording = true
        }
    }
    
    private func setupPermissions() {
        callRecorder.requestPermissions()
    }
    
    private func loadRecordings() {
        recordings = callRecorder.getRecordings()
    }
    
    private func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            callRecorder.deleteRecording(recordings[index])
        }
        loadRecordings()
    }
}

struct RecordingRow: View {
    let recording: Recording
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recording.name)
                    .font(.headline)
                Text(recording.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Play/pause functionality
                togglePlayback()
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func togglePlayback() {
        isPlaying.toggle()
        // Implement audio playback logic
    }
}
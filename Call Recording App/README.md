# Call Recording App for iOS

A personal call recording app for iPhone X running iOS 16.

## Features
- Automatic call recording when calls start/end
- Manual recording control
- List of recorded calls with playback
- Delete recordings
- Background recording support
- **MP3 format recordings**
- **iCloud Drive storage** (with local fallback)
- **Cross-device sync** via iCloud

## Setup Instructions

### 1. Xcode Project Setup
1. Open Xcode and create a new iOS project
2. Choose "App" template
3. Set Product Name: "CallRecorder"
4. Set Bundle Identifier: "com.yourname.callrecorder" (use your own identifier)
5. Choose SwiftUI for Interface
6. Choose Swift for Language

### 2. Add Files to Project
Copy all the Swift files from this folder into your Xcode project:
- `CallRecorderApp.swift` (replace the default one)
- `ContentView.swift` (replace the default one)
- `Models/Recording.swift`
- `Services/CallRecorderService.swift`

### 3. Update Info.plist
Replace your Info.plist with the provided one, or add these keys:
- `NSMicrophoneUsageDescription`: "This app needs microphone access to record phone calls."
- `UIBackgroundModes`: ["audio", "voip"]

### 4. Add Entitlements File
Add the `CallRecorder.entitlements` file to your project.

### 5. Capabilities
In Xcode project settings, add these capabilities:
- Background Modes (Audio, Voice over IP)
- Microphone usage
- iCloud (CloudKit, iCloud Documents)

### 6. iCloud Setup
1. Enable iCloud capability in your project
2. Select "CloudKit" and "iCloud Documents"
3. Make sure you're signed into your Apple Developer account

### 7. Build and Install
1. Connect your iPhone X to your Mac
2. Select your device in Xcode
3. Build and run the project (Cmd+R)

## Important Notes

### Legal Considerations
- **Check local laws**: Call recording laws vary by location
- **Consent required**: Many jurisdictions require consent from all parties
- **Personal use only**: This app is designed for personal use only

### Technical Limitations
- iOS has restrictions on call recording for security/privacy
- This app records ambient audio during calls (speakerphone works best)
- For true call recording, you may need to use VoIP services or jailbreak (not recommended)

### Alternative Approaches
1. **Use speakerphone** and record ambient audio
2. **VoIP integration** with services like Twilio
3. **External recording devices** connected to phone line

## Usage
1. Grant microphone permissions when prompted
2. The app will automatically detect calls and start recording
3. You can also manually start/stop recording
4. View and play back recordings in the list
5. Swipe to delete unwanted recordings

## Troubleshooting
- Ensure microphone permissions are granted
- Check that background app refresh is enabled
- For best quality, use speakerphone during calls
- Recordings are stored as MP3 files in iCloud Drive (or locally if iCloud unavailable)
- Files sync across all your devices signed into the same iCloud account
- You can access recordings from Files app under "CallRecorder" folder

## Disclaimer
This app is for educational and personal use only. Users are responsible for complying with local laws regarding call recording and obtaining proper consent where required.
import SwiftUI
import AVFoundation

struct ContentView: View {
    let audioFile = try! AVAudioFile(forReading: AudioResources.horizon)
    
    var body: some View {
        Waveform(audioFile: audioFile)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

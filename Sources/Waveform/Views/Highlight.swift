import SwiftUI

struct Highlight: Shape {
    let selectedSamples: SampleRange
    
    @EnvironmentObject var audio: WaveformAudio
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            guard selectedSamples.count > 0 else { return }
            
            let startPosition = audio.position(of: selectedSamples.lowerBound)
            let endPosition = audio.position(of: selectedSamples.upperBound)
            
            path.addRect(CGRect(x: startPosition, y: rect.origin.y, width: endPosition - startPosition, height: rect.height))
        }
    }
}

import SwiftUI

struct Highlight: Shape {
    let selectedSamples: SampleRange
    
    @EnvironmentObject var audio: WaveformAudio
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            guard selectedSamples.count > 0, selectedSamples.overlaps(audio.renderSamples) else { return }
            
            let startPosition = max(0, audio.position(of: selectedSamples.lowerBound))
            let endPosition = min(audio.position(of: selectedSamples.upperBound), audio.width)
            
            let startIndex = Int(startPosition)
            let endIndex = Int(endPosition)
            
            path.move(to: CGPoint(x: startPosition, y: rect.midY))
            
            for index in startIndex..<endIndex {
                let x = CGFloat(index)
                let max = rect.midY + (rect.midY * CGFloat(audio.sampleData[index].max))
                path.addLine(to: CGPoint(x: x, y: max))
            }
            
            for index in (startIndex..<endIndex).reversed() {
                let x = CGFloat(index)
                let min = rect.midY + (rect.midY * CGFloat(audio.sampleData[index].min))
                path.addLine(to: CGPoint(x: x, y: min))
            }
            
            path.closeSubpath()
        }
    }
}

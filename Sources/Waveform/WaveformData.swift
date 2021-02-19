struct WaveformData {
    var min: Float
    var max: Float
    
    static var zero: WaveformData {
        WaveformData(min: 0, max: 0)
    }
}

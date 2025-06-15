import Foundation

extension Double {
    /// Округляет значение до указанного количества знаков после запятой
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

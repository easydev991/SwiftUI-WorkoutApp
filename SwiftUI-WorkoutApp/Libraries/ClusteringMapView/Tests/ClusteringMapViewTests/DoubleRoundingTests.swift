@testable import ClusteringMapView
import Foundation
import Testing

struct DoubleRoundingTests {
    @Test("Округление положительных чисел")
    func roundingPositiveNumbers() {
        #expect(3.14159.rounded(to: 2) == 3.14)
        #expect(3.14159.rounded(to: 3) == 3.142)
        #expect(3.14159.rounded(to: 4) == 3.1416)
        #expect(2.5.rounded(to: 0) == 3.0)
    }

    @Test("Округление отрицательных чисел")
    func roundingNegativeNumbers() {
        #expect((-3.14159).rounded(to: 2) == -3.14)
        #expect((-3.14159).rounded(to: 3) == -3.142)
        #expect((-2.5).rounded(to: 0) == -3.0)
        #expect((-1.99).rounded(to: 1) == -2.0)
    }

    @Test("Округление до нуля знаков после запятой")
    func roundingToZeroPlaces() {
        #expect(3.7.rounded(to: 0) == 4.0)
        #expect(3.2.rounded(to: 0) == 3.0)
        #expect(3.5.rounded(to: 0) == 4.0)
        #expect((-3.7).rounded(to: 0) == -4.0)
    }

    @Test("Округление до большого количества знаков")
    func roundingToManyPlaces() {
        let value = 1.123456789
        #expect(value.rounded(to: 5) == 1.12346)
        #expect(value.rounded(to: 8) == 1.12345679)
        #expect(value.rounded(to: 10) == 1.123456789)
    }

    @Test("Граничные случаи")
    func edgeCases() {
        #expect(0.0.rounded(to: 2) == 0.0)
        #expect(0.0.rounded(to: 0) == 0.0)
        #expect(1.0.rounded(to: 3) == 1.0)
        #expect((-0.0).rounded(to: 2) == 0.0)
    }

    @Test("Очень маленькие числа")
    func verySmallNumbers() {
        #expect(0.000001.rounded(to: 6) == 0.000001)
        #expect(0.000001.rounded(to: 5) == 0.0)
        #expect(0.0000015.rounded(to: 6) == 0.000002)
    }

    @Test("Очень большие числа")
    func veryLargeNumbers() {
        #expect(1234567.89123.rounded(to: 2) == 1234567.89)
        #expect(999999.999.rounded(to: 2) == 1000000.0)
        #expect(1000000.0.rounded(to: 3) == 1000000.0)
    }

    @Test("Проверка точности с плавающей запятой", arguments: [
        (3.14159, 2, 3.14),
        (0.123456789, 4, 0.1235),
        (1.234, 2, 1.23),
        (2.678, 2, 2.68)
    ])
    func floatingPointPrecision(input: Double, places: Int, expected: Double) {
        let result = input.rounded(to: places)
        let tolerance = pow(10.0, Double(-places - 1))
        #expect(abs(result - expected) < tolerance)
    }

    @Test("Округление с одним знаком после запятой")
    func roundingToOnePlace() {
        #expect(3.14.rounded(to: 1) == 3.1)
        #expect(3.15.rounded(to: 1) == 3.2)
        #expect(3.149.rounded(to: 1) == 3.1)
        #expect(3.151.rounded(to: 1) == 3.2)
    }

    @Test("Округление чисел близких к нулю")
    func roundingNearZero() {
        #expect(0.001.rounded(to: 2) == 0.0)
        #expect(0.005.rounded(to: 2) == 0.01)
        #expect((-0.001).rounded(to: 2) == 0.0)
        #expect((-0.005).rounded(to: 2) == -0.01)
    }

    @Test("Идемпотентность округления")
    func roundingIdempotency() {
        let value = 3.14159
        let roundedOnce = value.rounded(to: 2)
        let roundedTwice = roundedOnce.rounded(to: 2)
        #expect(roundedOnce == roundedTwice)

        let roundedThreeTimes = roundedTwice.rounded(to: 2)
        #expect(roundedOnce == roundedThreeTimes)
    }
}

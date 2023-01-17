import Foundation

struct SportsGroundFilter: Equatable {
    var size = SportsGroundSize.allCases
    var grade = SportsGroundGrade.allCases
    var onlyMyCity = true
    var currentCity: String?
}

import Foundation

struct SportsGroundFilter: Equatable {
    var size = SportsGroundSize.allCases
    var type = SportsGroundGrade.allCases
    var onlyMyCity = true
}

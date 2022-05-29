import Foundation

enum PhotoContainer {
    case event(Input), sportsGround(Input)

    struct Input {
        let containerID, photoID: Int
    }
}

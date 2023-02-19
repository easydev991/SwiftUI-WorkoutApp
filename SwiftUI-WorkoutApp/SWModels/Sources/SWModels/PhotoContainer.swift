public enum PhotoContainer {
    case event(Input), sportsGround(Input)

    public struct Input {
        public let containerID, photoID: Int

        public init(containerID: Int, photoID: Int) {
            self.containerID = containerID
            self.photoID = photoID
        }
    }
}

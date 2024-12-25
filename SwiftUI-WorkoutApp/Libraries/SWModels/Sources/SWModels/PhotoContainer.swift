public enum PhotoContainer: Sendable {
    case event(Input), park(Input)

    public struct Input: Sendable {
        public let containerID, photoID: Int

        public init(containerID: Int, photoID: Int) {
            self.containerID = containerID
            self.photoID = photoID
        }
    }
}

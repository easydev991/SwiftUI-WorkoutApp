import UIKit.UIColor

public extension ClusteringMapView {
    struct MarkerColors {
        /// Цвет маркера для кластера
        let cluster: UIColor
        /// Цвет маркера для обычной аннотации
        let regular: UIColor

        /// Инициализатор
        /// - Parameters:
        ///   - cluster: Цвет маркера для кластера, по умолчанию `.orange`
        ///   - regular: Цвет обычного маркера, по умолчанию `.red`
        public init(cluster: UIColor = .orange, regular: UIColor = .red) {
            self.cluster = cluster
            self.regular = regular
        }
    }
}

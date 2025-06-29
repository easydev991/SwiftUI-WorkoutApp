import Foundation
import SWModels

extension ParksMapScreen {
    enum NewParkState: Equatable {
        /// Ожидание
        case idle(NewParkMapModel)
        /// Определяем локацию пользователя
        case locating(NewParkMapModel)
        /// Готовы к созданию площадки
        case ready(NewParkMapModel)

        var model: NewParkMapModel {
            switch self {
            case let .idle(model), let .locating(model), let .ready(model):
                model
            }
        }

        /// Обрабатывается ли сейчас создание новой площадки
        var isProcessingNewPark: Bool {
            switch self {
            case .idle: false
            case .locating, .ready: true
            }
        }
    }
}

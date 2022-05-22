import SwiftUI

/// Универсальная картинка с возможностью кэширования
struct CacheImageView: View {
    let url: URL?
    var mode = Mode.user

    var body: some View {
        CacheAsyncImage(url: url, dummySize: mode.size) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .applySpecificSize(mode.size)
            default:
                Image("defaultWorkoutImage")
                    .resizable()
                    .applySpecificSize(mode.size)
            }
        }
    }
}

extension CacheImageView {
    enum Mode {
        case user, sportsGround, dialog, generic, journalEntry
        var size: CGSize {
            switch self {
            case .user:
                return .init(width: 36, height: 36)
            case .sportsGround, .dialog:
                return .init(width: 60, height: 60)
            case .generic, .journalEntry:
                return .init(width: 24, height: 24)
            }
        }
    }
}

struct SmallProfileCacheImageView_Previews: PreviewProvider {
    static var previews: some View {
        CacheImageView(url: .init(string: "https://workout.su/img/avatar_default.jpg")!)
    }
}

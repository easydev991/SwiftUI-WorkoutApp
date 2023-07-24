import SwiftUI

/// Вьюшка для профиля с базовой информацией
///
/// Фото, пол, возраст, страна и город
public struct ProfileView: View {
    private let imageURL: URL?
    private let login: String
    private let gender: String
    private let age: Int
    private let countryAndCity: String

    /// Инициализирует `ProfileView`
    /// - Parameters:
    ///   - imageURL: URL` картинки
    ///   - login: Имя пользователя (логин)
    ///   - gender: Пол
    ///   - age: Возраст
    ///   - countryAndCity: Страна и город
    public init(
        imageURL: URL?,
        login: String,
        gender: String,
        age: Int,
        countryAndCity: String
    ) {
        self.imageURL = imageURL
        self.login = login
        self.gender = gender
        self.age = age
        self.countryAndCity = countryAndCity
    }

    public var body: some View {
        VStack(spacing: 12) {
            CachedImage(url: imageURL, mode: .profileAvatar)
                .borderedClipshape(.roundedRectangle)
            VStack(spacing: 8) {
                Text(login)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.swMainText)
                    .font(.system(size: 22, weight: .bold))
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: Icons.Misc.personInCircle.rawValue)
                        Text(gender) + Text("years \(age)")
                    }
                    HStack(spacing: 8) {
                        Image(systemName: Icons.Misc.location.rawValue)
                        Text(countryAndCity)
                            .lineLimit(2)
                    }
                }
                .foregroundColor(.swSmallElements)
            }
        }
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            imageURL: nil,
            login: "Beautifulbutterfly101",
            gender: "Женщина",
            age: 30,
            countryAndCity: "Россия, Краснодар"
        )
        .padding(.horizontal, 40)
        .previewLayout(.sizeThatFits)
    }
}
#endif

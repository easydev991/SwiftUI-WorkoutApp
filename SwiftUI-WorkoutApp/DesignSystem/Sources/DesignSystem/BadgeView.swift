import SwiftUI

struct BadgeView: View {
    let value: Int
    
    var body: some View {
        Image(systemName: "\(value).circle.fill")
            .foregroundColor(.swAccent)
    }
}

#if DEBUG
struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(value: 1)
    }
}
#endif

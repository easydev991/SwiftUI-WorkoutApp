//
//  PersonRow.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import SwiftUI

struct PersonRow: View {
    let model: TempPersonModel

    var body: some View {
        HStack(spacing: 16) {
            profileImage
            VStack(alignment: .leading) {
                Text(model.name)
                    .fontWeight(.medium)
                Text(model.shortAddress)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

private extension PersonRow {
    var profileImage: some View {
        AsyncImage(url: .init(string: model.imageStringURL)) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .smallProfileImageRect()
            case .failure:
                Image(systemName: "person.fill")
            default:
                ProgressView()
            }
        }
    }
}

struct PersonRow_Previews: PreviewProvider {
    static var previews: some View {
        PersonRow(model: .mockMain)
    }
}

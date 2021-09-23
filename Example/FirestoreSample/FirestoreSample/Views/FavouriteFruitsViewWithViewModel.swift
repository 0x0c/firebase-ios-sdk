// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import FirebaseFirestoreSwift

private struct Fruit: Codable, Identifiable, Equatable {
  @DocumentID var id: String?
  var name: String
  var isFavourite: Bool
}

private class ViewModel: ObservableObject {
  @FirestoreQuery(
    collectionPath: "fruits",
    predicates: [
      .whereField("isFavourite", isEqualTo: true),
    ]
  ) fileprivate var fruitResults: Result<[Fruit], Error>
}

struct FavouriteFruitsViewWithViewModel: View {
  @StateObject fileprivate var viewModel = ViewModel()

  @State var showOnlyFavourites = true

  var body: some View {
    if case let .success(fruits) = viewModel.fruitResults {
      List(fruits) { fruit in
        Text(fruit.name)
      }
      .animation(.default, value: fruits)
      .navigationTitle("Fruits")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: toggleFilter) {
            Image(systemName: showOnlyFavourites
              ? "line.3.horizontal.decrease.circle.fill"
              : "line.3.horizontal.decrease.circle")
          }
        }
      }
    } else if case let .failure(error as NSError) = viewModel.fruitResults {
      // Handle error
      Text("Couldn't map data: \(error)")
    }
  }

  func toggleFilter() {
    showOnlyFavourites.toggle()
    if showOnlyFavourites {
      viewModel.$fruitResults.predicates = [
        .whereField("isFavourite", isEqualTo: true),
      ]
    } else {
      viewModel.$fruitResults.predicates = []
    }
  }
}

struct FavouriteFruitsViewWithViewModel_Previews: PreviewProvider {
  static var previews: some View {
    FavouriteFruitsViewWithViewModel()
  }
}

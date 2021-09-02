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
}

struct FavouriteFruitsMappingErrorView: View {
  @FirestoreQuery(
    collectionPath: "mappingFailure"
  ) private var fruitResults: Result<[Fruit], Error>

  var body: some View {
    if case let .success(fruits) = fruitResults {
      List(fruits) { fruit in
        Text(fruit.name)
      }
      .animation(.default, value: fruits)
      .navigationTitle("Mapping failure")
    } else if case let .failure(error as NSError) = fruitResults {
      // Handle error
      Text("Couldn't map data: \(error)")
    }
  }
}

struct FavouriteFruitsMappingErrorView_Previews: PreviewProvider {
  static var previews: some View {
    FavouriteFruitsMappingErrorView()
  }
}

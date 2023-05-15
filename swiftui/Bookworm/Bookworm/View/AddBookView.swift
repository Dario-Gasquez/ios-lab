//
//  AddBookView.swift
//  Bookworm
//
//  Created by Dario on 30/05/2022.
//

import SwiftUI

struct AddBookView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name of the book:", text: $title)
                    TextField("Author's name", text: $author)

                    Picker("Genre", selection: $genre) {
                        ForEach(genres, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section {
                    TextEditor(text: $review)
                    RatingView(rating: $rating)
                } header:  {
                    Text("Write a review")
                }

                Section {
                    Button("Save") {
                        let newBook = Book(context: managedObjectContext)
                        newBook.id = UUID()
                        newBook.title = title
                        newBook.author = author
                        newBook.rating = Int16(rating)
                        newBook.genre = genre
                        newBook.review = review

                        try? managedObjectContext.save()
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Add a Book")
    }

    // MARK: - Private Section -

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var rating = 2
    @State private var genre = ""
    @State private var review = ""

    private let genres = ["Fantasy", "Horror", "Kids", "Mystery", "Poetry", "Romance", "Thriller"]
}



struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView()
    }
}

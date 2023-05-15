//
//  DetailView.swift
//  Bookworm
//
//  Created by Dario on 30/05/2022.
//

import SwiftUI
import CoreData


struct DetailView: View {

    let book: Book

    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomTrailing) {
                Image(book.genre ?? "Fantasy")
                    .resizable()
                    .scaledToFit()

                Text(book.genre?.uppercased() ?? "FANTASY")
                    .font(.caption)
                    .fontWeight(.black)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                    .offset(x: -5, y: -5)
            }

            Text(book.author ?? "Unknown author")
                .font(.title)
                .foregroundColor(.secondary)

            Text(book.review ?? "No review")
                .padding()

            RatingView(rating: .constant(Int(book.rating)))
                .font(.largeTitle)
        }
        .navigationTitle(book.title ?? "Unknown Book")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete book", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive, action: deleteBook)
            Button("Cancel", role: .cancel) {}
        } message : {
            Text("Are you sure?")
        }
        .toolbar {
            Button {
                showingDeleteAlert = true
            } label: {
                Label("Delete this book", systemImage: "trash")
            }
        }
    }


    // MARK: - Private Section -
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false

    private func deleteBook() {
        moc.delete(book)

        dismiss()
    }
}



struct DetailView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static var previews: some View {
        let newBook = Book(context: moc)
        newBook.title = "Test book"
        newBook.author = "Test author"
        newBook.genre = "Fantasy"
        newBook.rating = 4
        newBook.review = "This was a great book; I really enjoyed it"

        return NavigationView {
            DetailView(book: newBook)
        }
    }
}

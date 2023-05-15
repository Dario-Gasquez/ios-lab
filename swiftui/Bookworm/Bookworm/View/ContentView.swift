//
//  ContentView.swift
//  Bookworm
//
//  Created by Dario on 30/05/2022.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        DetailView(book: book)
                    } label: {
                        HStack {
                            EmojiRatingView(rating: book.rating)
                                .font(.largeTitle)

                            VStack(alignment: .leading) {
                                Text(book.title ?? "Unknown Title")
                                    .font(.headline)
                                Text(book.author ?? "Unknown Author")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("Bookworm")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddScreen.toggle()
                    } label: {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                AddBookView()
            }
        }
    }
    

    // MARK: - Private Section -

    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.title),
        SortDescriptor(\.author) // pretty cheap in terms of performance, unless we have a lots of data with the same title
    ]) private var books: FetchedResults<Book>

    @State private var showingAddScreen = false


    private func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            let book = books[offset]
            managedObjectContext.delete(book)
        }

        try? managedObjectContext.save()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

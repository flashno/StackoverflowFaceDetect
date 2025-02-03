//
//  UsersListView.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import SwiftUICore
import SwiftUI

import SwiftUI

struct UsersListView: View {
    @StateObject private var viewModel = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                } else {
                    List(viewModel.users) { user in
                        NavigationLink {
                            UserDetailView(user: user)
                        } label: {
                            UserRowView(user: user)
                        }
                    }
                }
            }
            .navigationTitle("Top Users")
        }
        .task { await viewModel.fetchUsers() }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
            Text("Error loading users")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.red)
        .padding()
    }
}

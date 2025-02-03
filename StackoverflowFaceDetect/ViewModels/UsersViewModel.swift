//
//  UsersViewModel.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import Foundation


class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    @MainActor
    func fetchUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let users = try await APIService.shared.fetchTopUsers()
            self.users = users
            self.error = nil
        } catch {
            self.users = []
            self.error = error
        }
    }
}

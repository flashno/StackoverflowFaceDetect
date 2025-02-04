//
//  UsersViewModel.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import Foundation
import UIKit

/// ViewModel responsible for managing Stack Overflow user data, image loading, and face detection
class UsersViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Array of basic user data from Stack Overflow API
    @Published private(set) var users: [User] = []
    
    /// Indicates if the initial API call is in progress
    @Published private(set) var isInitialLoading = false
    
    /// Stores any errors that occur during data fetching or processing
    @Published private(set) var error: Error?
    
    /// Dictionary storing processed image and face detection results for each user
    @Published private(set) var userImagesData: [Int: UserImageData] = [:]
    
    /// Set of user IDs currently being processed
    @Published private(set) var processingUsers = Set<Int>()
    
    // MARK: - Private Properties
    /// Maximum number of concurrent processing operations allowed
    private let maxConcurrentOperations = 4
    
    // MARK: - Public Methods
    
    /// Fetches users from the Stack Overflow API and processes their images
    func fetchUsers() async {
        // First, handle our loading state based on current app state
        await MainActor.run {
            // Only show loading indicator if this is our first load
            if users.isEmpty {
                isInitialLoading = true
            }
            // Clear any previous errors since we're starting a fresh fetch
            error = nil
        }
        
        do {
            // Fetch new users from the API
            let fetchedUsers = try await APIService.shared.fetchTopUsers()
            
            // Compare new users with existing processed data
            await MainActor.run {
                // Update our users list with the fresh data
                users = fetchedUsers
                isInitialLoading = false
                
                // Find which users need processing by comparing with existing data
                let usersNeedingProcessing = fetchedUsers.filter { newUser in
                    // A user needs processing if we don't have their image data yet
                    !userImagesData.keys.contains(newUser.id)
                }
                
                // Only start processing if we have new users to handle
                if !usersNeedingProcessing.isEmpty {
                    // Create a new task for processing, with proper error handling
                    Task {
                        do {
                            try await processUsers(usersNeedingProcessing)
                        } catch {
                            // If processing fails, we want to know about it
                            await MainActor.run {
                                self.error = error
                                print("Error processing users: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        } catch {
            // Handle API fetch errors appropriately
            await MainActor.run {
                // We only clear existing users if we have nothing cached
                // This prevents flickering if a refresh fails
                if users.isEmpty {
                    self.error = error
                    self.users = []
                }
                isInitialLoading = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Processes multiple users concurrently with controlled concurrency
    private func processUsers(_ users: [User]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Process users in smaller batches to prevent system overload
            for batch in users.chunks(of: maxConcurrentOperations) {
                for user in batch {
                    group.addTask {
                        await self.processUser(user)
                    }
                }
                // Wait for current batch to complete before starting next batch
                try await group.waitForAll()
            }
        }
    }
    
    /// Processes a single user's image and face detection
    private func processUser(_ user: User) async {
        // Mark user as being processed
        _ = await MainActor.run {
            processingUsers.insert(user.id)
        }
        
        do {
            // First load the image
            guard let image = try await loadImage(for: user) else {
                print("Failed to load image for user: \(user.id)")
                return
            }
            
            // Update UI with loaded image and default face metadata
            await MainActor.run {
                userImagesData[user.id] = UserImageData(
                    image: image,
                    faceMetadata: .empty
                )
            }
            
            // Perform face detection with timeout
            let metadata = try await performFaceDetection(for: image)
            
            // Update UI with face detection results
            await MainActor.run {
                userImagesData[user.id] = UserImageData(
                    image: image,
                    faceMetadata: metadata
                )
            }
        } catch {
            print("Error processing user \(user.id): \(error.localizedDescription)")
        }
        
        // Always remove from processing set when done
        _ = await MainActor.run {
            processingUsers.remove(user.id)
        }
    }
    
    /// Loads an image for a user with timeout protection
    private func loadImage(for user: User) async throws -> UIImage? {
        guard let urlString = user.profileImage,
                 let url = URL(string: urlString) else {
               print("Invalid URL for user: \(user.id)")
               return nil
           }

           return try await withThrowingTaskGroup(of: UIImage?.self) { group in
               group.addTask {
                   let (data, response) = try await URLSession.shared.data(from: url)
                   
                   // Validate HTTP response
                   guard let httpResponse = response as? HTTPURLResponse,
                         (200...299).contains(httpResponse.statusCode) else {
                       print("Invalid response for user image: \(user.id)")
                       return nil
                   }
                   
                   return UIImage(data: data)
               }
            
            group.addTask {
                try await Task.sleep(for: .seconds(10))
                throw CancellationError()
            }
            
            guard let result = try await group.next() else {
                throw CancellationError()
            }
            group.cancelAll()
            return result
        }
    }
    
    /// Performs face detection on an image with timeout protection
    private func performFaceDetection(for image: UIImage) async throws -> FaceMetadata {
        try await withThrowingTaskGroup(of: FaceMetadata.self) { group in
            group.addTask {
                await FaceDetector.shared.detectFaceFeatures(in: image)
            }
            
            group.addTask {
                try await Task.sleep(for: .seconds(5))
                throw CancellationError()
            }
            
            guard let result = try await group.next() else {
                return .empty
            }
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Helper Extensions

extension Array {
    func chunks(of size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

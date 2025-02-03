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
    @Published var userImagesData: [Int: UserImageData] = [:]
    
    private var imageLoaders: [Int: ImageLoader] = [:]
    private let maxConcurrentOperations = 3  // Control concurrent operations
    
    @MainActor
    func fetchUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let users = try await APIService.shared.fetchTopUsers()
            self.users = users
            self.error = nil
            self.userImagesData.removeAll()
            self.imageLoaders.removeAll()
            
            // Process all users with controlled concurrency
            await processUsers(users)
        } catch {
            self.users = []
            self.error = error
            self.userImagesData.removeAll()
            self.imageLoaders.removeAll()
        }
    }
    
    private func processUsers(_ users: [User]) async {
        // Create a task group with controlled concurrency
        await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
            var pendingUsers = users
            var activeCount = 0
            
            // Process users with controlled concurrency
            while !pendingUsers.isEmpty || activeCount > 0 {
                // Add new tasks if we have capacity and pending users
                while activeCount < maxConcurrentOperations && !pendingUsers.isEmpty {
                    let user = pendingUsers.removeFirst()
                    group.addTask {
                        await self.processUser(user)
                    }
                    activeCount += 1
                }
                
                // Wait for a task to complete before continuing
                do {
                    _ = try await group.next()
                    activeCount -= 1
                } catch {
                    print("Error processing user: \(error.localizedDescription)")
                    activeCount -= 1
                }
            }
        }
    }
    
    private func processUser(_ user: User) async {
        // Create a dedicated ImageLoader for this user
        let imageLoader = ImageLoader()
        
        await MainActor.run {
            imageLoaders[user.id] = imageLoader
        }
        
        do {
            // Add timeout for image loading
            let loadImageTask = Task {
                await imageLoader.loadImage(from: user.profileImage)
            }
            
            // Set a timeout of 10 seconds for image loading
            let _ = try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await loadImageTask.value
                }
                
                group.addTask {
                    try await Task.sleep(for: .seconds(10))
                    loadImageTask.cancel()
                    throw CancellationError()
                }
                
                // Wait for either completion or timeout
                try await group.next()
                group.cancelAll()
            }
            
            // Ensure we have a valid image
            guard let image = imageLoader.image else {
                       print("Failed to load image for user: \(user.id)")
                       return
                   }
                   
                   // Perform face detection with timeout
                   let detectionTask = Task.detached(priority: .userInitiated) {
                       FaceDetector.shared.detectFaceFeatures(in: image)
                   }
                   
                   let metadata = try await withThrowingTaskGroup(of: FaceMetadata.self) { group in
                       group.addTask {
                           await detectionTask.value
                       }
                       
                       group.addTask {
                           try await Task.sleep(for: .seconds(5))
                           detectionTask.cancel()
                           // Instead of throwing CancellationError, return a default FaceMetadata
                           return FaceMetadata(hasFace: false,
                                             hasSmile: false,
                                             isLeftEyeClosed: false,
                                             isRightEyeClosed: false,
                                             faceAngle: 0)
                       }
                       
                       // Get the first result and handle the optional
                       guard let result = try await group.next() else {
                           // If no result is available, provide a default FaceMetadata
                           return FaceMetadata(hasFace: false,
                                             hasSmile: false,
                                             isLeftEyeClosed: false,
                                             isRightEyeClosed: false,
                                             faceAngle: 0)
                       }
                       
                       group.cancelAll()
                       return result
                   }
                   
                   // Update the UI with the new data
                   await MainActor.run {
                       self.userImagesData[user.id] = UserImageData(
                           image: image,
                           faceMetadata: metadata
                       )
                   }
               } catch {
                   print("Error processing user \(user.id): \(error.localizedDescription)")
               }
    }
    
    func cleanup() {
        imageLoaders.removeAll()
        userImagesData.removeAll()
    }
}

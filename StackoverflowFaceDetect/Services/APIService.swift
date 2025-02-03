//
//  APIService.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import Foundation


class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.stackexchange.com/2.3/users"
    
    func fetchTopUsers() async throws -> [User] {
        let url = URL(string: "\(baseURL)?order=desc&sort=reputation&site=stackoverflow&pagesize=10")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let wrapper = try decoder.decode(Wrapper.self, from: data)
        return wrapper.items
    }
    
    private struct Wrapper: Codable {
        let items: [User]
    }
}

//
//  WebService.swift
//  Recify
//
//  Created by Macbook on 2026-02-08.
//

import Foundation


enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case faildToDecodeResponse
}

class WebService {
    
    
    func sendRequest<T: Codable>(toUrl: String, method: HttpMethod, body: T? = nil) async -> T? {
        
        do{
            guard let url = URL(string: toUrl)
            else {
                throw NetworkError.badUrl
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = method.rawValue
            
            if let body = body {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse
            else{
                throw NetworkError.badResponse
            }
            
            
            guard 200..<300 ~= response.statusCode
            else{
                throw NetworkError.badStatus
            }

            print("Response Status code: \(response.statusCode), \(data)")
            
            return try JSONDecoder().decode(T.self, from: data)
            
        }catch{
            print("Request Failed: ", error.localizedDescription)
            return nil
        }
        
    }
    
}

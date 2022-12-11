//
//  OpenAIData.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/11.
//

import Foundation

struct OpenAIData: Codable {
    
    let id: String?
    
    let object: String?
    
    let created: Int?
    
    let model: String?
    
    let choices: [Choices]?
    
    let usage: Usage?
    
}

struct Choices: Codable {
    
    let text: String?
    
    let index: Int?
    
    let logprobs: String?
    
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        
        case text, index, logprobs
        
        case finishReason = "finish_reason"
    }
}

struct Usage: Codable {
    
    let promptToken: Int?
    
    let completionTokens: Int?
    
    let totalTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case promptToken = "prompt_token"
        
        case completionTokens = "completion_tokens"
        
        case totalTokens = "total_tokens"
    }
}

//
//  OpenAIManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/11.
//

import Alamofire
import UIKit

enum OpenAIEngine: String {

    case davinci

    case curie

    case babbage

    case ada
    
    case instructcurie = "instruct-curie"

    case instructdavinci = "instruct-davinci"
}

class OpenAIManager {
    
    static let sharedInstance = OpenAIManager()
    
    let openAIKey = "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"
    
    var engine: OpenAIEngine = .davinci
    
    func fetchResponses(text: String, completion: @escaping (String) -> Void) {

        var headers = HTTPHeaders()
        
        let openAIurl = "https://api.openai.com/v1/completions"
        
        headers = [

            .contentType("application/json"),

            .authorization(bearerToken: openAIKey)

        ]

        let param = [
            
            "model": "text-davinci-003",
            
            "prompt": text,

            "max_tokens": 200
        
        ] as [String: Any]

        AF.request(openAIurl, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: OpenAIData.self) { response in
            if let choices = response.value?.choices, let text = choices[0].text {

                completion(text)
            }
            
            debugPrint(response)
        }
    }
}

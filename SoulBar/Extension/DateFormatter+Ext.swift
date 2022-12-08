//
//  DateFormatter+Ext.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/13.
//

import Foundation

extension DateFormatter {
    
    static let posixFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        
        return formatter
    }()
    
    func timeIntervalToString(timeinterval: TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(timeinterval))
        
        DateFormatter.posixFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        return DateFormatter.posixFormatter.string(from: date)
        
    }
}

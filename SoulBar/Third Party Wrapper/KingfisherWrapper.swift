//
//  KingfisherWrapper.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/12/7.
//

import Foundation
import Kingfisher

extension UIImageView {

    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {

        guard let urlString = urlString else { return }
        
        let url = URL(string: urlString)

        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}

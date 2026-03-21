//
//  GenerateQRCode.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

import CoreImage.CIFilter
import UIKit

func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: .ascii)
    
    // 1. 创建滤镜并设置输入
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("H", forKey: "inputCorrectionLevel") // 设置高容错率，让二维码更健壮
    
    // 2. 获取输出图片并放大
    guard let ciImage = filter.outputImage else { return nil }
    let scale = UIScreen.main.scale * 5 // 根据屏幕密度放大，确保清晰
    let transform = CGAffineTransform(scaleX: scale, y: scale)
    let scaledCIImage = ciImage.transformed(by: transform)
    
    // 3. 【核心修复】显式渲染为 CGImage
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else {
        return nil
    }
    
    // 4. 返回最终的 UIImage
    return UIImage(cgImage: cgImage)
}

func isValidAddress(_ address: String) -> Bool {
    // 以太坊地址是0x开头，后面跟着40个十六进制字符
    let addressRegex = "^0x[a-fA-F0-9]{40}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", addressRegex)
    return predicate.evaluate(with: address)
}

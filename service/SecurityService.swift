//
//  SecurityService.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import LocalAuthentication
import SwiftUI

class SecurityService: ObservableObject {
    @Published var isUnlocked = false
    
    // 这是一个通用的认证方法，支持闭包回调
    func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // 1. 检查设备是否支持生物识别（FaceID/TouchID/密码）
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your wallet to access sensitive information."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        completion(true)
                    } else {
                        // 认证失败（如用户取消或识别不匹配）
                        completion(false)
                    }
                }
            }
        } else {
            // 设备不支持生物识别（比如模拟器没开启 FaceID）
            // 在开发阶段，我们可以默认返回 true，或者提示用户去设置开启
            print("Biometrics not available: \(error?.localizedDescription ?? "Unknown error")")
            completion(true) // 调试用：如果不支持，直接放行
        }
    }
}

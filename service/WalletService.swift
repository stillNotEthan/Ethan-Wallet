//
//  WalletService.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/18.
//

import Foundation
import WalletCore
import web3
import SwiftProtobuf

class WalletService {
    static let shared = WalletService()
    private let serviceName = "com.ethan.ethanwallet"
    private let accountName = "mnemonic"
    
    // 保存助记词到Keychain
    func saveMnemonic(_ mnemonic: String) {
        if let data = mnemonic.data(using: .utf8) {
            KeychainHelper.shared.save(data, service: serviceName, account: accountName)
        }
    }
    
    // 从Keychain读取助记词
    func loadMnemonic() -> String? {
        if let data = KeychainHelper.shared.read(service: serviceName, account: accountName) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private init() {}
    
    /// 生产12个单词的助记词
    func generateMnemonic() -> String {
        // 128 bits 对应 12 个单词，256 bits 对应 24 个单词
        guard let wallet = HDWallet(strength: 128, passphrase: "") else {
            return "Error generating mnemonic"
        }
        return wallet.mnemonic
    }
    /// 根据助记词导入钱包并获取以太坊地址
    func getEthereumAddress(from mnemonic: String) -> String? {
        // 使用助记词初始化 HDWallet
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            return nil
        }
        // 推导出以太坊 (CoinType.ethereum) 的地址
        let address = wallet.getAddressForCoin(coin: .ethereum)
        return address
    }
    
    func getBalance(address: String, completion: @escaping (String) -> Void) {
        // 1. 确保地址是 0x 开头的 42 位字符串
        var formattedAddress = address
        if !formattedAddress.hasPrefix("0x") {
            formattedAddress = "0x" + formattedAddress
        }
        
        // 2. 使用更稳定的公共节点 (Ankr 节点对格式要求相对宽松)
        guard let url = URL(string: "https://eth-mainnet.g.alchemy.com/v2/3XrHH2lCoF9umUMpF4uZ_" ) else { return }
        
        // 3. 严格按照以太坊 JSON-RPC 规范构造请求体
        let requestBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": [formattedAddress, "latest"], // 确保这里是字符串 "latest"
            "id": Int(Date().timeIntervalSince1970) // 使用动态 ID
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type" )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [] )
        } catch {
            completion("Error: Request Encoding Failed")
            return
        }
        
        print("🚀 Requesting balance for: \(formattedAddress) via \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion("Error: \(error.localizedDescription)") }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion("Error: No Data") }
                return
            }
            
            // 打印原始响应，方便我们最后一次确认
            if let rawString = String(data: data, encoding: .utf8) {
                print("🌐 Node Response: \(rawString)")
            }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let hexBalance = result["result"] as? String {
                    // 成功获取到十六进制余额 (例如 "0x0" 或 "0x1bc16d674ec80000")
                    let cleanHex = hexBalance.replacingOccurrences(of: "0x", with: "")
                    
                    if cleanHex.isEmpty || cleanHex == "0" {
                        DispatchQueue.main.async { completion("0.0000 ETH") }
                        return
                    }
                    
                    // 使用 Scanner 解析十六进制
                    var weiValue: UInt64 = 0
                    let scanner = Scanner(string: cleanHex)
                    if scanner.scanHexInt64(&weiValue) {
                        let etherValue = Double(weiValue) / 1_000_000_000_000_000_000.0
                        DispatchQueue.main.async {
                            completion(String(format: "%.4f ETH", etherValue))
                        }
                    } else {
                        DispatchQueue.main.async { completion("0.0000 ETH") }
                    }
                    return
                } else if let errorDict = result["error"] as? [String: Any] {
                    let msg = errorDict["message"] as? String ?? "Unknown Error"
                    DispatchQueue.main.async { completion("RPC Error: \(msg)") }
                    return
                }
            }
            DispatchQueue.main.async { completion("Error: Invalid Response") }
        }.resume()
    }
}

extension WalletService {
    /// 从助记词推导出以太坊私钥
    func getPrivateKeyByMnemonic(from mnemonic: String) -> Data? {
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            return nil
        }
        // 获取privateKey对象
        let privateKey = wallet.getKeyForCoin(coin: .ethereum)
        // 提取原始 Data
        return privateKey.data
    }
    
    func signTransaction(mnemonic: String, toAddress: String, amountInEth: Double) -> String? {
        // 获取私钥
        guard let privateKeyData = getPrivateKeyByMnemonic(from: mnemonic) else {return nil}
        
        // 构造以太坊交易输入
        var input = TW_Ethereum_Proto_SigningInput()
        // 设置链 ID （以太坊主网是1）
        input.chainID = Data([0x01])
        // 设置Nonce
        input.nonce = Data([0x00])
        
        // 设置Gas费用
        input.gasPrice = Data(hexString: "04a817c800")!
        input.gasLimit = Data(hexString: "5208")!
        
        // 设置收款地址
        input.toAddress = toAddress
        
        // 设置转账金额
        let weiAmount = UInt64(amountInEth * 1_000_000_000_000_000_000)
        var transaction = TW_Ethereum_Proto_Transaction()
        var transfer = TW_Ethereum_Proto_Transaction.Transfer()
        
        // 将金额转为大端序 Data
        var bigEndianAmount = weiAmount.bigEndian
        transfer.amount = Data(bytes: &bigEndianAmount, count: MemoryLayout.size(ofValue: bigEndianAmount))
        
        transaction.transfer = transfer
        input.transaction = transaction
        
        // 设置私钥
        input.privateKey = privateKeyData
        
        // 执行签名
        do {
            let inputData = try input.serializedData()
            let outputData = AnySigner.nativeSign(data: inputData, coin: .ethereum)
            let output = try TW_Ethereum_Proto_SigningOutput(serializedData: outputData)
            
            // 返回签名后的十六进制字符串
            return output.encoded.hexString
        } catch {
            print("Signing Error: \(error)")
            return nil
        }
    }
    
    func broadcastTransaction(signedHex: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://eth-mainnet.g.alchemy.com/v2/3XrHH2lCoF9umUMpF4uZ_") else { return }
        
        // 构造eth_sendRawTransaction 请求
        // signedHex 必须以 0x开头
        let formattedHex = signedHex.hasPrefix("0x") ? signedHex : "0x" + signedHex
        
        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_sendRawTransaction",
            "params": [formattedHex],
            "id": 1
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        print("Broadcasting transaction...")
        
        // 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {completion("Network Error: \(error.localizedDescription)")}
                return
            }
            
            guard let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async{ completion("Error: Invalid Response") }
                return
            }
            
            if let txHash = result["result"] as? String {
                // 成功 返回交易哈希
                DispatchQueue.main.async{completion("Success! hash: \(txHash)")}
            } else if let errorDict = result["error"] as? [String: Any] {
                // 失败，返回错误信息
                let msg = errorDict["message"] as? String ?? "Unknown RPC Error"
                DispatchQueue.main.async{completion("RPC Error \(msg)")}
            }
        }.resume()
    }
}

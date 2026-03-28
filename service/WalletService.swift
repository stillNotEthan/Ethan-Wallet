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
import BigInt

class WalletService {
    static let shared = WalletService()
    private let serviceName = "com.ethan.ethanwallet"
    private let accountName = "mnemonic"
    
    var rpcURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "RPC_URL") as? String ?? ""
    }
    
    
    // 保存助记词到Keychain
    func saveMnemonic(_ mnemonic: String) {
        if let data = mnemonic.data(using: .utf8) {
            KeychainHelper.shared
                .save(data, service: serviceName, account: accountName)
        }
    }
    
    // 从Keychain读取助记词
    func loadMnemonic() -> String? {
        if let data = KeychainHelper.shared.read(
            service: serviceName,
            account: accountName
        ) {
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
    
    static func getBalance(address: String, completion: @escaping (String) -> Void) {
        // 1. 确保地址是 0x 开头的 42 位字符串
        var formattedAddress = address
        if !formattedAddress.hasPrefix("0x") {
            formattedAddress = "0x" + formattedAddress
        }
        
        // 2. 使用更稳定的公共节点 (Ankr 节点对格式要求相对宽松)
        let urlString = WalletService.shared.rpcURL
        guard let url = URL(string: urlString ) else {
            return
        }
        
        // 3. 严格按照以太坊 JSON-RPC 规范构造请求体
        let requestBody: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": [formattedAddress, "latest"], // 确保这里是字符串 "latest"
            "id": Int(Date().timeIntervalSince1970) // 使用动态 ID
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request
            .setValue("application/json", forHTTPHeaderField: "Content-Type" )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization
                .data(withJSONObject: requestBody, options: [] )
        } catch {
            completion("Error: Request Encoding Failed")
            return
        }
        
        print(
            "🚀 Requesting balance for: \(formattedAddress) via \(url.absoluteString)"
        )
        
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)")
                }
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
                    let cleanHex = hexBalance.replacingOccurrences(
                        of: "0x",
                        with: ""
                    )
                    
                    if cleanHex.isEmpty || cleanHex == "0" {
                        DispatchQueue.main.async { completion("0.0000 ETH") }
                        return
                    }
                    
                    // 使用 Scanner 解析十六进制
                    var weiValue: UInt64 = 0
                    let scanner = Scanner(string: cleanHex)
                    if scanner.scanHexInt64(&weiValue) {
                        let etherValue = Double(
                            weiValue
                        ) / 1_000_000_000_000_000_000.0
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
    
    func signTransaction(
        to recipient: String,
        amount: BigUInt,
        nonce: BigUInt,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        mnemonic: String
    ) -> String? {
        // 获取私钥
        guard let privateKey = getPrivateKeyByMnemonic(from: mnemonic) else {
            return nil
        }
        
        let coin: CoinType = .ethereum
        
        let input = EthereumSigningInput.with {
            $0.chainID = Data(hexString: "01")! // 以太坊主网 ID 为 1
            $0.nonce = Data(nonce.serialize())
            $0.gasPrice = Data(gasPrice.serialize())
            $0.gasLimit = Data(gasLimit.serialize())
            $0.toAddress = recipient
            $0.transaction = EthereumTransaction.with {
                $0.transfer = EthereumTransaction.Transfer.with {
                    $0.amount = Data(amount.serialize())
                }
            }
            $0.privateKey = privateKey
        }
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: coin)
        return output.encoded.hexString
        
    }
    
    static func broadcastTransaction(
        signedHex: String,
        completion: @escaping (String) -> Void
    ) {
        let urlString = WalletService.shared.rpcURL
        guard let url = URL(string: urlString) else {
            return
        }
        
        // 构造eth_sendRawTransaction 请求
        // signedHex 必须以 0x开头
        let formattedHex = signedHex.hasPrefix(
            "0x"
        ) ? signedHex : "0x" + signedHex
        
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
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Network Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async{
                    completion("Error: Invalid Response")
                }
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
    
    // 获取当前网络的Gas价格 （单位：Wei）
    static func fetchGasPrice() async throws -> BigUInt {
        let urlString = WalletService.shared.rpcURL
        print("current rpc: \(urlString)")
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_gasPrice",
            "params": [],
            "id": 1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(
            RPCResponse<String>.self,
            from: data
        )
        
        // 将十六进制转为BigUInt
        return BigUInt(
            response.result.replacingOccurrences(of: "0x", with: ""),
            radix: 16
        ) ?? 0
    }
    
    
    static func fetchNonce(for address: String) async throws -> BigUInt {
        let urlString = WalletService.shared.rpcURL
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getTransactionCount",
            "params": [address, "latest"],
            "id": 1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(RPCResponse<String>.self, from: data)
        
        // 将十六进制字符串转为 BigUInt
        return BigUInt(response.result.replacingOccurrences(of: "0x", with: ""), radix: 16) ?? 0
    }
    
    static func fetchTokenBalance(contractAddress: String, walletAddress: String, decimals: Int) async throws -> String {
        let urlString = WalletService.shared.rpcURL
        guard let url = URL(string: urlString) else { throw NSError(domain: "Invalid URL", code: 0) }
        
        // 构造balanceOf的Data
        // balanceOf的方法选择器是0x70a08231
        let methodID = "70a08231"
        let paddedAddress = walletAddress.replacingOccurrences(of: "0x", with: "").paddingLeft(toLength: 64, withPad: "0")
        let data = "0x" + methodID + paddedAddress
        
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_call",
            "params": [["to": contractAddress, "data": data], "latest"],
            "id": 1
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(RPCResponse<String>.self, from: responseData)
        
        // 解析返回的大数并转换精度
        let rawBalance = BigUInt(response.result.replacingOccurrences(of: "0x", with: ""), radix: 16) ?? 0
        let divisor = pow(10.0, Double(decimals))
        let formattedBalance = Double(rawBalance) / divisor
        return String(format: "%.2f", formattedBalance)
    }
    
    static func fetchTransactionHistory(for address: String) async throws -> [Transaction] {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "ETHERSCAN_API_KEY") as? String ?? ""
        let urlString = "https://api.etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&endblock=99999999&sort=desc&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { throw NSError(domain: "Invalid URL", code: 0) }
        let request = URLRequest(url: url);
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(EtherscanResponse.self, from: data)
        
        return response.result
    }
}

extension String {
    func paddingLeft(toLength: Int, withPad character: String) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeating: character, count: toLength - newLength) + self
        } else {
            return self
        }
    }
}

struct RPCResponse<T: Codable>: Codable {
    let result: T
}

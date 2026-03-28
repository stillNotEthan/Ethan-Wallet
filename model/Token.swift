//
//  Token.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/22.
//

import Foundation
import BigInt

struct Token: Identifiable, Hashable {
    let id = UUID();
    let name: String;
    let symbol: String;
    let contractAddress: String;
    let decimal: Int;
    var balance: String = "0.0"
    let iconName: String;
}

extension Token {
    static let mockTokens = [
        Token(name: "Tether USD", symbol: "USDT", contractAddress: "0xdAC17F958D2ee523a2206206994597C13D831ec7", decimal: 6, iconName: "t.circle.fill"),
        Token(name: "USD Coin", symbol: "USDC", contractAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", decimal: 6, iconName: "u.circle.fill"),
        Token(name: "Chainlink", symbol: "LINK", contractAddress: "0x514910771AF9Ca656af840dff83E8264EcF986CA", decimal: 18, iconName: "l.circle.fill")
    ]
}

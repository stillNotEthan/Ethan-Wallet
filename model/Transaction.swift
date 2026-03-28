//
//  Transaction.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    let id = UUID();
    let hash: String;
    let from: String;
    let to: String;
    let value: String;
    let timeStamp: String;
    let isError: String;
    
    // 格式化后的日期
    var date: String {
        let interval = TimeInterval(timeStamp) ?? 0;
        let date = Date(timeIntervalSince1970: interval);
        let formatter = DateFormatter();
        formatter.dateStyle = .medium;
        formatter.timeStyle = .short;
        return formatter.string(from: date)
    }
    
    // 格式化后的金额（wei -> ETH）
    var formattedValue: String {
        let wei = Double(value) ?? 0;
        let eth = wei / 1_000_000_000_000_000_000.0;
        return String(format: "%.4f ETH", eth);
    }
}

struct EtherscanResponse: Codable {
    let status: String;
    let message: String;
    let result: [Transaction]
}

//
//  ShortenAddress.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/20.
//

func shortenAddress(_ addr: String) -> String {
    guard addr.count > 10 else { return addr }
    return String(addr.prefix(6)) + "..." + String(addr.suffix(4))
}

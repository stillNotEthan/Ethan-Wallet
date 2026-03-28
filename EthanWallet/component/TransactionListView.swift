//
//  TransactionListView.swift
//  EthanWallet
//
//  Created by Ethan Wang on 2026/3/28.
//

import SwiftUI

struct TransactionListView: View {
    let transactions: [Transaction];
    let walletAddress: String;
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.title3)
                .bold()
                .padding(.horizontal)
            
            if transactions.isEmpty {
                Text("No Any transactions found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(transactions.prefix(5)) { tx in
                    HStack {
                        Image(systemName: tx.from.lowercased() == walletAddress.lowercased() ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                            .foregroundColor(tx.from.lowercased() == walletAddress.lowercased() ? .red : .green)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(tx.from.lowercased() == walletAddress.lowercased() ? "Sent" : "Received")
                                .bold()
                            Text(tx.date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(tx.formattedValue)
                            .bold()
                        
                    }
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
        }
    }
}

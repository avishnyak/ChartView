//
//  MagnifierRect.swift
//
//
//  Created by Samu András on 2020. 03. 04..
//

import SwiftUI

public struct MagnifierRect: View {
    @Binding var currentNumbers: [Double]
    var valueSpecifier: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    public var body: some View {
        ZStack {
            VStack {
                Text(self.currentNumbers.map { String(format: self.valueSpecifier, $0) }.joined(separator: "\n"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    .padding()

                Spacer()
            }

            if self.colorScheme == .dark {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: self.colorScheme == .dark ? 2 : 0)
                    .frame(width: 60, height: 260)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 60, height: 280)
                    .foregroundColor(Color.white)
                    .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6)
                    .blendMode(.multiply)
            }
        }
    }
}

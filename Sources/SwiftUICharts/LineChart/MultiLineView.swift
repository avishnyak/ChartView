//
//  MultiLineView.swift
//  MultiLineChart
//
//  Created by Anton Vishnyak
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct MultiLineView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var data: [MultiLineChartData]
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String

    @State private var showLegend = false
    @State private var dragLocation: CGPoint = .zero
    @State private var indicatorLocation: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var currentDataNumbers: [Double] = [0]
    @State private var hideHorizontalLines: Bool = false

    var globalMin: Double {
        if let min = data.flatMap({ $0.onlyPoints() }).min() {
            return min
        }
        return 0
    }

    var globalMax: Double {
        if let max = data.flatMap({ $0.onlyPoints() }).max() {
            return max
        }
        return 0
    }

    public init(data: [([Double], String, GradientColor)],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f") {
        self.data = data.map { MultiLineChartData(points: $0.0, label: $0.1, gradient: $0.2) }
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.currentDataNumbers = data.map { _ in 0.0 }
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 8) {
                Group {
                    if self.title != nil {
                        Text(self.title!)
                            .font(.title)
                            .bold().foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if self.legend != nil {
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                    }
                }.offset(x: 0, y: 20)
                ZStack {
                    GeometryReader { reader in
                        Rectangle()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                        if self.showLegend {
                            Legend(data: self.data[0],
                                   frame: .constant(reader.frame(in: .local)), hideHorizontalLines: self.$hideHorizontalLines)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1).delay(1))
                        }
                        ZStack {
                            ForEach(0..<self.data.count) { i in
                                Line(data: self.data[i],
                                     frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - 30, height: reader.frame(in: .local).height)),
                                     touchLocation: self.$indicatorLocation,
                                     showIndicator: self.$hideHorizontalLines,
                                     minDataValue: .constant(self.globalMin),
                                     maxDataValue: .constant(self.globalMax),
                                     showBackground: false,
                                     gradient: self.data[i].getGradient(),
                                     index: i)
                                    .offset(x: 30, y: 0)
                                    .onAppear {
                                        self.showLegend = true
                                    }
                                    .onDisappear {
                                        self.showLegend = false
                                    }
                            }
                        }
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 240)
                    .offset(x: 0, y: 40)
                    MagnifierRect(currentNumbers: self.$currentDataNumbers, valueSpecifier: self.valueSpecifier)
                        .opacity(self.opacity)
                        .offset(x: self.dragLocation.x - geometry.frame(in: .local).size.width / 2, y: 36)
                }
                .frame(width: geometry.frame(in: .local).size.width, height: 240)
                .gesture(DragGesture()
                    .onChanged { value in
                        self.dragLocation = value.location
                        self.indicatorLocation = CGPoint(x: max(value.location.x - 30, 0), y: 32)
                        self.opacity = 1
                        self.hideHorizontalLines = true

                        var cdn: [Double] = []

                        for i in 0..<self.data.count {
                            let points = self.data[i].onlyPoints()
                            let stepWidth: CGFloat = (geometry.frame(in: .local).size.width - 30) / CGFloat(points.count - 1)

                            let index: Int = Int(floor((value.location.x - 15) / stepWidth))
                            if index >= 0, index < points.count {
                                cdn.append(points[index])
                            } else {
                                cdn.append(0)
                            }
                        }

                        self.currentDataNumbers = cdn
                    }
                    .onEnded { _ in
                        self.opacity = 0
                        self.hideHorizontalLines = false
                    }
                )
            }
        }
    }
}

struct MultiLineView_Previews: PreviewProvider {
    static var previews: some View {
        MultiLineChartView(data: [([8, 23, 54, 32, 12, 37, 7, 23, 43], "Test", GradientColors.orange)], title: "Line chart", legend: "Basic")
            .environment(\.colorScheme, .light)
    }
}

//
//  HistoryWindow.swift
//  CryptoRate
//
//  Created by Joseph Bourjeli on 7/9/19.
//  Copyright © 2019 Work Smarter Computing LLC. All rights reserved.
//

import Cocoa
import Charts

class HistoryWindow: NSWindowController {
    enum ChartType {
        case Delta
        case Absolute
    }

    @IBOutlet weak var chartView: LineChartView!

    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!

    var coindeskClient: CoindeskClientApi!
    var days = [String]()
    var dataset = [(x: Double, y:Double)]()
    var chartType = ChartType.Absolute

    override var windowNibName : String! {
        return "HistoryWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.title = "Historical Price Data"
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.chartView.backgroundColor = .white

        self.startDatePicker.dateValue = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        self.endDatePicker.dateValue = Date()

        self.loadHistory()
    }

    private func showAbsoluteRateGraph() {
        let chartData = self.dataset.map { (dp)  -> ChartDataEntry in
            return ChartDataEntry(x: dp.x, y: dp.y)
        }

        self.chartView.leftAxis.valueFormatter = nil
        self.updateChart(chartData: chartData)
    }

    private func showPercentDiffGraph() {
        var previousY: Double = self.dataset.first?.y ?? 0.0
        let chartData = self.dataset.map { (dp)  -> ChartDataEntry in
            guard previousY != 0 else { return ChartDataEntry(x: dp.x, y: 0) }

            let dataEntry = ChartDataEntry(x: dp.x, y: ((dp.y - previousY)/previousY)*100.0)
            previousY = dp.y

            return dataEntry
        }

        self.chartView.leftAxis.valueFormatter = YAxisValueFormatter()
        self.updateChart(chartData: chartData)
    }

    private func updateChart(chartData: [ChartDataEntry]) {
        let chartDataSet = LineChartDataSet(values: chartData, label: "Daily Price ($)")
        chartDataSet.drawVerticalHighlightIndicatorEnabled = true
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        
        self.chartView.data = LineChartData(dataSet: chartDataSet)
    }
    
    // MARK: - IB Actions
    
    @IBAction func rateTypeChanged(_ sender: NSButton) {
        let type = sender.title
        if type == "$" {
            self.chartType = .Absolute
        } else if type == "Δ" {
            self.chartType = .Delta
        }

        self.refreshGraph()
    }

    @IBAction func updateButtonPressed(_ sender: NSButtonCell) {
        self.loadHistory()
    }

    private func loadHistory() {
        let fromDate = self.startDatePicker.dateValue
        let toDate = self.endDatePicker.dateValue
        self.coindeskClient.fetchHistory(between: fromDate, and: toDate, resolve: { data in
            DispatchQueue.main.async {
                var counter = -1.0;
                self.days = []
                self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0)
                self.chartView.xAxis.valueFormatter = self
                self.chartView.xAxis.labelPosition = .bottom
                self.dataset = data.bpi.sorted(by: {$0.key < $1.key}).map { (dp)  -> (x: Double, y:Double) in
                    self.days.append(dp.key)
                    counter += 1.0
                    
                    return (x: counter, y: dp.value)
                }

                self.refreshGraph();
            }
        }, reject: { err in
            print("Error getting historical data: \(err)")
        })
    }

    private func refreshGraph() {
        switch self.chartType {
        case .Absolute:
            self.showAbsoluteRateGraph()
        case .Delta:
            self.showPercentDiffGraph()
        }
    }
}

extension HistoryWindow: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.days[Int(value)]
    }
}

class YAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let percentFormatter            = NumberFormatter()
        percentFormatter.numberStyle    = NumberFormatter.Style.percent
        percentFormatter.multiplier     = 1.00
        percentFormatter.minimumFractionDigits = 1
        percentFormatter.maximumFractionDigits = 5

        return percentFormatter.string(from: NSNumber(value: value))!
    }
}

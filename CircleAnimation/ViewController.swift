//
//  ViewController.swift
//  CircleAnimation
//
//  Created by Nguyen Huynh on 10/31/16.
//  Copyright © 2016 nguyenh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  var chart: MonitorChart!
  var chartView = SaleMonitorChartView.initFromNib() as! SaleMonitorChartView

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let monitorSegment1 = MonitorChartSegment(startValue: 0, endValue: 300, color: UIColor.redColor())
    let monitorSegment2 = MonitorChartSegment(startValue: 300, endValue: 900, color: UIColor.yellowColor())
    let monitorSegment3 = MonitorChartSegment(startValue: 900, endValue: 1000, color: UIColor.greenColor())


    chartView.updateWithActualValue(620, quota: 700, min: 0, max: 1000, segments: [monitorSegment1, monitorSegment2, monitorSegment3])
    chartView.frame.origin = CGPoint(x: 30, y: 200)

    view.addSubview(chartView)
//    let width = CGFloat(300)
//    let height = width
//    let pos = CGPoint(x: 100, y: 400)
////    chart = MonitorChart(frame: CGRect(origin: pos, size: CGSize(width: width, height: height)))
//    let monitorSegment1 = MonitorChartSegment(startValue: 0, endValue: 450, color: UIColor.redColor())
//    let monitorSegment2 = MonitorChartSegment(startValue: 450, endValue: 900, color: UIColor.yellowColor())
//    let monitorSegment3 = MonitorChartSegment(startValue: 900, endValue: 1800, color: UIColor.greenColor())
//
//    view.addSubview(chart)
//    chart.setUpChartWithSegments([monitorSegment1, monitorSegment2, monitorSegment3], actualValue: 300, minValue: 0, maxValue: 1800, saleQuota: 1500)
//    chart.drawWithAnimation()
  }

  @IBAction func redrawButtonPressed(sender: AnyObject) {
    let monitorSegment1 = MonitorChartSegment(startValue: 0, endValue: 360, color: UIColor.redColor())
    let monitorSegment2 = MonitorChartSegment(startValue: 360, endValue: 620, color: UIColor.yellowColor())
    let monitorSegment3 = MonitorChartSegment(startValue: 620, endValue: 1000, color: UIColor.greenColor())

    chartView.updateWithActualValue(200, quota: 400, min: 0, max: 1000, segments: [monitorSegment1, monitorSegment2, monitorSegment3])
  }
}


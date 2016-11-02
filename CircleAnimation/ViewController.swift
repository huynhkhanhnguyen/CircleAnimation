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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let width = CGFloat(300)
    let height = width
    let pos = CGPoint(x: 100, y: 400)
    chart = MonitorChart(frame: CGRect(origin: pos, size: CGSize(width: width, height: height)))
    let monitorSegment1 = MonitorChartSegment(startValue: 0, endValue: 450, color: UIColor.blueColor())
    let monitorSegment2 = MonitorChartSegment(startValue: 450, endValue: 900, color: UIColor.redColor())
    let monitorSegment3 = MonitorChartSegment(startValue: 900, endValue: 1800, color: UIColor.greenColor())

    view.addSubview(chart)
    chart.setUpChartWithSegments([monitorSegment1, monitorSegment2, monitorSegment3], actualValue: 300, minValue: 0, maxValue: 1800, saleQuota: 1500)
    chart.drawWithAnimation()
  }

  @IBAction func redrawButtonPressed(sender: AnyObject) {
    chart.drawWithAnimation()
  }
}


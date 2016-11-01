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
    let monitorSegment1 = MonitorChartSegment(startValue: 0, endValue: 360, color: UIColor.blueColor())
    let monitorSegment2 = MonitorChartSegment(startValue: 360, endValue: 640, color: UIColor.redColor())
    let monitorSegment3 = MonitorChartSegment(startValue: 640, endValue: 1000, color: UIColor.greenColor())

    view.addSubview(chart)
    chart.setUpChartSegments(0.0, maxValue: 1000, segments: [monitorSegment1, monitorSegment2, monitorSegment3])
    chart.drawWithAnimation()

  }

  @IBAction func redrawButtonPressed(sender: AnyObject) {
    chart.drawWithAnimation()
  }
}


//
//  SaleMonitorChartView.swift
//  CircleAnimation
//
//  Created by Nguyen Huynh on 11/2/16.
//  Copyright © 2016 nguyenh. All rights reserved.
//

import UIKit

extension CALayer {
  var borderUIColor: UIColor {
    set {
      self.borderColor = newValue.CGColor
    }
    get {
      return UIColor(CGColor: self.borderColor!)
    }
  }
}

extension UIView {
  class func initFromNib() -> UIView {
    let mainBundle = NSBundle.mainBundle()
    let className  = NSStringFromClass(self).componentsSeparatedByString(".").last ?? ""
    if ( mainBundle.pathForResource(className, ofType: "nib") != nil ) {
      let objects = mainBundle.loadNibNamed(className, owner: self, options: [:])
      for object in objects {
        if let view = object as? UIView {
          return view
        }
      }
    }
    return UIView(frame: CGRectZero)
  }
}

class SaleMonitorChartView: UIView {

  @IBOutlet weak var chartTitleLabel: UILabel!
  @IBOutlet weak var monitorChart: MonitorChart!

  @IBOutlet weak var indicatorNameLabel: UILabel!
  @IBOutlet weak var quotaLabel: UILabel!
  @IBOutlet weak var actualLabel: UILabel!
  @IBOutlet weak var forecastLabel: UILabel!
  @IBOutlet weak var attainmentLabel: UILabel!
  @IBOutlet weak var expectedAttainmentLabel: UILabel!

  func updateWithActualValue(actual: Double, quota: Double, min: Double, max: Double, segments: [MonitorChartSegment]) {
    monitorChart.setUpChartWithSegments(segments, actualValue: actual, minValue: min, maxValue: max, saleQuota: quota)
    quotaLabel.text = "$\(quota)"
    actualLabel.text = "$\(actual)"
    monitorChart.drawWithAnimation()
  }
}

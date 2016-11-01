//
//  MonitorChart.swift
//  CircleAnimation
//
//  Created by Nguyen Huynh on 10/31/16.
//  Copyright © 2016 nguyenh. All rights reserved.
//

import UIKit

struct MonitorChartSegment {
  let startValue: Double
  let endValue: Double
  let color: UIColor
}

private class MonitorChartLayer: CAShapeLayer {
  var monitorChartSegment: MonitorChartSegment!
  var animation: CAAnimation!
  var endPoint: CGFloat = 0.0

  func performAnimation() {
    removeAllAnimations()
    addAnimation(animation, forKey: "strokeEnd")
  }
}

class MonitorChart: UIView {
  var circleLayer: CAShapeLayer!
  var lineWidth = CGFloat(55)
  var animationDuration = 1.5 //secconds

  private var currentAnimationIndex = 0
  private var chartLayers: [MonitorChartLayer] = []

  func setUpChartSegments(minValue: Double, maxValue: Double, segments: [MonitorChartSegment]) {
    chartLayers.removeAll()
    let totalValueRange = maxValue - minValue
    let lineWidth = CGFloat(55)
    let arcCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
    let circlePath = UIBezierPath(arcCenter: arcCenter, radius: (frame.size.width - lineWidth - 1)/2, startAngle: CGFloat(-M_PI), endAngle: CGFloat(0), clockwise: true)

    for segment in segments {
      let circleLayer = MonitorChartLayer()
      circleLayer.path = circlePath.CGPath
      circleLayer.fillColor = UIColor.clearColor().CGColor
      circleLayer.strokeColor = segment.color.CGColor
      circleLayer.lineWidth = lineWidth
      circleLayer.strokeEnd = 0.0
      circleLayer.monitorChartSegment = segment

      let animation = CABasicAnimation(keyPath: "strokeEnd")
      animation.fromValue = (segment.startValue - minValue) / totalValueRange
      animation.toValue = (segment.endValue - minValue) / totalValueRange
      animation.duration = (segment.endValue - segment.startValue) / totalValueRange * animationDuration
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
      animation.delegate = self
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeBoth
      circleLayer.strokeStart = animation.fromValue as! CGFloat
      circleLayer.endPoint = animation.toValue as! CGFloat
      circleLayer.animation = animation

      chartLayers.append(circleLayer)
    }
  }

  override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    chartLayers[currentAnimationIndex].strokeEnd = chartLayers[currentAnimationIndex].endPoint
    CATransaction.commit()
    currentAnimationIndex += 1
    if currentAnimationIndex < chartLayers.count {
      chartLayers[currentAnimationIndex].performAnimation()
    }
  }

  func drawWithAnimation() {
    for chartLayer in chartLayers {
      if let index = layer.sublayers?.indexOf(chartLayer) {
        layer.sublayers?.removeAtIndex(index)
      }
    }
    currentAnimationIndex = 0
    chartLayers.forEach {
      $0.strokeEnd = 0
      layer.addSublayer($0)
    }
    chartLayers.first?.performAnimation()
  }
}

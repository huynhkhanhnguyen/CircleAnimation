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
  var animation: CAAnimation?
  var endPoint: CGFloat = 0.0

  func performAnimation() {
    removeAllAnimations()
    if let animation = animation {
      addAnimation(animation, forKey: "strokeEnd")
    }
  }
}

class MonitorChart: UIView {
  var circleLayer: CAShapeLayer!
  var lineWidth = CGFloat(50)
  var animationDuration = 1.5 //secconds

  private var currentAnimationIndex = 0
  private var chartLayers: [MonitorChartLayer] = []
  private var arcCenter = CGPointZero
  private var radius: CGFloat = 0
  private let borderLayer = MonitorChartLayer()

  func setUpChartSegments(minValue: Double, maxValue: Double, segments: [MonitorChartSegment]) {
    chartLayers.removeAll()
    arcCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0 + 1)
    radius = frame.size.width / 2
    let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius - lineWidth / 2, startAngle: CGFloat(-M_PI), endAngle: CGFloat(0), clockwise: true)

    for segment in segments {
      let circleLayer = MonitorChartLayer()
      circleLayer.path = circlePath.CGPath
      circleLayer.fillColor = UIColor.clearColor().CGColor
      circleLayer.strokeColor = segment.color.CGColor
      circleLayer.lineWidth = lineWidth
      circleLayer.strokeEnd = 0.0
      circleLayer.monitorChartSegment = segment

      let animation = createStrokeEndAnimationForSegment(segment, minValue: minValue, maxValue: maxValue)
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
    } else {
      addBorder()
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
    borderLayer.performAnimation()
    chartLayers.first?.performAnimation()
  }

  private func createStrokeEndAnimationForSegment(segment: MonitorChartSegment, minValue: Double, maxValue: Double) -> CABasicAnimation {
    let totalValueRange = maxValue - minValue
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = (segment.startValue - minValue) / totalValueRange
    animation.toValue = (segment.endValue - minValue) / totalValueRange
    animation.duration = (segment.endValue - segment.startValue) / totalValueRange * animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    animation.delegate = self
    animation.removedOnCompletion = false
    animation.fillMode = kCAFillModeBoth

    return animation
  }

  private func addBorder() {
    let borderPath = UIBezierPath()
    borderPath.moveToPoint(CGPoint(x: arcCenter.x - radius + lineWidth - 1, y: arcCenter.y))
    borderPath.addArcWithCenter(CGPoint(x: arcCenter.x, y: arcCenter.y), radius: radius - lineWidth, startAngle: CGFloat(-M_PI), endAngle: 0, clockwise: true)
    borderPath.addLineToPoint(CGPoint(x: arcCenter.x + radius, y: arcCenter.y))
    borderPath.addArcWithCenter(CGPoint(x: arcCenter.x, y: arcCenter.y), radius: radius, startAngle: 0, endAngle: CGFloat(-M_PI), clockwise: false)
    borderPath.addLineToPoint(CGPoint(x: arcCenter.x - radius + lineWidth - 1, y: arcCenter.y))
    borderPath.closePath()

    borderLayer.path = borderPath.CGPath
    borderLayer.fillColor = UIColor.clearColor().CGColor
    borderLayer.strokeColor = UIColor.grayColor().CGColor
    borderLayer.lineWidth = 1
    borderLayer.strokeEnd = 1.0
    layer.addSublayer(borderLayer)
  }
}

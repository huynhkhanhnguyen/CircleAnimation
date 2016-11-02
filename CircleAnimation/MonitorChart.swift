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

  class func createLayerForSegment(segment: MonitorChartSegment, path: UIBezierPath, lineWidth: CGFloat) -> MonitorChartLayer {
    let circleLayer = MonitorChartLayer()
    circleLayer.path = path.CGPath
    circleLayer.fillColor = UIColor.clearColor().CGColor
    circleLayer.strokeColor = segment.color.CGColor
    circleLayer.lineWidth = lineWidth
    circleLayer.strokeEnd = 0.0
    circleLayer.monitorChartSegment = segment
    return circleLayer
  }

  func updateWithAnimation(animation: CABasicAnimation) {
    strokeStart = animation.fromValue as! CGFloat
    endPoint = animation.toValue as! CGFloat
    self.animation = animation
  }

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
  var animationDuration = 1.5 //seconds

  private var currentAnimationIndex = 0
  private var chartLayers: [MonitorChartLayer] = []
  private var arcCenter = CGPointZero
  private var radius: CGFloat = 0
  private var actual: Double = 0
  private var min: Double = 0
  private var max: Double = 0
  private var quota: Double = 0
  private let pointerLayer = CAShapeLayer()
  private let borderLayer = MonitorChartLayer()

  func setUpChartWithSegments(segments: [MonitorChartSegment], actualValue: Double, minValue: Double, maxValue: Double, saleQuota: Double) {
    backgroundColor = UIColor.grayColor()
    actual = actualValue
    min = minValue
    max = maxValue
    quota = saleQuota
    chartLayers.removeAll()

    arcCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0 + 1)
    radius = frame.size.width / 2
    let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius - lineWidth / 2, startAngle: CGFloat(-M_PI), endAngle: CGFloat(0), clockwise: true)

    for segment in segments {
      let circleLayer = MonitorChartLayer.createLayerForSegment(segment, path: circlePath, lineWidth: lineWidth)
      let animation = createStrokeEndAnimationForSegment(segment, minValue: minValue, maxValue: maxValue)
      circleLayer.updateWithAnimation(animation)
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
      addBorderAndQuota()
      addPointer()
      addLabels()
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

  private func addLabels() {
    let padding: CGFloat = 10
    let minLabel = UILabel()
    minLabel.text = "$\(min)"
    minLabel.sizeToFit()
    minLabel.frame.origin = CGPoint(x: arcCenter.x - radius + lineWidth + padding, y: arcCenter.y - minLabel.frame.size.height)

    let maxLabel = UILabel()
    maxLabel.text = "$\(max)"
    maxLabel.sizeToFit()
    maxLabel.frame.origin = CGPoint(x: arcCenter.x + radius - lineWidth - maxLabel.frame.size.width - padding, y: arcCenter.y - maxLabel.frame.size.height)

    let middleLabel = UILabel()
    middleLabel.text = "$\((max - min))"
    middleLabel.sizeToFit()
    middleLabel.frame.origin = CGPoint(x: arcCenter.x - middleLabel.frame.size.width / 2, y: arcCenter.y - radius + lineWidth + padding)

    let quotaLabel = UILabel()
    quotaLabel.text = "Quota \n $640"
    quotaLabel.numberOfLines = 2
    quotaLabel.sizeToFit()
    let radian = (quota - (max - min)) / (max - min) * M_PI
    let quotaEndX = arcCenter.x + CGFloat(cos(radian)) * (radius)
    let quotaEndY = arcCenter.y + CGFloat(sin(radian)) * (radius) - 30
    quotaLabel.frame = CGRect(origin: CGPoint(x: quotaEndX, y: quotaEndY), size: quotaLabel.frame.size)

    let actualLabel = UILabel()
    actualLabel.text = "Actual \n $350"
    actualLabel.numberOfLines = 2
    actualLabel.sizeToFit()
    actualLabel.frame.origin = CGPoint(x: arcCenter.x - actualLabel.frame.size.width / 2, y: arcCenter.y - 60)

    [minLabel, maxLabel, middleLabel, quotaLabel, actualLabel].forEach { addSubview($0) }
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

  private func addPointer() {
    let pointerRadius = CGFloat(10)
    let pointerPath = UIBezierPath()
    pointerPath.addArcWithCenter(arcCenter, radius: pointerRadius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)

    pointerPath.moveToPoint(arcCenter)
    pointerPath.lineWidth = 2
    let radiusValue = radius - pointerRadius
    let minMaxGap = (max - min)
    let radian = (actual - minMaxGap) / minMaxGap * M_PI
    let posX = arcCenter.x + CGFloat(cos(radian)) * radiusValue
    let posY = arcCenter.y + CGFloat(sin(radian)) * radiusValue
    pointerPath.addLineToPoint(CGPoint(x: posX, y: posY))

    pointerLayer.path = pointerPath.CGPath
    pointerLayer.strokeColor = UIColor.blackColor().CGColor
    pointerLayer.lineWidth = 3
    pointerLayer.fillColor = UIColor.blackColor().CGColor
    pointerLayer.removeFromSuperlayer()
    layer.addSublayer(pointerLayer)
  }

  private func addBorderAndQuota() {
    let borderPath = UIBezierPath()
    borderPath.moveToPoint(CGPoint(x: arcCenter.x - radius + lineWidth - 1, y: arcCenter.y))
    borderPath.addArcWithCenter(CGPoint(x: arcCenter.x, y: arcCenter.y), radius: radius - lineWidth, startAngle: CGFloat(-M_PI), endAngle: 0, clockwise: true)
    borderPath.addLineToPoint(CGPoint(x: arcCenter.x + radius, y: arcCenter.y))
    borderPath.addArcWithCenter(CGPoint(x: arcCenter.x, y: arcCenter.y), radius: radius, startAngle: 0, endAngle: CGFloat(-M_PI), clockwise: false)
    borderPath.addLineToPoint(CGPoint(x: arcCenter.x - radius + lineWidth - 1, y: arcCenter.y))

    let radian = (quota - (max - min)) / (max - min) * M_PI
    let quotaStartX = arcCenter.x + CGFloat(cos(radian)) * (radius - lineWidth)
    let quotaStartY = arcCenter.y + CGFloat(sin(radian)) * (radius - lineWidth)
    let quotaEndX = arcCenter.x + CGFloat(cos(radian)) * (radius - 10)
    let quotaEndY = arcCenter.y + CGFloat(sin(radian)) * (radius - 10)
    borderPath.moveToPoint(CGPoint(x: quotaStartX, y: quotaStartY))
    borderPath.addLineToPoint(CGPoint(x: quotaEndX, y: quotaEndY))

    borderPath.closePath()

    borderLayer.path = borderPath.CGPath
    borderLayer.fillColor = UIColor.clearColor().CGColor
    borderLayer.strokeColor = UIColor.grayColor().CGColor
    borderLayer.lineWidth = 1
    borderLayer.strokeEnd = 1.0
    borderLayer.removeFromSuperlayer()
    layer.addSublayer(borderLayer)
  }
}

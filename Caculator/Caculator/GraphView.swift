//
//  GraphView.swift
//  Caculator
//
//  Created by certainly on 2017/3/29.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getBounds() -> CGRect
    func getYCoordinate(_ x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {

    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale = CGFloat(Constants.Drawing.pointsPerUnit) { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color = UIColor.black { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var dataSource: GraphViewDataSource?
    private let drawer = AxesDrawer(color: UIColor.blue)
    
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        color.set()
        
        pathForFunction().stroke()
      
        drawer.drawAxes(in: dataSource?.getBounds() ?? bounds, origin: origin, pointsPerUnit: scale)
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        
        guard let data = dataSource else {
            NSLog(Constants.Error.data)
            return path
        }
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        let width = Int(bounds.size.width * scale)
        for pixel  in 0...width {
            point.x = CGFloat(pixel) / scale
            
            if let y = data.getYCoordinate((point.x - origin.x) / scale) {
                if !y.isNormal && !y.isZero {
                    pathIsEmpty = true
                    continue
                }
                
                point.y = origin.y - y * scale
                
                if pathIsEmpty {
                    path.move(to: point)
                    pathIsEmpty = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        
        
        path.lineWidth = lineWidth
        return path
        
    }
    
    func doubleTap(_ recognizer: UITapGestureRecognizer)  {
        if recognizer.state == .ended {
            origin = recognizer.location(in: self)
        }
    }
    
    func zoom(_ recognizer: UIPinchGestureRecognizer)  {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func move(_ recognizer: UIPanGestureRecognizer)  {
        switch recognizer.state {
        case .changed:
            fallthrough
        case .ended:
            let translation = recognizer.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            
            recognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    

}

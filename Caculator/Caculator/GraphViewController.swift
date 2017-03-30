//
//  GraphViewController.swift
//  Caculator
//
//  Created by certainly on 2017/3/30.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom(_:))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.move(_:))))
            let recognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.doubleTap(_:)))
            recognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(recognizer)
        }
    }
    
    func getBounds() -> CGRect {
        return navigationController?.view.bounds ?? view.bounds
    }
    
    func getYCoordinate(_ x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: ((CGFloat) -> Double)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

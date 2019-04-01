//
//  ViewController.swift
//  ZoomDemo
//
//  Created by nguyen.ngoc.ban on 4/1/19.
//  Copyright © 2019 nguyen.ngoc.ban. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var zoomView: ZoomImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        zoomView.loadImage(image: UIImage(named: "0"))
        // Do any additional setup after loading the view, typically from a nib.
    }


}


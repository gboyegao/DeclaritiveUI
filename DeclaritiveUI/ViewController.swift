//
//  ViewController.swift
//  DeclaritiveUI
//
//  Created by Adegboyega Olusunmade on 03/03/2019.
//  Copyright © 2019 Adegboyega Olusunmade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navigationManager = NavigationManager()
        
        navigationManager.fetch(completionHandler: {
            initialScreen in
                let vc = TableScreen(screen: initialScreen)
                vc.navigationManager = navigationManager
            navigationController?.viewControllers = [vc]
        })
    }
    

}


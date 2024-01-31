//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Aleksey Kolesnikov on 31.01.2024.
//

import UIKit

final class CalculationsListViewController: UIViewController {
    @IBOutlet weak var calculationLabel: UILabel!
    
    var result: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculationLabel.text = result
    }
}

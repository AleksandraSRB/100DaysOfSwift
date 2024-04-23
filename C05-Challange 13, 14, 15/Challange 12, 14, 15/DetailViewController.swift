//
//  DetailViewController.swift
//  Challange 12, 14, 15
//
//  Created by Aleksandra Sobot on 28.12.23..
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var detailFlagImageView: UIImageView!
    @IBOutlet var capitalLabel: UILabel!
    @IBOutlet var populationLabel: UILabel!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    
    var country: Country!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = country.name.official
        
        navigationItem.largeTitleDisplayMode = .never
        
        setDetailView()
    }
    
    func setDetailView() {
        detailFlagImageView.image = UIImage(named: country.flagImageName)
        detailFlagImageView.layer.borderWidth = 2
        detailFlagImageView.layer.borderColor = UIColor.lightGray.cgColor
        detailFlagImageView.layer.cornerRadius = 4
        
        capitalLabel.text = "Capital: \(country.capital.joined(separator: ","))"
        populationLabel.text = "Population: \(country.population.formatted())"
        countryCodeLabel.text = "Country code: \(country.code)"
        regionLabel.text = "Country region: \(country.region)"
    }
    

}

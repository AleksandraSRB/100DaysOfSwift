//
//  ViewController.swift
//  Challange 12, 14, 15
//
//  Created by Aleksandra Sobot on 27.12.23..
//

import UIKit

class ViewController: UITableViewController {
    
    var countries: [Country] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        DispatchQueue.global(qos: .userInitiated).async {
                   self.fetchCountries()
               }
    }
    
    func fetchCountries() {
          let joinedCodes = Country.countryCodes.joined(separator: ",")
          
          guard let url = URL(string: "https://restcountries.com/v3.1/alpha?codes=\(joinedCodes)") else {
              fatalError("Invalid URL provided for countries.")
          }
          
          let task = URLSession.shared.dataTask(with: url) { data, _, error in
              guard error == nil else {
                  print(error!.localizedDescription)
                  return
              }
              
              if let data = data {
                  do {
                      self.countries = try JSONDecoder().decode([Country].self, from: data)
                      
                      DispatchQueue.main.async {
                          self.countries.sort { $0.name.common < $1.name.common }
                          
                          self.tableView.reloadData()
                      }
                  } catch {
                      print(error.localizedDescription)
                  }
              }
          }
          
          task.resume()
      }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
      
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath) as? CountryCell else {
            fatalError("Couldn't load Country cell")}
        
        let country = countries[indexPath.row]
        
        cell.flagImageView.image = UIImage(named: country.flagImageName)
        cell.flagImageView.layer.cornerRadius = 2
        cell.flagImageView.layer.borderWidth = 1
        cell.flagImageView.layer.borderColor = UIColor.lightGray.cgColor
            
        cell.label.text = country.name.common

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = countries[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController
        vc?.country = country
        
        navigationController?.pushViewController(vc!, animated: true)
    }


}


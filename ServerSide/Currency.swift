//
//  Currency.swift
//  CoinFlipper
//
//  Created by Quercy on 04.05.2024.
//

import Foundation

struct Currency: Codable, Comparable {
    var date: String
    var base: String
    var rates = [String: Double]()
    
    static func < (lhs: Currency, rhs: Currency) -> Bool{
                lhs.base < rhs.base
        }
}

class Currencies: ObservableObject {
    @Published var items = [Currency]()
    
    var codes: [String] {
        var allCodes: [String] = []
        for currency in items {
          allCodes.append(contentsOf: currency.rates.keys)
        }
        return allCodes
    }
    
    init(items: [Currency] = [Currency]()) {
        self.items = items
    }
    
    func removeCurrency(_ item: Currency) {
            var indexes = IndexSet()
        if let index = items.firstIndex(of: item) {
                indexes.insert(index)
            }
        items.remove(atOffsets: indexes)
        }
    
}

func apiRequest(url: String, completion: @escaping (Currency) -> ()) {
  guard let urlObject = URL(string: url) else {
    print("Error: Invalid URL provided")
    return
  }
  
  let session = URLSession.shared
  let task = session.dataTask(with: urlObject) { data, response, error in
    if let error = error {
      print("Error fetching data: \(error.localizedDescription)")
      return
    }
    
    guard let data = data else {
      print("Error: No data received from the API")
      return
    }
    
    do {
      let decoder = JSONDecoder()
      let currency = try decoder.decode(Currency.self, from: data)
      completion(currency)
    } catch {
      print("Error decoding data: \(error.localizedDescription)")
    }
  }
  task.resume()
}

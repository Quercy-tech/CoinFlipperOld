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

    static func < (lhs: Currency, rhs: Currency) -> Bool {
        lhs.base < rhs.base
    }
}

class Currencies: ObservableObject {
    @Published var items = [Currency]() {
        didSet {
            saveCurrencies()
        }
    }

    var codes: [String] {
        var allCodes: [String] = []
        for currency in items {
            allCodes.append(contentsOf: currency.rates.keys)
        }
        return allCodes
    }

    init(items: [Currency] = [Currency]()) {
        loadCurrencies()
    }

    func removeCurrency(_ item: Currency) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }

    func saveCurrencies() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            UserDefaults.standard.set(encoded, forKey: "CurrencyList")
        }
    }

    func loadCurrencies() {
        if let savedData = UserDefaults.standard.data(forKey: "CurrencyList") {
            let decoder = JSONDecoder()
            if let decodedItems = try? decoder.decode([Currency].self, from: savedData) {
                self.items = decodedItems
            }
        }
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


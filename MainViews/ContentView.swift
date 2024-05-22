//
//  ContentView.swift
//  CoinFlipper
//
//  Created by Quercy on 04.05.2024.
//
import SwiftUI

struct ContentView: View {
    
    @State private var base = "UAH"
    @State private var amount = "1.0"
    @State private var showingAddCurrency = false
    @FocusState private var inputIsFocused: Bool
    
    @State private var showingDates = false
    @State private var showingEditCurrency = false
    
    @ObservedObject var CurrencyList = Currencies()
    @State private var codesAndValues = [String: Double]()
    @State private var codesAndNames = [String: String]()
    @State private var shouldMakeRequest = true
    
    func makeRequest(currencies: [String]) {
        apiRequest(url: "https://api.currencybeacon.com/v1/latest?api_key=sn89Py12cds8QIa1wtjYMBpO6XVKYeWl&base=\(base)") { currency in
            CurrencyList.items = []
            codesAndValues = [:]
            codesAndNames = [:]
            
            for currency in currency.rates {
                codesAndValues[currency.key] = currency.value
                codesAndNames[currency.key] = currencyName(currencyCode: currency.key)
                if currencies.contains(currency.key) {
                    CurrencyList.items.append(Currency(date: Date.now.formatted(), base: base, rates: [currency.key: currency.value]))
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(CurrencyList.items.sorted(), id: \.rates) { currency in
                    let rateKeys = Array(currency.rates.keys)
                    ForEach(rateKeys, id: \.self) { key in
                        NavigationLink(destination: EditCurrencyView(currency: self.$CurrencyList.items[self.CurrencyList.items.firstIndex(of: currency)!], CurrencyList: CurrencyList, base: $base, codesAndNames: $codesAndNames, newFullName: codesAndNames[key] ?? "What")) {
                            VStack(alignment: .leading) {
                                Text("Rates:")
                                ForEach(rateKeys, id: \.self) { key in
                                    let currencyAmount = (currency.rates[key] ?? 0.0) * (Double(amount) ?? 0.0)
                                    Text("\(key): \(currencyAmount.formatted())")
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    CurrencyList.removeCurrency(currency)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            
            VStack {
                TextField("Enter an amount", text: $amount)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .cornerRadius(20.0)
                    .padding()
                    .keyboardType(.decimalPad)
                    .focused($inputIsFocused)
                
                TextField("Enter a currency", text: $base)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .cornerRadius(20.0)
                    .padding()
                    .focused($inputIsFocused)
                
                Button("Convert!") {
                    inputIsFocused = false
                    makeRequest(currencies: CurrencyList.codes)
                }.padding()
            }
            .navigationTitle("CoinFlipper Pro")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddCurrency = true }) {
                        Label("Add a currency", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingDates = true }) {
                        Label("Check currency on a certain day", systemImage: "calendar")
                    }
                }
            }
            .sheet(isPresented: $showingAddCurrency) {
                AddView(CurrencyList: CurrencyList, base: $base, codesAndValues: $codesAndValues, codesAndNames: $codesAndNames)
            }
            .sheet(isPresented: $showingDates) {
                CalendarView(base: $base, amount: $amount, CurrencyList: CurrencyList)
            }
        }
        .onAppear {
            if shouldMakeRequest {
                makeRequest(currencies: CurrencyList.codes)
                shouldMakeRequest = false
            }
        }
    }
    
    func currencyName(currencyCode: String) -> String {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currencyCode]))
        return locale.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(CurrencyList: Currencies())
    }
}



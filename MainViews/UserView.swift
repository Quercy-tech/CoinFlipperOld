//
//  ContentView.swift
//  CoinFlipper
//
//  Created by Quercy on 04.05.2024.
//
import SwiftUI

struct UserView: View {
    
    
    @State private var base = "UAH"
    @State private var amount = "1.0"
    @State private var showingAddCurrency = false
    @State private var enteredCurrencies = ["USD", "EUR", "GBP"]
    @FocusState private var inputIsFocused: Bool
    
    @State private var showingDates = false
    
    @ObservedObject var CurrencyList: Currencies
    @State private var codesAndValues = [String: Double]()
    
    @State private var count = 0
    
    func makeRequest(currencies: [String]) {
        apiRequest(url: "https://api.currencybeacon.com/v1/latest?api_key=sn89Py12cds8QIa1wtjYMBpO6XVKYeWl&base=\(base)") { currency in
            CurrencyList.items = []
            
            for currency in currency.rates {
                codesAndValues[currency.key] = currency.value
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

                VStack(alignment: .leading) { // Use VStack for better formatting
                  Text("Rates:") // Label for the rates section
                    
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
               
                Button("Convert") {
                    inputIsFocused = false
                }.padding()
            }
            .onAppear {
                makeRequest(currencies: CurrencyList.codes)
               
            }
            .onChange(of: base, {
                makeRequest(currencies: CurrencyList.codes)
            })
            
            .navigationTitle("CoinFlipper")
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Check currency in certain day", systemImage: "calendar") {
                        showingDates = true
                    }
                }
            }
            .sheet(isPresented: $showingDates) {
                CalendarView(base: $base, amount: $amount, CurrencyList: CurrencyList)
            }
        }
    }
}

#Preview {
    UserView(CurrencyList: Currencies())
}


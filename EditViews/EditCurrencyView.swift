//
//  EditCurrencyView.swift
//  CoinFlipper
//
//  Created by Quercy on 18.05.2024.
//

import SwiftUI

struct EditCurrencyView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var currency: Currency
    @ObservedObject var CurrencyList: Currencies
    
    @Binding var base: String
    @Binding var codesAndNames: [String: String]
    @State var selectedCurrency: String
    @State var newFullName: String
    @State var selectedValue: Double
    
    
    init(currency: Binding<Currency>, CurrencyList: Currencies, base: Binding<String>, codesAndNames: Binding<[String: String]>, newFullName: String) {
        self._currency = currency
        self.CurrencyList = CurrencyList
        self._base = base
        self._codesAndNames = codesAndNames
        self._selectedCurrency = State(initialValue: currency.wrappedValue.rates.keys.first ?? "")
        self._selectedValue = State(initialValue: currency.wrappedValue.rates.values.first ?? 0.0)
        self._newFullName = State(initialValue: newFullName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Currency")) {
                    TextField("Currency name", text: $newFullName)
                    TextField("Currency rate", value: $selectedValue, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Currency")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
//                        currency.rates[selectedCurrency] = selectedValue
                        codesAndNames[selectedCurrency] = newFullName
                        CurrencyList.removeCurrency(currency)
                        CurrencyList.items.append(Currency(date: Date.now.formatted(), base: base, rates: [selectedCurrency: selectedValue]))
                        dismiss()
                        
                    }
                }
            }
        }
    }
}

#Preview {
    EditCurrencyView(currency: .constant(Currency(date: Date.now.formatted(), base: "UAH", rates: ["USD":0.25])), CurrencyList: Currencies(), base: .constant("UAH"), codesAndNames: .constant(["USD": "Ukranian Hryvna"]), newFullName: "Ukranian Hryvna")
}

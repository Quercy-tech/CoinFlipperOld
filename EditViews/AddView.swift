import FlagsKit
import SwiftUI

struct AddView: View {
    @ObservedObject var CurrencyList: Currencies
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedCurrency = "UAH"
    @State private var selectedValue = 1.0
    @State private var FullCurrencyName = "Ukrainian Hryvnia"
    @State private var searchText = ""
    @Binding var base: String
    @Binding var codesAndValues: [String: Double]
    @Binding var codesAndNames: [String: String]
    
    var filteredCodesAndNames: [String: String] {
        if searchText.isEmpty {
            return codesAndNames
        } else {
            return codesAndNames.filter { $0.key.localizedCaseInsensitiveContains(searchText) || $0.value.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search currency...", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Picker(selection: $selectedCurrency, label: Text("Currency")) {
                    ForEach(Array(filteredCodesAndNames.keys).sorted(), id: \.self) { currency in
                        HStack {
                            Text("\(Country.flagEmoji(forCurrencyCode: currency)) \(filteredCodesAndNames[currency] ?? "Unknown Currency") \(currency)")
                        }
                        .tag(currency)
                    }
                    .onChange(of: filteredCodesAndNames) { _ in
                        if let firstCurrency = filteredCodesAndNames.keys.sorted().first {
                            selectedCurrency = firstCurrency
                        }
                    }
                }
                .pickerStyle(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Add a currency")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let selectedValue = codesAndValues[selectedCurrency] {
                            if !CurrencyList.codes.contains(selectedCurrency) {
                                CurrencyList.items.append(Currency(date: Date.now.formatted(), base: base, rates: [selectedCurrency: selectedValue]))
                            }
                        }
                        
                        dismiss()
                    }
                }
            }
        }
    }

    func currencyName(currencyCode: String) -> String {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currencyCode]))
        return locale.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(CurrencyList: Currencies(), base: .constant("UAH"), codesAndValues: .constant(["UAH": 1.0]), codesAndNames:.constant(["UAH": "Ukrainian Hryvnia"]))
    }
}

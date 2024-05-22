//
//  CalendarView.swift
//  CoinFlipper
//
//  Created by Quercy on 09.05.2024.
//

import SwiftUI



struct CalendarView: View {
    
    @State var enteredDate = Date.now
    @State var currencyList = [String]()
    @State private var enteredValue = "1.0"
    
    @Binding var base:String
    @Binding var amount:String
    @ObservedObject var CurrencyList: Currencies
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: enteredDate)
      }
    
    var body: some View {
        NavigationStack {
            DatePicker("Please enter a date", selection: $enteredDate, in: Date.now.addingTimeInterval(-86400 * 3650 * 3.3)...Date.now , displayedComponents: [.date])
                .labelsHidden()
                .datePickerStyle(GraphicalDatePickerStyle())
                .onAppear{
                    makeTimeRequest(date:FormatDate(date: enteredDate), currencies: CurrencyList.codes)
                }
            List {
                ForEach(currencyList, id: \.self) { currency in
                    Text(currency)
                }
                
                .onChange(of: enteredDate, { oldValue, newValue in
                    makeTimeRequest(date: FormatDate(date: newValue), currencies: CurrencyList.codes)
                })
                
                
            }
            .navigationTitle("Enter a date: ")
        }
        
    }
    
    func FormatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
        
    
    func makeTimeRequest(date: String, currencies: [String]) {
        apiRequest(url: "https://api.currencybeacon.com/v1/historical?api_key=sn89Py12cds8QIa1wtjYMBpO6XVKYeWl&base=\(base)&date=\(date)") { currency in
            var tempList = [String]()
            
            for currency in currency.rates {
                if currencies.contains(currency.key) {
                    tempList.append("\(currency.key) \(String(format: "%.4f", currency.value * (Double(amount) ?? 0.0)))")
                }
                tempList.sort()
            }
            currencyList.self = tempList
        }
    }
}

#Preview {
    CalendarView(base: .constant("UAH"), amount: .constant("1000.0"), CurrencyList: Currencies())
}

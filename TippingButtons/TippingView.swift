import SwiftUI

struct TippingSuggestion: Hashable {
    
    let id: Int
    let tip: String
}

/// View model acts as observable object which holds necessary
/// information for every view in the hierarchy
/// Properties which get updated will trigger an update on every view that holds this VM
class TippingViewModel: ObservableObject {
    
    @Published var tip: String = ""
    @Published var tippingParameters: String = ""
    @Published var selectedPam: String = "Apple Pay"
    @Published var tippingPaymentMethods: [String] = ["Apple Pay", "PayPal", "SEPA"]
    @Published var persistentStore: String = ""
    @Published var suggestions = [TippingSuggestion(id: 0, tip: "3"), TippingSuggestion(id: 1, tip: "5"), TippingSuggestion(id: 2, tip: "7")]
    @Published var didSend: Bool = false
    
    init() {

    }
    
    func cancelTip() {
        /// dismiss tipping view
    }
    
    func sendTip() {
        /// network request for sending tip to backend
        didSend = true
    }
    
    func configurePam() {
        
    }
}

struct TippingView: View {
    
    @StateObject var tippingViewModel = TippingViewModel()
    
    @State var selection: Int = 0
    @State var isSuggestionSelected: Bool = true
    @State var textFieldTip: String = ""
    
    var body: some View {
        if !tippingViewModel.didSend {
            VStack(alignment: .center, spacing: 40.0) {
                Text("Tip the driver").font(.system(size: 28, weight: .bold, design: .default))
                SuggestionButtons(selection: $selection, selected: $isSuggestionSelected, textFieldTip: $textFieldTip)
                TippingTextField(textFieldTip: $textFieldTip, isSuggestionSelected: $isSuggestionSelected)
                ActionButtons()
            }
            .environmentObject(tippingViewModel)
        } else {
            VStack {
                SuccessView()
                Button {
                    tippingViewModel.didSend = false
                } label: {
                    Text("Back")
                }
            }
        }
    }
}

struct TippingTextField: View {
    
    @EnvironmentObject var tippingViewModel: TippingViewModel
    
    @Binding var textFieldTip: String
    @Binding var isSuggestionSelected: Bool
    
    var body: some View {
        VStack {
            Text("Or enter a custom amount").font(.system(size: 18, weight: .medium, design: .default))
            TextField("0.00 €", text: $textFieldTip)
                .onChange(of: textFieldTip) { newValue in
                    isSuggestionSelected = false
                    tippingViewModel.tip = !newValue.isEmpty ? newValue : ""
                }
            .font(.system(size: 16, weight: .bold, design: .default))
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .padding()
            Text("minimum amount 0.50 €").font(.system(size: 13, design: .rounded))
                .foregroundColor(Color(#colorLiteral(red: 0.658826232, green: 0.6588104367, blue: 0.658818841, alpha: 1)))
        }
    }
}

struct SuggestionButtons: View {
    
    @EnvironmentObject var tippingViewModel: TippingViewModel
    
    @Binding var currentlySelectedId: Int
    @Binding var selected: Bool
    @Binding var textFieldTip: String
    
    init(selection: Binding<Int>, selected: Binding<Bool>, textFieldTip: Binding<String>) {
        self._currentlySelectedId = selection
        self._selected = selected
        self._textFieldTip = textFieldTip
    }
    
    var body: some View {
        HStack {
            ForEach(tippingViewModel.suggestions, id: \.self) { suggestion in
                SuggestionButton(currentlySelectedId: $currentlySelectedId, isSelected: $selected, textFieldTip: $textFieldTip, buttonId: suggestion.id, suggestion: suggestion.tip)
            }
        }
    }
}

struct SuggestionButton: View {
    
    @EnvironmentObject var tippingViewModel: TippingViewModel
    
    @Binding var currentlySelectedId: Int
    @Binding var isSelected: Bool
    @Binding var textFieldTip: String
    
    let buttonId: Int
    let suggestion: String
    
    var body: some View {
        Button(action: {
            textFieldTip = ""
            isSelected = true
            currentlySelectedId = buttonId
            tippingViewModel.tip = tippingViewModel.suggestions[currentlySelectedId].tip
            }) {
                Text("\(suggestion) €").fontWeight(.bold)
                .frame(width: 100, height: 100)
                .foregroundColor(isSelected && buttonId == currentlySelectedId && textFieldTip.isEmpty ? .white : .black)
                .clipShape(Circle())
        }
        .background((buttonId == currentlySelectedId && isSelected && textFieldTip.isEmpty ? Color(#colorLiteral(red: 0.5684229136, green: 0.2000597119, blue: 0.9333202243, alpha: 1)) : .white))
        .cornerRadius(25)
        .shadow(color: Color(#colorLiteral(red: 0.8980428576, green: 0.8980216384, blue: 0.8980329633, alpha: 1)), radius: 3, x: -1, y: 1)
        .onAppear {
            if isSelected {
                tippingViewModel.tip = tippingViewModel.suggestions[currentlySelectedId].tip
            }
        }
    }
}

struct ActionButtons: View {
    
    @EnvironmentObject var tippingViewModel: TippingViewModel
    
    var body: some View {
        HStack(spacing: 60.0) {
            Button {
                tippingViewModel.cancelTip()
            } label: {
                Text("Cancel").font(.headline).bold()
                    .foregroundColor(Color(#colorLiteral(red: 0.5684229136, green: 0.2000597119, blue: 0.9333202243, alpha: 1)))
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(#colorLiteral(red: 0.8588270545, green: 0.8588067293, blue: 0.858817637, alpha: 1)), lineWidth: 0.5))
            }
            Button {
                tippingViewModel.sendTip()
            } label: {
                Text("Pay \(!tippingViewModel.tip.isEmpty ? tippingViewModel.tip : "0") €").font(.headline).bold()
                    .foregroundColor(!tippingViewModel.tip.isEmpty ? Color(#colorLiteral(red: 0.5684229136, green: 0.2000597119, blue: 0.9333202243, alpha: 1)) : Color.gray)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(#colorLiteral(red: 0.8588270545, green: 0.8588067293, blue: 0.858817637, alpha: 1)), lineWidth: 0.5))
            }.disabled(tippingViewModel.tip.isEmpty)
        }
    }
}

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isPresented: Bool
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Search Location", text: $searchText)
                .focused($isTextFieldFocused)
                .font(.theme.regular(size: 15))
                .foregroundStyle(Color(.defaultText))
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(.grayText))
        }
        .onChange(of: isTextFieldFocused) { _, newValue in
            isPresented = newValue
        }
        .onChange(of: isPresented, { oldValue, newValue in
            isTextFieldFocused = newValue
        })
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.background))
        )
        .padding()
    }
}

#Preview {
    SearchBarView(
        searchText: .constant(""),
        isPresented: .constant(false)
    )
}


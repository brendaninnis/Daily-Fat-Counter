
import SwiftUI

struct CounterButton: View {
    let value: Int
    var text: String {
        String(format: "+ %dg", value)
    }

    let action: () -> Void

    struct OutlineButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration
                .label
                .font(.title3.bold())
                .foregroundColor(Color.ui.onGreen)
                .padding()
                .frame(
                    minWidth: 90,
                    minHeight: 60
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: 8,
                        style: .continuous
                    ).fill(
                        configuration.isPressed ?
                            Color.ui.paleYellow
                            : Color.ui.paleGreen
                    )
                )
                .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
        }
    }

    var body: some View {
        Button(text, action: action)
            .buttonStyle(OutlineButton())
    }
}

struct CounterButton_Previews: PreviewProvider {
    static var previews: some View {
        CounterButton(value: 1) {}
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))

        CounterButton(value: 1) {}
            .preferredColorScheme(.dark)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
    }
}

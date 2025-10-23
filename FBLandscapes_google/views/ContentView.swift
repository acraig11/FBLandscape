import SwiftUI

// MARK: - Tabs
enum AppTab: Int, CaseIterable, Identifiable {
    case home, about, booking
    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .home:        return "house.fill"
        case .about:       return "person.circle.fill"
        case .booking:     return "calendar.circle.fill"
      //  case .partner:     return "person.2.circle"
      //  case .realEstate:  return "house.circle"
      //  case .artAndToys:  return "paintpalette" // correct SF Symbol
        }
    }

    var title: String {
        switch self {
        case .home:        return "Home"
        case .about:       return "About"
        case .booking:     return "Booking"
      //  case .partner:     return "Partner"
       // case .realEstate:  return "Real Estate"
       // case .artAndToys:  return "Art"
        }
    }
}

// MARK: - Root
struct ContentView: View {
    @State private var tab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            viewForTab(tab)                     // main content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selection: $tab)       // compact custom bar (6 items)
                .background(Color(.systemBackground))
                .overlay(Divider(), alignment: .top)
        }
    }

    // Return AnyView to keep the type checker relaxed
    private func viewForTab(_ tab: AppTab) -> AnyView {
        switch tab {
        case .home:        return AnyView(HomeView())
        case .about:       return AnyView(AboutView())
        case .booking:     return AnyView(BookingView())
      //  case .partner:     return AnyView(PartnerView())
      //  case .realEstate:  return AnyView(RealEstateView())
     //   case .artAndToys:  return AnyView(art_and_toys())
        }
    }
}

// MARK: - Custom Tab Bar
private struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabItem(
                    tab: tab,
                    isSelected: selection == tab,
                    action: { selection = tab }
                )
                .frame(maxWidth: .infinity) // equal width for all 6
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
    }
}

// MARK: - Single tab button
private struct TabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.title)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.secondary.opacity(0.15) : .clear)
            )
            .contentShape(Rectangle())   // <-- parentheses matter
            .accessibilityLabel(Text(tab.title))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .buttonStyle(.plain)
    }
}


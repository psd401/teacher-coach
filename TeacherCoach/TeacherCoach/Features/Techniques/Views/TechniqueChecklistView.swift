import SwiftUI

/// Checkbox list of techniques grouped by category
struct TechniqueChecklistView: View {
    let framework: TeachingFramework
    @Binding var enabledTechniqueIds: Set<String>

    @Environment(\.serviceContainer) private var services

    private var techniquesByCategory: [(category: TechniqueCategory, techniques: [Technique])] {
        services.techniqueService.getTechniquesByCategory(for: framework)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(techniquesByCategory, id: \.category) { group in
                VStack(alignment: .leading, spacing: 8) {
                    // Category header
                    HStack(spacing: 6) {
                        Image(systemName: group.category.icon)
                            .font(.caption)
                        Text(group.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)

                    // Technique checkboxes
                    ForEach(group.techniques) { technique in
                        TechniqueCheckboxRow(
                            technique: technique,
                            isEnabled: enabledTechniqueIds.contains(technique.id),
                            onToggle: {
                                if enabledTechniqueIds.contains(technique.id) {
                                    enabledTechniqueIds.remove(technique.id)
                                } else {
                                    enabledTechniqueIds.insert(technique.id)
                                }
                            }
                        )
                    }
                }
            }

            // Select/Deselect buttons
            HStack {
                Button("Select All") {
                    let allIds = services.techniqueService.getTechniques(for: framework).map { $0.id }
                    enabledTechniqueIds = Set(allIds)
                }
                .buttonStyle(.link)

                Button("Deselect All") {
                    enabledTechniqueIds = []
                }
                .buttonStyle(.link)
            }
            .font(.caption)
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }
}

/// Individual technique checkbox row
struct TechniqueCheckboxRow: View {
    let technique: Technique
    let isEnabled: Bool
    let onToggle: () -> Void

    @State private var showingDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Toggle(isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            )) {
                EmptyView()
            }
            .toggleStyle(.checkbox)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text(technique.name)
                    .font(.body)

                Text(technique.descriptionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                showingDetail = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .popover(isPresented: $showingDetail) {
                TechniqueDetailPopoverView(technique: technique)
            }
        }
        .padding(.vertical, 2)
    }
}

/// Popover showing technique details
struct TechniqueDetailPopoverView: View {
    let technique: Technique

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(technique.name)
                .font(.headline)

            Text(technique.descriptionText)
                .font(.body)

            if !technique.lookFors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Look-fors:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ForEach(technique.lookFors, id: \.self) { item in
                        HStack(alignment: .top, spacing: 4) {
                            Text("\u{2022}")
                            Text(item)
                        }
                        .font(.caption)
                    }
                }
            }

            if !technique.exemplarPhrases.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Example phrases:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ForEach(technique.exemplarPhrases.prefix(3), id: \.self) { phrase in
                        Text("\"\(phrase)\"")
                            .font(.caption)
                            .italic()
                    }
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var enabledIds: Set<String> = Set(TLACTechniques.defaultEnabledIds)

        var body: some View {
            TechniqueChecklistView(
                framework: .tlac,
                enabledTechniqueIds: $enabledIds
            )
            .padding()
            .frame(width: 350)
        }
    }

    return PreviewWrapper()
}

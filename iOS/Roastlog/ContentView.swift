import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Batch?

    var body: some View {
        NavigationStack {
            ZStack {
                RoastlogTheme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Roastlog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore || purchases.isPro {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EntryFormView(itemToEdit: nil) { newItem in
                store.add(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            EntryFormView(itemToEdit: item) { updated in
                store.update(updated)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(RoastlogTheme.accentBright)
            Text("No batches yet")
                .font(RoastlogTheme.headlineFont)
                .foregroundStyle(.white)
            Text("Tap + to log your first one.")
                .font(RoastlogTheme.captionFont)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    editingItem = item
                } label: {
                    row(for: item)
                }
                .accessibilityIdentifier("row_\(item.id.uuidString)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for item: Batch) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.origin).font(RoastlogTheme.headlineFont).foregroundStyle(RoastlogTheme.ink)
            Text(item.roastLevel).font(RoastlogTheme.bodyFont).foregroundStyle(RoastlogTheme.secondaryInk)
            Text(item.notes).font(RoastlogTheme.captionFont).foregroundStyle(RoastlogTheme.secondaryInk)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(RoastlogTheme.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(RoastlogTheme.cardBackground)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store
    let itemToEdit: Batch?
    let onSave: (Batch) -> Void

    @State private var origin: String
    @State private var roastLevel: String
    @State private var notes: String
    @State private var rating: Int
    @FocusState private var focusedField: Bool

    init(itemToEdit: Batch?, onSave: @escaping (Batch) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        _origin = State(initialValue: itemToEdit?.origin ?? "")
        _roastLevel = State(initialValue: itemToEdit?.roastLevel ?? "")
        _notes = State(initialValue: itemToEdit?.notes ?? "")
        _rating = State(initialValue: itemToEdit?.rating ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Origin") {
                    TextField("Origin", text: $\origin)
                        .focused($focusedField)
                        .accessibilityIdentifier("field_origin")
                }
                Section("Roast Level") {
                    TextField("Roast Level", text: $\roastLevel)
                        .accessibilityIdentifier("field_roastLevel")
                }
                Section("Notes") {
                    TextField("Notes", text: $\notes, axis: .vertical)
                        .accessibilityIdentifier("field_notes")
                }
                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .navigationTitle(itemToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let base = itemToEdit ?? Batch(origin: origin, roastLevel: roastLevel, notes: notes)
                        var updated = base
                        updated.origin = origin
                        updated.roastLevel = roastLevel
                        updated.notes = notes
                        updated.rating = rating
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(origin.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}

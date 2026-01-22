//
//  UpdateCompostView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 20/08/25.
//
//  Refactored to use MVVM architecture with UpdateCompostViewModel
//

import SwiftUI
import SwiftData

// CompostNavigation enum is defined in YourCompostsView.swift

extension Date {
    func daysUntil(_ targetDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: targetDate)
        return components.day ?? 0
    }
}

struct UpdateCompostView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModel
    @State private var viewModel: UpdateCompostViewModel

    // MARK: - Navigation
    @Binding private var navigationPath: NavigationPath

    // MARK: - Initialization
    init(compostItem: CompostItem, navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
        // ViewModel will be properly initialized in onAppear with modelContext
        _viewModel = State(initialValue: UpdateCompostViewModel(
            compostItem: compostItem,
            modelContext: ModelContext(try! ModelContainer(for: CompostItem.self))
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerBar
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    titleRow
                    statsAndActionsCard
                    adviceAndLogCard
                        .padding(.bottom, 100)
                }
                bottomSaveBar
            }
        }
        .padding(.horizontal, 24)
        .background(Color("Status/Background"))
        .navigationBarHidden(true)
        .onAppear {
            // Re-initialize ViewModel with correct context
            viewModel = UpdateCompostViewModel(
                compostItem: viewModel.compostItem,
                modelContext: context
            )
        }
        .sheet(isPresented: $viewModel.vitalsSheetPresented) {
            UpdateCompostVitalsSheet(compostItem: viewModel.compostItem)
        }
        .alert("Rename Compost", isPresented: $viewModel.showRenameAlert) {
            TextField("Compost name", text: $viewModel.renameText)
            Button("Cancel", role: .cancel) {}
            Button("Rename") { viewModel.renameCompost() }
        } message: {
            Text("Enter a new name for this compost pile.")
        }
        .confirmationDialog("Delete Compost",
                            isPresented: $viewModel.showDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if viewModel.deleteCompost() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this compost? This action cannot be undone.")
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22))
            }
            .foregroundStyle(Color("BrandGreenDark"))

            Spacer()
            Text("Update Compost")
                .font(.custom("KronaOne-Regular", size: 16))
                .foregroundStyle(Color("BrandGreenDark"))
            Spacer()

            Menu {
                Button { viewModel.markAsHarvested() } label: {
                    Label("Mark As Harvested", systemImage: "checkmark.circle")
                }
                Button { viewModel.prepareRename() } label: {
                    Label("Rename Compost", systemImage: "pencil")
                }
                Button(role: .destructive) { viewModel.prepareDelete() } label: {
                    Label("Delete Compost", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(Color("BrandGreenDark"))
            }
        }
    }

    // MARK: - Title Row
    private var titleRow: some View {
        HStack(alignment: .center) {
            Text(viewModel.compostName)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            StatusChip(type: viewModel.chipType)
        }
        .padding(.top, 12)
    }

    // MARK: - Stats and Actions Card
    private var statsAndActionsCard: some View {
        VStack(spacing: 24) {
            HStack(alignment: .center) {
                statTile(icon: "arrow.trianglehead.2.clockwise",
                         value: viewModel.turnedOverText,
                         label: "Last turned")
                Spacer()
                statTile(icon: "calendar",
                         value: "\(viewModel.ageDays) day",
                         label: "Age")
                Spacer()
                statTile(icon: "checkmark.circle",
                         value: viewModel.daysRemainingText,
                         label: "Est. Harvest")
            }

            HStack(spacing: 0) {
                // Mix button
                Button(action: { viewModel.mixCompost() }) {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                        Text(viewModel.hasBeenTurnedToday ? "Already mixed!" : "Mix")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(viewModel.isPileEmpty ? Color.gray.opacity(0.35) :
                           (viewModel.hasBeenTurnedToday ? Color.gray.opacity(0.35) : Color("compost/PileDirt")))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(viewModel.hasBeenTurnedToday ? Color.gray : Color.clear, lineWidth: 2)
                )
                .disabled(viewModel.isPileEmpty)
                .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                    Button("Ok", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage)
                }

                Spacer()

                // Add Material button
                Button(action: {
                    navigationPath.append(CompostNavigation.pilePrototype(viewModel.compostItemId))
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Material")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color("BrandGreenDark"))
                .clipShape(Capsule())
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
    }

    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .center) {
            Image(systemName: icon)
                .foregroundStyle(Color("Status/Success"))
            Text(value)
                .font(.headline)
                .padding(.top, 4)
            Text(label)
                .font(.subheadline)
        }
    }

    // MARK: - Advice and Log Card
    private var adviceAndLogCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Compost Log :  \(viewModel.lastLoggedFormatted)")
                    .font(.headline)
                    .foregroundStyle(Color("BrandGreenDark"))
                Spacer()
                Text(viewModel.isRecentlyUpdated ? "Updated" : "Not Updated")
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(viewModel.isRecentlyUpdated ? Color("Status/Success") : Color("Status/Warning"))
                    )
                    .foregroundStyle(.white)
                    .font(.caption)
            }

            if viewModel.isPileEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "questionmark.app.dashed")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.black.opacity(0.5))
                    Text("No data yet. Please add your compost material to get started!")
                        .foregroundStyle(Color.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical)
            } else {
                AdviceCard(category: .temperature, issue: viewModel.temperatureIssue)
                AdviceCard(category: .moisture, issue: viewModel.moistureIssue)
            }

            Button(action: { viewModel.showVitalsSheet() }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Update Log")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color("BrandGreenDark"))
            .clipShape(Capsule())
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
    }

    // MARK: - Bottom Save Bar
    private var bottomSaveBar: some View {
        VStack {
            Button(action: { viewModel.confirmSave() }) {
                Text(viewModel.isHarvested ? "SAVED" : "SAVE")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(Color("BrandGreenDark"))
            .clipShape(Capsule())
            .alert("Compost Updated!", isPresented: $viewModel.showSaveAlert) {
                Button("Ok") { dismiss() }
            } message: {
                Text("Your compost has been successfully updated!")
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 0)
        .background(
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0.00),
                    .init(color: .white.opacity(0), location: 1.00),
                ],
                startPoint: .init(x: 0.5, y: 1),
                endPoint: .init(x: 0.5, y: 0)
            )
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var navigationPath = NavigationPath()

    let method = CompostMethod(
        compostMethodId: 1,
        name: "Hot Compost",
        descriptionText: "Fast composting method for active gardeners",
        compostDuration1: 30,
        compostDuration2: 180,
        spaceNeeded1: 1,
        spaceNeeded2: 4
    )

    let compost = CompostItem(name: "Makmum Pile")
    compost.compostMethodId = method
    let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
    compost.creationDate = threeDaysAgo
    compost.turnEvents = [TurnEvent(date: threeDaysAgo)]

    return UpdateCompostView(compostItem: compost, navigationPath: $navigationPath)
}

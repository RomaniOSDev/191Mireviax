import SwiftUI
import UniformTypeIdentifiers

struct DataExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct ExportDataButton: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var exportDocument = DataExportDocument(data: Data())
    @State private var showExporter = false

    var body: some View {
        Button {
            exportData()
        } label: {
            SettingsListCell(title: "Export Data", iconName: "square.and.arrow.up", subtitle: "Save JSON backup")
        }
        .fileExporter(
            isPresented: $showExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "tastetrack-backup"
        ) { result in
            if case .success = result {
                FeedbackService.success()
            }
        }
    }

    private func exportData() {
        FeedbackService.lightTap()
        guard let data = try? JSONEncoder().encode(store.exportBundle()) else { return }
        exportDocument = DataExportDocument(data: data)
        showExporter = true
    }
}

struct ImportDataButton: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showImporter = false

    var body: some View {
        Button {
            FeedbackService.lightTap()
            showImporter = true
        } label: {
            SettingsListCell(title: "Import Data", iconName: "square.and.arrow.down", subtitle: "Restore from backup")
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url),
                   let bundle = try? JSONDecoder().decode(AppExportBundle.self, from: data) {
                    store.importBundle(bundle)
                } else {
                    FeedbackService.warning()
                }
            case .failure:
                FeedbackService.warning()
            }
        }
    }
}

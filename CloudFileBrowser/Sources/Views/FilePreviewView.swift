//
//  FilePreviewView.swift
//  CloudFileBrowser
//
//  Created by CloudFileBrowser
//

import SwiftUI
import PDFKit

struct FilePreviewView: View {
    let file: CloudFile
    let data: Data
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Group {
                if file.isImage {
                    imagePreview
                } else if file.isPDF {
                    pdfPreview
                } else {
                    unsupportedPreview
                }
            }
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var imagePreview: some View {
        Group {
            if let uiImage = UIImage(data: data) {
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            } else {
                Text("Unable to load image")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var pdfPreview: some View {
        Group {
            if let pdfDocument = PDFDocument(data: data) {
                PDFKitView(document: pdfDocument)
            } else {
                Text("Unable to load PDF")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var unsupportedPreview: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("Preview not available")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("This file type cannot be previewed")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

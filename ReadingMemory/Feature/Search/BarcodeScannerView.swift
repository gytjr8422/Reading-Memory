//
//  BarcodeScannerView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/23/24.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedISBN: String?
    @Binding var isCameraActive: Bool

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

                // 바코드에서 추출한 ISBN을 부모 뷰에 전달
                parent.scannedISBN = stringValue

                // 카메라 비활성화
                parent.isCameraActive = false
            }
        }
        
        @objc func closeScanner() {
            parent.isCameraActive = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video) else { return viewController }
        let input = try? AVCaptureDeviceInput(device: device)

        if (input != nil && session.canAddInput(input!)) {
            session.addInput(input!)

            let output = AVCaptureMetadataOutput()
            if (session.canAddOutput(output)) {
                session.addOutput(output)

                output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.ean8, .ean13, .pdf417] // 바코드 타입 설정

                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.frame = viewController.view.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                viewController.view.layer.addSublayer(previewLayer)
                
                let navigationController = UINavigationController(rootViewController: viewController)
                // 네비게이션 바가 투명하지 않도록 설정
                viewController.navigationController?.navigationBar.isTranslucent = false
                
                // 네비게이션 바의 확장 영역에 포함
                viewController.edgesForExtendedLayout = .all
                viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: context.coordinator, action: #selector(Coordinator.closeScanner))
                
                DispatchQueue.global().async {
                    session.startRunning()
                }
                
                return navigationController
            }
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

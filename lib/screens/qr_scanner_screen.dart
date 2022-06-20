import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/qt_overlay.dart';
import 'global_menu.dart';

class QrScannerScreen extends StatelessWidget {
  static const routeName = '/scanner';
  final MobileScannerController cameraController = MobileScannerController();

  QrScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: [
        MobileScanner(
          allowDuplicates: false,
          controller: cameraController,
          onDetect: (barcode, args) async {
            final String qrData = barcode.rawValue ?? '';
            if (int.tryParse(qrData) != null) {
              Navigator.of(context).pushReplacementNamed(MenuScreen.routeName);
            } else {
              if (Uri.tryParse(qrData) != null) {
                Map? queryParameters;
                var uriData = Uri.parse(qrData);
                queryParameters = uriData.queryParameters;
                if (queryParameters.containsKey("locker_id") &&
                    int.tryParse(queryParameters["locker_id"]) != null) {
                  final String lockerId = queryParameters["locker_id"];
                  Navigator.of(context).pop(lockerId);
                } else {
                  await showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                            title: Text("Інформація"),
                            content: Text(
                                "Не можемо ідентифікувати комплекс. Спробуйте вести Locker ID"),
                          ));
                  Navigator.of(context).pop();
                }
              }
            }
          },
        ),
        QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
        Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                color: Colors.white,
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
                  builder: (context, state, child) {
                    switch (state as TorchState) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off, color: Colors.grey);
                      case TorchState.on:
                        return const Icon(Icons.flash_on, color: Colors.yellow);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () => cameraController.toggleTorch(),
              ),
              IconButton(
                color: Colors.white,
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state as CameraFacing) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () => cameraController.switchCamera(),
              ),
            ]))
      ],
    )));
  }
}

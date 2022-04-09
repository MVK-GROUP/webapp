import 'package:flutter/material.dart';
import '../models/services.dart';
import '../style.dart';

class TariffDialog extends StatelessWidget {
  final ACLCellType cellType;
  final Color tileColor;

  const TariffDialog(this.cellType, {Key? key, this.tileColor = mainColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 300, maxHeight: 500),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                        iconSize: 32,
                        color: mainColor,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))),
              ),
              Text(
                "Оберіть тариф",
                style: titleSecondaryTextStyle.copyWith(color: secondaryColor),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  cellType.title,
                  style: subtitleTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: cellType.tariff
                      .map((e) => Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    primary: tileColor),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    const Icon(
                                      Icons.lock_clock,
                                      size: 28,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      e.hours,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.attach_money,
                                      size: 28,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      e.price.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                  ],
                                )),
                          ))
                      .toList(),
                ),
              )),
            ],
          ),
        ));
  }
}

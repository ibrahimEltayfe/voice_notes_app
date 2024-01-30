import 'package:flutter/material.dart';

import 'constants/app_colors.dart';

Future<T?> showAppBottomSheet<T>(BuildContext context,{
  required Widget Function(BuildContext) builder,
  bool showCloseButton = false
}) async{
  return await showModalBottomSheet<T?>(
    context: context,
    backgroundColor: AppColors.blue800,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(35),
        topRight: Radius.circular(35),
      ),
    ),
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(showCloseButton)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close,color: AppColors.white,),
                  ),
                ),
              ),

              builder(context)
            ],
          ),
        ),
      );
    },
  );
}
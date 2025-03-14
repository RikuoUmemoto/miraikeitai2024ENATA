/*----------------------------------
写真挿入に使われるクラスです。
-----------------------------------*/

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InsertPhoto extends StatefulWidget {
  final String title;
  final File? photo;
  final Function(File?) onPhotoSelected;

  const InsertPhoto({
    Key? key,
    required this.title,
    required this.photo,
    required this.onPhotoSelected,
  }) : super(key: key);

  @override
  InsertPhotoState createState() => InsertPhotoState();
}

class InsertPhotoState extends State<InsertPhoto> {
  File? photo;

  @override
  void initState() {
    super.initState();
    photo = widget.photo;
  }

  final ImagePicker imagePicker = ImagePicker();

  // ギャラリーから画像を取得するメソッド
  Future<void> getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        photo = File(pickedFile.path);
      });
      widget.onPhotoSelected(photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.photo),
            label: const Text('写真を選択'),
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                fixedSize: Size(150, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
            onPressed: getImageFromGallery,
          ),
          Expanded(
            child: Center(
              child: photo == null
                  ? Text('写真が選択されていません')
                  : Image.file(
                      photo!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

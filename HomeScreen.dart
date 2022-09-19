// ignore_for_file: null_check_always_fails

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marcjrfoundation/pages/home/ChildListButton.dart';
import 'package:marcjrfoundation/pages/home/DialogValidators.dart';
import 'package:marcjrfoundation/services/SharedPreferences/sharedprefs_helper.dart';
import 'package:marcjrfoundation/services/device_size.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:websafe_svg/websafe_svg.dart';

class HomeScreen extends StatefulWidget with InviteNameandAgeValidatos {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Image childImage;
  TextEditingController childNameController = TextEditingController();
  TextEditingController childAgeController = TextEditingController();
  TextEditingController childDiagnosisController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode _childNameFocus = FocusNode();
  FocusNode _childAgeFocus = FocusNode();
  FocusNode _childDiagnosisFocus = FocusNode();
  String buttonText = 'Image';

  String get _childName => childNameController.text;

  void _nameEditingComplete() {
    final newFocus = widget.nameValidator.isValid(_childName)
        ? _childAgeFocus
        : _childNameFocus;
    FocusScope.of(context).requestFocus(newFocus);
  }

  Future<void> writeChildrenToDb(
      String parentUid,
      String childUid,
      String childNameInput,
      String childAgeInput,
      String childDiagnosisInput,
      String childPicUrl) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childUid)
        .set({
      'childName': childNameInput,
      'childAge': childAgeInput,
      'childDiagnosis': childDiagnosisInput,
      'childUid': childUid,
      'childPicUrl': childPicUrl,
    });
  } // writes children details to db

  Future<String> uploadImageToFirebase(String childUid, String _image) async {
    Reference storage = FirebaseStorage.instance
        .ref()
        .child('users/$parentIdGlobal/$childUid/child_pic');
    UploadTask uploadTask = storage.putFile(_image as File);

    var dowurl = await (await uploadTask).ref.getDownloadURL();
    var url = dowurl.toString();
    return url;
  }

  _showAddDialog() {
    String? childUid = Uuid().v4();
    String? childNameInput;
    String? childAgeInput;
    String? childDiagnosisInput;
    String? childPicUrl;
    File? _image;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          title: Text(
            'Add Child Information',
          ),
          contentPadding: EdgeInsets.all(8.0),
          elevation: 10.0,
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty || value.length < 2)
                          return "Please enter child's valid name";
                        return null;
                      };
return null;
                    },
                    controller: childNameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'eg: Amber',
                      labelText: 'Child name*',
                      labelStyle: TextStyle(color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(width: 10.0),
                      ),
                      hintMaxLines: 2,
                    ),
                    onEditingComplete: _nameEditingComplete,
                    autocorrect: false,
                    focusNode: _childNameFocus,
                    onChanged: (_childName) => print(_childName),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    controller: childAgeController,
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty || int.parse(value) < 1)
                          return "Please enter child's valid age";
                        else if (int.parse(value) > 18)
                          return "Child Age could not be greater than 18";
                        return null;
                      };
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    showCursor: true,
                    decoration: InputDecoration(
                      hintText: 'eg: 21',
                      labelText: 'Child age(in years)',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      hintMaxLines: 2,
                    ),
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    focusNode: _childAgeFocus,
                    onChanged: (_childAge) => print(_childAge),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
//                    validator: (value) {
//                      if (value.isEmpty || value.length < 2)
//                        return "Please enter proper diagnostic issue";
//                      return null;
//                    },
                    controller: childDiagnosisController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'eg: DIPG,Leukemia',
                      labelText: 'Child Diagnosis',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(width: 10.0),
                      ),
                      hintMaxLines: 2,
                    ),
                    autocorrect: false,
                    focusNode: _childDiagnosisFocus,
                    onChanged: (_childDiagnosis) => print(_childDiagnosis),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Permission.photos.request();
                      var status = await Permission.photos.status;
                      if (status.isGranted) {
                        final  _picker = ImagePicker();
                          final XFile? pickedImage =
                          await _picker.pickImage(source: ImageSource.gallery,
                              maxWidth: 100.0,
                            maxHeight: 100.0
                          );
                          if(pickedImage !=null) {
                            setState((){
                              _image=File(pickedImage.path);
                            });
    }
                      } else if (status.isDenied ||
                          status.isPermanentlyDenied) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              if (Platform.isAndroid)
                                return AlertDialog(
                                  title: Text('Permission Not Granted'),
                                  content: Text(
                                      'The permission for photo library is not granted'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => openAppSettings(),
                                      child: Text('Ok'),
                                    ),
                                  ],
                                );
                              return CupertinoAlertDialog(
                                title: Text('Permission Not Granted'),
                                content: Text(
                                    'The permission for photo library is not granted'),
                                actions: [
                                  TextButton(
                                    onPressed: () => openAppSettings(),
                                    child: Text('Ok'),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.transparent,
                          border: Border.all(
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _image == null
                            ? Icon(
                                Icons.add,
                                color: Colors.black,
                              )
                            : Image.file( _image!,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                childNameController.clear();
                childAgeController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                childNameInput = childNameController.text;
                childAgeInput = childAgeController.text;
                childDiagnosisInput = childDiagnosisController.text;

                String? parentUid = await getData('parentUid');

                if (_formKey.currentState?.validate() == false) {
                  if (_image != null) {
                    childPicUrl =
                        await uploadImageToFirebase(childUid, _image as String);
                  }

                  await writeChildrenToDb(parentUid!, childUid, childNameInput!,
                      childAgeInput!, childDiagnosisInput!, childPicUrl as String);
                  childNameController.clear();
                  childAgeController.clear();
                  Navigator.of(context).pop();
                }
              },child: Text('Ok'),

            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          child: StreamBuilder<QuerySnapshot<Object?>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(parentIdGlobal)
                .collection('children')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.requireData;
                return ListView.builder(
                     itemCount: data.size,
                    itemBuilder: (context, index) {
                      return ChildListButton(
                          childName: data.docs[index]["childName"],
                          childAge: data.docs[index]["childAge"],
                          childPicUrl: data.docs[index]["childPicUrl"],
                          childUid: data.docs[index]["childUid"],
                          childDiagnosis: data.docs[index]["childDiagnosis"]
                      );
                    }
                );
              }
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.all(
                  ResponsiveWidget.isSmallScreen(context) ? 100.0 : 500),
              textScaleFactor:
                  ResponsiveWidget.isSmallScreen(context) ? 1.0 : 1.5,
            ),
            child: Text(
              'Add Child',
              style: Theme.of(context).textTheme.button,
            ),
          ),
          icon: Icon(
            Icons.add,
            size: ResponsiveWidget.isSmallScreen(context) ? 20.0 : 33.0,
          ),
          backgroundColor: Color(0xff8BC34A),
          onPressed: _showAddDialog,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    } on PlatformException catch (e) {
      print(e.message);

      // TODO: implement build
      throw UnimplementedError();
    }
  }
}

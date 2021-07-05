import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_editor_pro/modules/all_emojies.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/emoji.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

typedef CallBackImageFile(File file);

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
TextEditingController inputTextController = TextEditingController();
var width = 800;
var height = 800;

List fontsize = [];
var howmuchwidgetis = 0;
List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
String textInput = '';
SignatureController _controller = SignatureController(penStrokeWidth: 5, penColor: Colors.orange);

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;
  final CallBackImageFile callBackImageFile;

  ImageEditorPro({
    this.appBarColor,
    this.bottomBarColor,
    this.callBackImageFile,
  });

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller = SignatureController(penStrokeWidth: 5, penColor: color, points: points);
  }

  List<Offset> offsets = [];
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List<Offset> _points = <Offset>[];
  List type = [];
  List aligment = [];
  File _imageFile;
  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = new GlobalKey();
  File _image;
  ScreenshotController screenshotController = ScreenshotController();
  Timer timeprediction;

  void timers() {
    Timer.periodic(Duration(milliseconds: 10), (tim) {
      setState(() {});
      timeprediction = tim;
    });
  }

  @override
  void dispose() {
    timeprediction.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    timers();
    _controller.clear();
    type.clear();
    fontsize.clear();
    offsets.clear();
    multiwidget.clear();
    inputTextController.clear();
    howmuchwidgetis = 0;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        key: scaf,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              setState(() {
                inputTextController.text = '';
              });
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Icon(
                Icons.arrow_back_ios,
                size: 45,
              ),
            ),
          ),
          actions: <Widget>[
            new IconButton(
                icon: Icon(FontAwesomeIcons.boxes),
                onPressed: () {
                  showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: new Text("Select Height Width"),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    height = int.parse(heightcontroler.text);
                                    width = int.parse(widthcontroler.text);
                                  });
                                  heightcontroler.clear();
                                  widthcontroler.clear();
                                  Navigator.pop(context);
                                },
                                child: new Text("Done"))
                          ],
                          content: new SingleChildScrollView(
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("Define Height"),
                                new SizedBox(
                                  height: 10,
                                ),
                                TextField(controller: heightcontroler, keyboardType: TextInputType.numberWithOptions(), decoration: InputDecoration(hintText: 'Height', contentPadding: EdgeInsets.only(left: 10), border: OutlineInputBorder())),
                                new SizedBox(
                                  height: 10,
                                ),
                                new Text("Define Width"),
                                new SizedBox(
                                  height: 10,
                                ),
                                TextField(controller: widthcontroler, keyboardType: TextInputType.numberWithOptions(), decoration: InputDecoration(hintText: 'Width', contentPadding: EdgeInsets.only(left: 10), border: OutlineInputBorder())),
                              ],
                            ),
                          ),
                        );
                      });
                }),
            new IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _controller.points.clear();
                  setState(() {});
                }),
            new IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  bottomsheets();
                }),
            new FlatButton(
                child: Text("Done"),
                textColor: Colors.white,
                onPressed: () {
                  _imageFile = null;
                  screenshotController.capture(delay: Duration(milliseconds: 500), pixelRatio: 1.5).then((File image) async {
                    //print("Capture Done");
                    setState(() {
                      _imageFile = image;
                    });
                    final paths = await getApplicationDocumentsDirectory();
                    image.copy(paths.path + '/' + DateTime.now().millisecondsSinceEpoch.toString() + '.png');
                    widget.callBackImageFile(image);
                  }).catchError((onError) {
                    print(onError);
                  });
                }),
          ],
          backgroundColor: widget.appBarColor,
        ),
        body: Stack(
          children: [
            Center(
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  margin: EdgeInsets.all(20),
                  color: Colors.white,
                  width: width.toDouble(),
                  height: height.toDouble(),
                  child: RepaintBoundary(
                      key: globalKey,
                      child: Stack(
                        children: <Widget>[
                          _image != null
                              ? Image.file(
                                  _image,
                                  height: height.toDouble(),
                                  width: width.toDouble(),
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                          Container(
                            child: GestureDetector(
                                onPanUpdate: (DragUpdateDetails details) {
                                  setState(() {
                                    RenderBox object = context.findRenderObject();
                                    Offset _localPosition = object.globalToLocal(details.globalPosition);
                                    _points = new List.from(_points)..add(_localPosition);
                                  });
                                },
                                onPanEnd: (DragEndDetails details) {
                                  _points.add(null);
                                },
                                child: Signat()),
                          ),
                          Stack(
                            children: multiwidget.asMap().entries.map((f) {
                              return type[f.key] == 1
                                  ? EmojiView(
                                      left: offsets[f.key].dx,
                                      top: offsets[f.key].dy,
                                      ontap: () {
                                        scaf.currentState.showBottomSheet((context) {
                                          return Sliders(
                                            size: f.key,
                                            sizevalue: fontsize[f.key].toDouble(),
                                          );
                                        });
                                      },
                                      onpanupdate: (details) {
                                        setState(() {
                                          offsets[f.key] = Offset(offsets[f.key].dx + details.delta.dx, offsets[f.key].dy + details.delta.dy);
                                        });
                                      },
                                      value: f.value.toString(),
                                      fontsize: fontsize[f.key].toDouble(),
                                      align: TextAlign.center,
                                    )
                                  : type[f.key] == 2
                                      ? TextView(
                                          left: offsets[f.key].dx,
                                          top: offsets[f.key].dy,
                                          ontap: () {
                                            scaf.currentState.showBottomSheet((context) {
                                              return Sliders(
                                                size: f.key,
                                                sizevalue: fontsize[f.key].toDouble(),
                                              );
                                            });
                                          },
                                          onpanupdate: (details) {
                                            setState(() {
                                              offsets[f.key] = Offset(offsets[f.key].dx + details.delta.dx, offsets[f.key].dy + details.delta.dy);
                                            });
                                          },
                                          value: f.value.toString(),
                                          fontsize: fontsize[f.key].toDouble(),
                                          align: TextAlign.center,
                                        )
                                      : new Container();
                            }).toList(),
                          )
                        ],
                      )),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: openbottomsheet
            ? new Container()
            : Container(
                decoration: BoxDecoration(color: widget.bottomBarColor, boxShadow: [BoxShadow(blurRadius: 10.9)]),
                height: 70,
                child: new ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    BottomBarContainer(
                      colors: widget.bottomBarColor,
                      icons: FontAwesomeIcons.brush,
                      ontap: () {
                        // raise the [showDialog] widget
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: changeColor,
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('Got it'),
                                  onPressed: () {
                                    setState(() => currentColor = pickerColor);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ));
                      },
                      title: 'Brush',
                    ),
                    BottomBarContainer(
                      icons: Icons.text_fields,
                      ontap: () {
                        //  final value = await Navigator.push(context, MaterialPageRoute(builder: (context) => TextEditor()));
                        showDialogInputText();
                        // if ((textInput == '') && textInput == null) {
                        //   print("true");
                        // } else {
                        //   type.add(2);
                        //   fontsize.add(40);
                        //   offsets.add(Offset.zero);
                        //   multiwidget.add(textInput);
                        //   howmuchwidgetis++;
                        // }
                      },
                      title: 'Text',
                    ),
                    BottomBarContainer(
                      icons: FontAwesomeIcons.eraser,
                      ontap: () {
                        _controller.clear();
                        type.clear();
                        fontsize.clear();
                        offsets.clear();
                        multiwidget.clear();
                        howmuchwidgetis = 0;
                      },
                      title: 'Eraser',
                    ),
                    BottomBarContainer(
                      icons: Icons.photo,
                      ontap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ColorPiskersSlider();
                            });
                      },
                      title: 'Filter',
                    ),
                    BottomBarContainer(
                      icons: FontAwesomeIcons.smile,
                      ontap: () {
                        Future getemojis = showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Emojies();
                            });
                        getemojis.then((value) {
                          if (value != null) {
                            type.add(1);
                            fontsize.add(20);
                            offsets.add(Offset.zero);
                            multiwidget.add(value ?? '');
                            howmuchwidgetis++;
                          }
                        });
                      },
                      title: 'Emoji',
                    ),
                  ],
                ),
              ));
  }

  void showDialogInputText() {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => buildInputText(),
    // );

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Input Text"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    setState(() {
                      textInput = inputTextController.text;
                      type.add(2);
                      fontsize.add(40);
                      offsets.add(Offset.zero);
                      multiwidget.add(textInput ?? '');
                      howmuchwidgetis++;
                    });
                    inputTextController.clear();
                    Navigator.pop(context);
                  },
                  child:  Text("OK")),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text("Cancle"))
            ],
            content: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: inputTextController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 5, left: 5),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    textInput = value;
                  });
                },
              ),
            ),
          );
        });
  }

  Widget buildInputText() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 500,
            height: 230,
            margin: EdgeInsets.only(left: (MediaQuery.of(context).size.width) / 5.5),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1), color: Colors.white),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Input Text',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    controller: inputTextController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 5, left: 5),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        textInput = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              textInput = inputTextController.text;
                              type.add(2);
                              fontsize.add(40);
                              offsets.add(Offset.zero);
                              multiwidget.add(textInput ?? '');
                              howmuchwidgetis++;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                            child: Center(child: Text("OK", style: TextStyle(color: Colors.blue))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 70,
                            child: Center(child: Text("Cancel", style: TextStyle(color: Colors.blue))),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void bottomsheets() {
    openbottomsheet = true;
    setState(() {});
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return new Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 10.9, color: Colors.grey[400])]),
          height: 170,
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Text("Select Image Options"),
              ),
              Divider(
                height: 1,
              ),
              new Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Container(
                    //   child: InkWell(
                    //     onTap: () {},
                    //     child: Container(
                    //       child: Column(
                    //         children: <Widget>[
                    //           IconButton(
                    //               icon: Icon(Icons.photo_library),
                    //               onPressed: () async {
                    //                 var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                    //                 var decodedImage = await decodeImageFromList(image.readAsBytesSync());
                    //
                    //                 setState(() {
                    //                   height = decodedImage.height;
                    //                   width = decodedImage.width;
                    //                   _image = image;
                    //                 });
                    //                 setState(() => _controller.clear());
                    //                 Navigator.pop(context);
                    //               }),
                    //           SizedBox(width: 10),
                    //           Text("Open Gallery")
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(width: 24),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () async {
                                  var image = await ImagePicker.pickImage(source: ImageSource.camera);
                                  var decodedImage = await decodeImageFromList(image.readAsBytesSync());

                                  setState(() {
                                    height = decodedImage.height;
                                    width = decodedImage.width;
                                    _image = image;
                                  });
                                  setState(() => _controller.clear());
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            Text("Open Camera")
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }
}

class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
    _controller.addListener((){

    });
  }

  @override
  Widget build(BuildContext context) {
    return //SIGNATURE CANVAS
        //SIGNATURE CANVAS
        ListView(
      children: <Widget>[
        Signature(controller: _controller, height: height.toDouble(), width: width.toDouble(), backgroundColor: Colors.transparent),
      ],
    );
  }
}

class Sliders extends StatefulWidget {
  final int size;
  final sizevalue;

  const Sliders({Key key, this.size, this.sizevalue}) : super(key: key);

  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  void initState() {
    slider = widget.sizevalue;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: new Text("Slider Size"),
            ),
            Divider(
              height: 1,
            ),
            new Slider(
                value: slider,
                min: 0.0,
                max: 100.0,
                onChangeEnd: (v) {
                  setState(() {
                    fontsize[widget.size] = v.toInt();
                  });
                },
                onChanged: (v) {
                  setState(() {
                    slider = v;
                    print(v.toInt());
                    fontsize[widget.size] = v.toInt();
                  });
                }),
          ],
        ));
  }
}

class ColorPiskersSlider extends StatefulWidget {
  @override
  _ColorPiskersSliderState createState() => _ColorPiskersSliderState();
}

class _ColorPiskersSliderState extends State<ColorPiskersSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 260,
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: new Text("Slider Filter Color"),
          ),
          Divider(
            height: 1,
          ),
          SizedBox(height: 20),
          new Text("Slider Color"),
          SizedBox(height: 10),
          BarColorPicker(
              width: 300,
              thumbColor: Colors.white,
              cornerRadius: 10,
              pickMode: PickMode.Color,
              colorListener: (int value) {
                setState(() {
                  //  currentColor = Color(value);
                });
              }),
          SizedBox(height: 20),
          new Text("Slider Opicity"),
          SizedBox(height: 10),
          Slider(value: 0.1, min: 0.0, max: 1.0, onChanged: (v) {})
        ],
      ),
    );
  }
}

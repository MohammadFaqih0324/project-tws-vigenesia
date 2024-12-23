import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:project_tws_vigenesia/Constant/const.dart';
import 'package:project_tws_vigenesia/Models/Motivasi_Model.dart';

class EditPage extends StatefulWidget {
  final String? id;
  final String? isi_motivasi;
  const EditPage({Key? key, this.id, this.isi_motivasi}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String baseurl =
      "https://56e2-110-138-54-61.ngrok-free.app/vigenesia"; // ganti dengan ip address kamu / tempat kamu menyimpan backend

  var dio = Dio();

  Future<dynamic> putPost(String isi_motivasi, String ids) async {
    Map<String, dynamic> data = {"isi_motivasi": isi_motivasi, "id": ids};
    var response = await dio.put('$baseurl/api/dev/PUTmotivasi',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ));

    print("---> ${response.data} + ${response.statusCode}");

    return response.data;
  }

  late TextEditingController isiMotivasi;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nilai motivasi yang sudah ada
    isiMotivasi = TextEditingController(text: widget.isi_motivasi);
  }

  @override
  void dispose() {
    // Pastikan controller di-dispose setelah halaman tidak digunakan
    isiMotivasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: Text("Edit"),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Edit Motivasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.4,
                  child: FormBuilderTextField(
                    cursorColor: Colors.indigo[900],
                    name: "isi_motivasi",
                    controller:
                        isiMotivasi, // Gunakan controller yang diinisialisasi
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: BorderSide(
                            color: Colors.indigo.shade900, width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        borderSide: BorderSide(
                            color: Colors.indigo.shade900, width: 1.0),
                      ),
                      labelStyle: TextStyle(color: Colors.indigo[900]),
                      labelText: "New Motivasi",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan validasi input kosong
                    if (isiMotivasi.text.isEmpty) {
                      Flushbar(
                        message: "Isi motivasi tidak boleh kosong",
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                        flushbarPosition: FlushbarPosition.TOP,
                      ).show(context);
                    } else {
                      putPost(isiMotivasi.text, widget.id.toString())
                          .then((value) => {
                                if (value != null)
                                  {
                                    Navigator.pop(context),
                                    Flushbar(
                                      message:
                                          "Berhasil Update, silahkan refresh",
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.green,
                                      flushbarPosition: FlushbarPosition.TOP,
                                    ).show(context)
                                  }
                              });
                    }
                  },
                  child: Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.indigo[900], // Ubah warna tombol di sini
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

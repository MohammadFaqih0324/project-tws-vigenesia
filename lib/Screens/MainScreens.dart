import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_tws_vigenesia/Constant/const.dart';
import 'Login.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:project_tws_vigenesia/Models/Motivasi_Model.dart';
import 'package:project_tws_vigenesia/Screens/EditPage.dart';

class MainScreens extends StatefulWidget {
  final String? nama;
  final String? iduser;

  const MainScreens({Key? key, this.nama, this.iduser}) : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl = "https://56e2-110-138-54-61.ngrok-free.app/vigenesia";

  String? id;
  var dio = Dio();
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String isi) async {
    Map<String, dynamic> body = {
      "isi_motivasi": isi,
      "iduser": widget.iduser ?? '' //sudah ok
      //"iduser": widget.iduser
    };

    try {
      Response response = await dio.post("$baseurl/api/dev/POSTmotivasi/",
          data: body,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            validateStatus: (status) => true,
          ));
      print("Respon -> ${response.data} + ${response.statusCode}");
      return response;
    } catch (e) {
      print("Error di -> $e");
    }
  }

  List<MotivasiModel> listproduk = [];

  Future<List<MotivasiModel>> getData() async {
    var response = await dio.get('$baseurl/api/Get_motivasi/');

    print(" ${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<Map<String, dynamic>> deletePost(String id) async {
    dynamic data = {
      "id": id,
    };
    var response = await dio.delete('$baseurl/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {"Content-type": "application/json"}));

    print(" ${response.data}");

    var resbody = jsonDecode(response.data);
    return resbody;
  }

  Future<void> _getData() async {
    setState(() {
      getData();
    });
  }

  TextEditingController isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VIGENESIA"),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(
                  context); // This will pop the current screen off the stack
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      Login(), // Navigate to the Login screen
                ),
              );
              Flushbar(
                message: "Berhasil Logout",
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
                flushbarPosition: FlushbarPosition.TOP,
              ).show(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Di Aplikasi Vigenesia',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      'Masukan Motivasi Anda ${widget.nama}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    controller: isiController,
                    name: "isi_motivasi",
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        await sendMotivasi(isiController.text.toString())
                            .then((value) => {
                                  if (value != null)
                                    {
                                      Flushbar(
                                        message:
                                            "Berhasil Submit, silahkan refresh",
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.green,
                                        flushbarPosition: FlushbarPosition.TOP,
                                      ).show(context)
                                    },
                                  //_getData(),
                                  print("Sukses"),
                                });
                      },
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.indigo[900], // Ubah warna tombol di sini
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Center(
                          child: Text(
                            'Motivasi Hari Ini',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          child: Icon(Icons.refresh, color: Colors.indigo[900]),
                          onPressed: () {
                            _getData();
                          },
                        ),
                        FutureBuilder<List<MotivasiModel>>(
                          future: getData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<MotivasiModel>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text("No Data"));
                            } else {
                              return Column(
                                children: List.generate(snapshot.data!.length,
                                    (index) {
                                  var item = snapshot.data![index];
                                  return ListTile(
                                    title: Text(item.isiMotivasi.toString()),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          child: Icon(Icons.settings,
                                              color: Colors.indigo[900]),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditPage(
                                                  id: item.id,
                                                  isi_motivasi:
                                                      item.isiMotivasi,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        TextButton(
                                          child: Icon(Icons.delete,
                                              color: Colors.indigo[900]),
                                          onPressed: () {
                                            deletePost(item.id!)
                                                .then((response) {
                                              // Cek jika response merupakan Map dan ambil message jika ada
                                              String message =
                                                  'Item berhasil dihapus';
                                              if (response
                                                      is Map<String, dynamic> &&
                                                  response
                                                      .containsKey('message')) {
                                                message = response['message'];
                                              }
                                            }).catchError((error) {
                                              // Cetak error untuk diagnosa
                                              print("Error: $error");
                                              Flushbar(
                                                message:
                                                    "Berhasil Delete, silahkan refresh",
                                                duration: Duration(seconds: 2),
                                                backgroundColor: Colors.green,
                                                flushbarPosition:
                                                    FlushbarPosition.TOP,
                                              ).show(context);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

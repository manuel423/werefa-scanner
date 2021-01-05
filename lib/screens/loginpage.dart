
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:werefamscanner/utility/soldticketmodel.dart';
import 'package:werefamscanner/utility/dbconnection.dart';
class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {

  TextEditingController _controller= new TextEditingController();
  BuildContext loadcont;

  Future<void> _lodding() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Center(
          child: SpinKitCubeGrid(
            color: Colors.white,
            size: 80.0,
          ),
        );
      },
    );
  }

  Future<void> _caution(String mes) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          title: Text("Caution"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(mes),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getdata() async{
    if(_controller.text==''){
      _caution('Enter the id');
    }else{
       var connectivity =new Connectivity();
       ConnectivityResult connectivityResult= await connectivity.checkConnectivity();

       if(connectivityResult==ConnectivityResult.wifi || connectivityResult==ConnectivityResult.mobile){
         print("connectd");
         var id=_controller.text;
         var url="https://werefa.biz/api/movieinfo/$id";
         _lodding();
         try{

           http.Response responce= await http.get(url).timeout(const
             Duration(seconds: 180),
             onTimeout: () {
               Navigator.of(context).pop();
              _caution("time out");
             },
           );

           if(responce.statusCode==200){

            print(responce.body);
             if(responce.body=='1'){

               Navigator.of(context).pop();
               await _caution('no Tickets found');
               Navigator.pushNamed(context, '/scanner');
             }else if(responce.body=='0'){
               await _caution("invalid id!!");
               Navigator.of(context).pop();
             } else{

               Map<String, dynamic> info=jsonDecode(responce.body);
               print(info);
               for(int i=0;i<info['data'].length;i++){
                 final  List<Map<String, dynamic>> scanned= await DBprovider.db.getscannedbyid(info['data'][i]['Ticket_No']);
                 final  List<Map<String, dynamic>> sold= await DBprovider.db.getsoldbyid(info['data'][i]['Ticket_No']);

                 if(sold==null && scanned==null){

                   var newinfo= Soldticket(ticket_id: info['data'][i]['Ticket_No'],ticket_num:  int.parse(info['data'][i]['amount']));
                   await DBprovider.db.newsold(newinfo);
                 }

                 }
               Navigator.of(context).pop();
               Navigator.pushNamed(context, '/scanner');
             }

           }else{

            await _caution("invalid id!!");
             Navigator.of(context).pop();
           }
         } on SocketException catch(_){
           _caution("Connection error");
           Navigator.of(context).pop();
         }
       }else{

         _caution("Connection error");
         //Navigator.of(context).pop();
       }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black38,
        title: Text("Werefa"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login',style: TextStyle(
              fontSize: 60.0,
              letterSpacing: 2.0,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 12.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    filled: true,
                    border: InputBorder.none,
                    hintText: 'Password',
                    contentPadding: EdgeInsets.all(16.0),
                    prefixIcon: Icon(Icons.lock,color: Colors.white,)
                ),
                obscureText: true,
                controller: _controller,
              ),
            ),

            SizedBox(
              height: 40.0,
            ),
            RaisedButton(
              onPressed: (){
               getdata();
              },
              shape: StadiumBorder(),
              color: Colors.red,
              textColor: Colors.white,
              child: Text("Login",style: TextStyle(fontSize: 22.0),),
              padding: EdgeInsets.symmetric(vertical: 12.0,horizontal: 80.0),
              elevation: 0.0,
            )
          ],
        ),
      ),
    );
  }
}

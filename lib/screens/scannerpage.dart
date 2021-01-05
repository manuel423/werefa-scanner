
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../reuseables/ReuseableCard.dart';
import 'package:werefamscanner/utility/dbconnection.dart';
import 'package:werefamscanner/utility/soldticketmodel.dart';

const Color active=Color(0xff1d1e33);
const Color inactive=Color(0xff111328);

class  InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Future _futurevalue;
  int scanned=0;
  int all=0;
  Future<void> _found(String mes,int num) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Result"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.check_circle,color: Colors.green,size: 50,),
                    SizedBox(width: 10,),
                    Center(child: Text(mes,style: TextStyle(fontSize: 30),)),
                  ],
                ),
                SizedBox(height: 10,),
                Text('$num Person Ticket.',style: TextStyle(fontSize: 30),),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
                _scanQR();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _notfound(String mes) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Result"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Row(
                    children: [
                      Icon(Icons.error,color: Colors.red,size: 50,),
                      SizedBox(width: 10,),
                      Text(mes,style: TextStyle(fontSize: 40),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _scanQR();
              },
            ),
          ],
        );
      },
    );
  }

  _scanQR() async{
    try{
      var qres= await BarcodeScanner.scan();
      if(qres.rawContent!=""){
        final  List<Map<String, dynamic>> sold= await DBprovider.db.getsoldbyid(qres.rawContent);
        if(sold!=null){
            var newinfo= Soldticket(ticket_id: sold[0]['Ticket_id'],ticket_num:  sold[0]['Ticket_num']);
            await DBprovider.db.newscanned(newinfo);
            DBprovider.db.deleteticket(qres.rawContent);
            _found("Found",sold[0]['Ticket_num']);
            setState(() {
              scanned++;
            });
        }else{
          _notfound("Not Found");
        }
       }


    }on PlatformException catch (e){
      if(e.code== BarcodeScanner.cameraAccessDenied){
        setState(() {
          //res= "Camera Permission is needed!!";
        });

      }else{
        setState(() {
          // res= "Unknown Error $e";
        });

      }
    }on FormatException{
      setState(() {
        // res="You pressed the back button before scanning!!";
      });
    }

  }

  _getno() async{
    final  List<Map<String, dynamic>> sold= await DBprovider.db.getsolds();
    setState(() {
      all=sold.length;
    });

  }

  @override
  Widget build(BuildContext context) {

    _futurevalue=_getno();

    return  Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black38,
        title: Text("Werefa"),
      ),
      //backgroundColor: Colors.white,
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(

                    child: Reuseable(color: Color(0xff1d1e33),child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Text("All Tickets",
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white
                          ),
                        ),
                        SizedBox(height: 20,),
                        FutureBuilder(
                            future: _futurevalue,
                            builder: (context, snapshot){

                          switch(snapshot.connectionState){
                            case ConnectionState.none:
                              return Text('Waiting...');
                            case ConnectionState.active:
                              return  Text('Waiting...');
                            case ConnectionState.done:
                              return  Text(all.toString(),style: TextStyle(fontSize: 40),);
                            default:
                              return Text(all.toString(),style: TextStyle(fontSize: 40),);
                          }

                        })

                      ],

                    )
                    ),
                  ),
                ),
              ],
            ),
          ),



          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(

                    child: Reuseable(color: Color(0xff1d1e33),child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Text("Scanned Tickets",
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text(scanned.toString(),style: TextStyle(fontSize: 40),),

                      ],

                    )
                    ),
                  ),
                ),
              ],
            ),
          ),


          GestureDetector(
            onTap: (){
              _scanQR();
              //_showMyDialog();
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                      Icons.scanner
                  ),
                  Text("Scan Ticket",style: TextStyle(fontSize: 30),)
                ],
              ),
              margin: EdgeInsets.only(top: 10),
              color: Colors.red,
              width: double.infinity,
              height: 80,
            ),
          ),
        ],
      ),

    );
  }
}
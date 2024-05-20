import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Worldle'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(color: Colors.yellow,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(30, 20, 36, 20),
              itemCount: 30,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: 5,
              ), 
              itemBuilder: (context, index){
                return Container(color: Colors.red,);
              }
              ),
            )),
          Expanded(
            flex: 4,
            child: Container(color: Colors.green,))
        ],
      ),
    );
  }
}
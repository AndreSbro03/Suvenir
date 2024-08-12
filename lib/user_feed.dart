import 'package:flutter/material.dart';

class UserFeed extends StatelessWidget {
  const UserFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Gallerizz"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
      ),
      body: PageView( 
        scrollDirection: Axis.vertical,
        children: [
          ImageViewer(),
          ImageViewer(),
          ImageViewer(),
          ImageViewer(),
          ImageViewer(),
          ImageViewer(),
          ImageViewer() 
        ],


      )
    );

  }

  Container ImageViewer() {
    return Container(
      decoration: const BoxDecoration( 
        image: DecorationImage(
          image: NetworkImage('https://imgs.search.brave.com/u3C1AOf13EJQXT3_5TK1npYra7NT0MuwJYC2tFfRxCU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTM0/NDYyMjI3MS9waG90/by9mYW1pbHktcG9y/dHJhaXQuanBnP3M9/NjEyeDYxMiZ3PTAm/az0yMCZjPTJhXzZ0/a3RHaGtpR19wbTdQ/RlE4LXg1c0pBRjJQ/QlFyZHRUTzB1LU1o/UGM9')
        )
      )
    );
  }
}
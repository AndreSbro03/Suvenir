import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.paths, required this.isChecked, required this.apply});

  final List<AssetPathEntity> paths;
  final Wrapper<List<bool>> isChecked;
  final Function apply;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text("Select Folders"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: getHeight(context) * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    child: const Text("Select All"),
                    onPressed: () {
                      setState(() {
                        for(int i = 0; i < widget.isChecked.value.length; ++i){
                          if(!widget.isChecked.value[i]) widget.isChecked.value[i] = true;
                        }
                      });
                    }
                  ),
                  ElevatedButton(
                    child: const Text("Deselect All"),
                    onPressed: (){
                      setState(() {
                        for(int i = 0; i < widget.isChecked.value.length; ++i){
                          if(widget.isChecked.value[i]) widget.isChecked.value[i] = false;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ListView.builder(
                  itemCount: widget.paths.length,
                  /*prototypeItem: ListTile(
                    title: Text(widget.paths.first.name),
                  ),*/
                  itemBuilder: (_, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: getWidth(context) * 0.70,
                          child: Text(widget.paths[index].name)
                        ),                        
                        Checkbox(value: widget.isChecked.value[index], onChanged: (_) {
                            setState(() {
                              widget.isChecked.value[index] = !widget.isChecked.value[index];
                            });
                          }
                        ),                                          
                      ],
                    );
                  }
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: GestureDetector(
                onTap: () {
                  widget.apply();
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: getHeight(context) * 0.07,
                  width: getWidth(context) * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(40),
                    //border: Border.all( color: Colors.amber, width: 2.0,)
                  ),
                  child:  const Center(
                    child: Text(
                      "Apply",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
library kaching_counter_pkg;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyKachingCounter extends StatefulWidget {
  late int start;
  late int end;
  late List<int> endArr = [];
  late List<int> startArr = [];
  late int len, time;
  late bool autostart;

  MyKachingCounter(this.end, {this.start=0 , this.autostart=true , Key? key}) : super(key: key) {
    String str;
    List<String> strArr;

    str = end.toString();
    strArr = str.split("");
    for (String s in strArr) { endArr.add(int.parse(s)); }
    len = endArr.length;
    print("end ================ $endArr");

    startArr = List.filled(len, 0);

    if(start!=0){//not 0
      str = start.toString();
      strArr = str.split("");
      int diff = len - strArr.length;
      for (int i = 0; i < strArr.length; i++) {
        String s = strArr[i];
        startArr[i+diff] =  int.parse(s);
      }

    }
    else{//start is 0
      for(int i = len-1; i >=0; i-- ){
        startArr[i] = (len-1) - i;
      }
    }
    print("start============= $startArr");

  }

  @override
  State<MyKachingCounter> createState() => _MyKachingCounterState();
}

class _MyKachingCounterState extends State<MyKachingCounter> with TickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _animationController;
  late AudioPlayer ply1,ply2,ply3;


  void getAnimationsReady(){
    _animationController = AnimationController(duration: Duration(seconds: widget.len), vsync: this);
    _animation = IntTween(begin: widget.start, end: widget.end).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    if (widget.autostart) { goGoGo(); }
  }

  Future<void> getAudioReady() async{
    ply1 = AudioPlayer();
    await ply1.setAsset("assets/audio/reel.mp3");
    ply2 = AudioPlayer();
    await ply2.setAsset("assets/audio/cut.mp3");
    ply3 = AudioPlayer();
    await ply3.setAsset("assets/audio/kaching.mp3");
    print("DONE!!");
  }

  void goGoGo(){
    _animationController.forward();
  }


  @override
  void dispose() {
    ply1.dispose();ply2.dispose();ply3.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    int count=0;
    int valz=0;
    int div = widget.end~/widget.len;
    String suffix="";
    getAudioReady();
    getAnimationsReady();
    if (widget.autostart) { playerStuff(1);}


    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          int last = _animation.value % 10;

          for(int i = 0; i<widget.len; i++){
            for(int j=0; j<widget.len; j++){
              if(j==i){continue;}
              if(widget.startArr[i]==widget.startArr[j]){
                widget.startArr[i]++;
              }
            }
            widget.startArr[i] += last;
            if ((widget.startArr[i]>9)) { widget.startArr[i] = widget.startArr[i] % 10;}
          }


          if(_animation.value - valz > div){
            playerStuff(2);
            count++;
            valz = _animation.value;

            suffix = "${widget.endArr[widget.len-count]}$suffix";
            print("$valz-------------${widget.startArr} / $suffix");
          }
          else if (_animation.value > (widget.end * 0.95) ){ //(count==widget.len-1){ //(count<widget.len) && ((widget.end - _animation.value) < div*0.15 ) ){//
            count++;                                          //for some reason (animation.value == widget.end) takes too long to happen!?!?
            suffix = "${widget.endArr[0]}$suffix";
            playerStuff(11);
            playerStuff(3);
            print("### last session.... with count: $count");
            _animationController.reset();
          }

          String str = widget.startArr.join();
          if(_animationController.status == AnimationStatus.forward) {
            str = "${str.substring(0, str.length - count)}$suffix";
            print("$count....................................................$str");
          }
          else if (_animationController.status == AnimationStatus.dismissed) {
            str = widget.start.toString();
            if(count==widget.len){str = widget.end.toString();}
            print("$count. . .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  $str");
          }


          return Text(str, style: const TextStyle(fontSize: 58));//_animation.value.toString());
        });
  }

  Future<void> playerStuff(int i) async {
    if(i==1){ await ply1.setVolume(1.0); ply1.play();}
    else if(i==2){ await ply2.setAsset("assets/audio/cut.mp3"); ply2.play();}
    else if(i==3){ await ply3.play(); ply3.dispose(); _animationController.dispose(); print("### player3().... disposed");}
    else if(i==11){await ply1.stop();await ply1.dispose();await ply2.dispose();}
  }
}

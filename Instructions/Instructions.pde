//2022年8月用のプログラム
//唾液計測の指示とデバイスの制御を行う．
import processing.serial.*;

import ddf.minim.*;
import ddf.minim.signals.*;
import javax.swing.*;
import java.awt.*;
import controlP5.*;

PrintWriter output;

//turnは唾液が出てくるタイミングの配列，テスト用にtestがある
int[]turnA = {0, 30, 180};
int[]turnB = {0, 180, 30};
int[]turnC = {30, 0, 180};
int[]turnD = {30, 180, 0};
int[]turnE = {180, 0, 30};
int[]turnF = {180, 30, 0};
int[]test = {30, 0, 3};

/////実験時はここを変更する///////////////////////
int[]turn = turnB;
String playerName = "sumida";
//定数，基本的にINTERVALは300，MEASUREMENT_TIMEは30，ADJUSTMENTは260
final int INTERVAL = 300;
final int MEASUREMENT_TIME = 30;
final int ADJUSTMENT =260;
/////////////////////////////////////////////////

int time;
int start_time;
int timestamp;
boolean watte;
boolean time_flag;
boolean final_flag;
String odor;
int temp_time;

Minim minim;
AudioOutput out;
SineWave sine;
Serial myPort;

ControlP5 cp5;
JLayeredPane pane;
JTextField[] jt = new JTextField[12];
String[]input_before = {"", "", "", "", "", "", "", "", "", "", "", ""};
String[]input_after = {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
String[]title = {"測定1回目", "測定2回目", "測定3回目", "測定4回目", "測定5回目", "測定6回目", "測定7回目", "測定8回目", "測定9回目", "測定10回目", "測定11回目", "測定12回目"};
String[]enter = {"enter1", "enter2", "enter3", "enter4", "enter5", "enter6", "enter7", "enter8", "enter9", "enter10", "enter11", "enter12"};

void setup() {
  size(850, 800);
  watte = false;
  time_flag = false;
  final_flag = false;
  timestamp = 0;
  odor = "OFF";
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600);
  println("myPortHasOpened");
  myPort.bufferUntil('\n');
  println("myPortHasConnected");
  delay(100);
  myPort.clear();
  String filename = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2); //日時でcsvファイル作成
  output = createWriter(playerName + filename + ".csv");
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  sine = new SineWave(440, 0.5, out.sampleRate());
  PFont font = createFont("Meiryo", 12);
  textFont(font);
  cp5 = new ControlP5(this);
  ControlFont cf1 = new ControlFont(font, 12);
  cp5.setFont(cf1);
  java.awt.Canvas canvas =
    (java.awt.Canvas) surface.getNative();
  pane = (JLayeredPane) canvas.getParent().getParent();
  for (int i=0; i<12; i++) {
    jt[i] = new JTextField();
    jt[i].setBounds(10, 60 + 60*i, 150, 30);
    pane.add(jt[i]);
    cp5.addBang(enter[i], 170, 60 + 60*i, 50, 30)
      .setCaptionLabel("入力")
      .getCaptionLabel()
      .align(ControlP5.CENTER, ControlP5.CENTER)
      ;
  }
}

void draw() {
  background(80);
  fill(255);
  PFont font = createFont("Meiryo", 12);
  textFont(font);
  for (int i=0; i<12; i++) {
    text(title[i], 10, 55 + 60*i);
    text("測定前", 230, 70 + 60*i);
    text("測定後", 230, 90 + 60*i);
    text(input_before[i], 280, 70 + 60*i);
    text(input_after[i], 280, 90 + 60*i);
  }
  font = createFont("Meiryo", 24);
  textFont(font);
  text("指示", 350, 300);
  font = createFont("Meiryo", 20);
  textFont(font);
  if (!(time_flag) && !(input_before[0] == "")) {
    //println(start_time);
    start_time = hour()*3600 + minute()*60 + second() - ADJUSTMENT;
    time_flag = true;
  }
  time = (hour()*3600 + minute()*60 + second()) - start_time;
  int temp_time = time % INTERVAL; //インターバルとの差の時間
  int remaining_time = INTERVAL - temp_time; //次のステップに行くまでの時間
  for (int i=0; i<12; i++) {
    if (input_before[i] == "") {
      text("口に入れる前のワッテの重量を"+ "\r\n" + title[i] + "に記入してください", 400, 350);
      watte = false;
      break;
    } else if (input_after[i] == "") {
      if (!watte) {
        if (remaining_time == 1) {
          watte = true;
          break;
        } else if (remaining_time > MEASUREMENT_TIME) {
          text((String.valueOf(remaining_time - MEASUREMENT_TIME)) + "秒後にワッテを口に入れてください", 400, 350);
          if ((remaining_time - MEASUREMENT_TIME) < 6) {
            if (timestamp == 0) {
              out = minim.getLineOut(Minim.STEREO);
              out.addSignal(sine);
              timestamp = millis();
              if (timestamp == 0) {
                timestamp = 1;
              }
            }
            //println(millis()-timestamp);
            if ((!(timestamp == 0)) && millis()-timestamp > 50 && millis()-timestamp < 1000) {
              out.close();
            } else if ((!(timestamp == 0)) && millis()-timestamp > 1000) {
              timestamp = 0;
            }
          }
          break;
        } else if (remaining_time  <=  MEASUREMENT_TIME) {
          text((String.valueOf(remaining_time - 1)) + "秒後にワッテを口から出してください", 400, 350);
          if ((remaining_time - 1) < 6) {
            if (timestamp == 0) {
              out = minim.getLineOut(Minim.STEREO);
              out.addSignal(sine);
              timestamp = millis();
              if (timestamp == 0) {
                timestamp = 1;
              }
            }
            if ((!(timestamp == 0)) && millis()-timestamp > 50 && millis()-timestamp < 1000) {
              out.close();
            } else if ((!(timestamp == 0)) && millis()-timestamp > 1000) {
              timestamp = 0;
            }
          }
          break;
        }
        break;
      } else {
        text("口に入れた後のワッテの重量を"+ "\r\n" + title[i]+ "に記入してください", 400, 350);
        break;
      }
    }
  }
  //text("残り"+ (String.valueOf(time)), 600, 500);
  boolean temp_flag;
  temp_flag = false;
  for (int i= 0; i < 3; i++) {
    temp_time = (INTERVAL * (3+ (i*4)))-MEASUREMENT_TIME;
    if (time > (temp_time -turn[i])&&(time < temp_time)) {
      println(temp_time);
      temp_flag = true;
      if (odor == "OFF") {
        myPort.write('1');
        odor = "ON";
        println("においON");
      }
      break;
    }
  }
  if (!temp_flag) {
    if (odor == "ON") {
      myPort.write('0');
      println("においOFF");
      odor = "OFF";
    }
  }
  if (!(input_after[11] == "")) {
    if (!final_flag) {
      for (int i=0; i<2; i++) {
        output.print(turn[i]);
        output.print(",");
      }
      output.println(turn[2]);
      for (int i=0; i<12; i++) {
        output.print(input_before[i]);
        output.print(",");
        output.println(input_after[i]);
      }
    }
    output.close();
    final_flag = true;
    text("これで実験は終わりです"+ "\r\n" +  "ありがとうございました", 400, 350);
  }
}
void enter1() {
  if (input_before[0] == "") {
    input_before[0] = jt[0].getText();
    jt[0].setText("");
  } else {
    input_after[0] = jt[0].getText();
    jt[0].setText("");
  }
}
void enter2() {
  if (input_before[1] == "") {
    input_before[1] = jt[1].getText();
    jt[1].setText("");
  } else {
    input_after[1] = jt[1].getText();
    jt[1].setText("");
  }
}
void enter3() {
  if (input_before[2] == "") {
    input_before[2] = jt[2].getText();
    jt[2].setText("");
  } else {
    input_after[2] = jt[2].getText();
    jt[2].setText("");
  }
}
void enter4() {
  if (input_before[3] == "") {
    input_before[3] = jt[3].getText();
    jt[3].setText("");
  } else {
    input_after[3] = jt[3].getText();
    jt[3].setText("");
  }
}
void enter5() {
  if (input_before[4] == "") {
    input_before[4] = jt[4].getText();
    jt[4].setText("");
  } else {
    input_after[4] = jt[4].getText();
    jt[4].setText("");
  }
}
void enter6() {
  if (input_before[5] == "") {
    input_before[5] = jt[5].getText();
    jt[5].setText("");
  } else {
    input_after[5] = jt[5].getText();
    jt[5].setText("");
  }
}
void enter7() {
  if (input_before[6] == "") {
    input_before[6] = jt[6].getText();
    jt[6].setText("");
  } else {
    input_after[6] = jt[6].getText();
    jt[6].setText("");
  }
}
void enter8() {
  if (input_before[7] == "") {
    input_before[7] = jt[7].getText();
    jt[7].setText("");
  } else {
    input_after[7] = jt[7].getText();
    jt[7].setText("");
  }
}
void enter9() {
  if (input_before[8] == "") {
    input_before[8] = jt[8].getText();
    jt[8].setText("");
  } else {
    input_after[8] = jt[8].getText();
    jt[8].setText("");
  }
}
void enter10() {
  if (input_before[9] == "") {
    input_before[9] = jt[9].getText();
    jt[9].setText("");
  } else {
    input_after[9] = jt[9].getText();
    jt[9].setText("");
  }
}
void enter11() {
  if (input_before[10] == "") {
    input_before[10] = jt[10].getText();
    jt[10].setText("");
  } else {
    input_after[10] = jt[10].getText();
    jt[10].setText("");
  }
}
void enter12() {
  if (input_before[11] == "") {
    input_before[11] = jt[11].getText();
    jt[11].setText("");
  } else {
    input_after[11] = jt[11].getText();
    jt[11].setText("");
  }
}

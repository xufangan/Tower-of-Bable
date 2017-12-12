import java.util.Map;
import websockets.*;
import processing.sound.*;
import geomerative.*;
import fisica.*;


WebsocketServer socket;

boolean drawText = false;
String currentSpeechText;
Speech speech;

FWorld world;
float posX = 0;
float posY = 0;
RFont font;

void setup() {
  size(500,700);
  background(255);
  fill(0);
  noStroke();
  socket = new WebsocketServer(this, 8888, "/speechsocket");
  RG.init(this);
  Fisica.init(this);
  Fisica.setScale(1);
  
  RG.setPolygonizer(RG.ADAPTATIVE);
  world = new FWorld();
  world.setGravity(0, 200);
  world.setEdges(this, color(255));
  world.remove(world.top);
  
  font = RG.loadFont("Roboto-Regular.ttf");
}


void draw() {
  if (drawText == true){
  background(255);
  fill(0);
  noStroke();
  world.draw(this);
  world.step();
  }
}



void webSocketServerEvent(String msg){

  println("From SERVER: " + msg);
  drawText = true;
  
  speech = new Speech();
  speech.speechText = msg; 
  speech.getSpeechShape();
 
  println(speech.childrenNum);
  //FChar chr = new FChar(msg);
  //if (chr.bodyCreated()) {
  //  world.add(chr);
  //  println("chr added");
  //} 

  
  for (int i = 0; i < speech.childrenNum; i++){ 
    PVector LetterPosition = new PVector();
    LetterPosition.x = speech.speechShape.children[i].getCenter().x + width/2;
    LetterPosition.y = speech.speechShape.children[i].getCenter().y + 20;
    println(i, LetterPosition.x, LetterPosition.y);
    RShape letterShape = speech.speechShape.children[i];
    
    FChar chr = new FChar(letterShape, LetterPosition.x, LetterPosition.y);
    if (chr.bodyCreated()) {
      world.add(chr);
      println(i, "chr added");
    } 
  }  
}






class Speech{  
  String speechText;
  String speechFont = "Roboto-Regular.ttf";
  int speechSize = 12; 
  RShape speechShape;
  int childrenNum;
  
  void getSpeechShape(){
    speechShape = RG.getText(speechText, speechFont, speechSize, CENTER);
    childrenNum = speechShape.countChildren();
  }
}


class FChar extends FPoly {
  RShape m_shape;
  RShape m_poly;
  float posX;
  float posY;
  boolean m_bodyCreated;
  
  FChar(RShape shp,float a, float b){
    super();  
    //String txt = sp;
    //RG.textFont(font, 32);
    posX = a;
    posY = b;
    m_shape = shp;
    println("shape delivered");
    m_poly = RG.polygonize(m_shape);
    
    //if (m_poly.countChildren() < 1) return;
    //m_poly = m_poly.children[0];    
    
    // Find the longest contour of our letter
    float maxLength = 0.0;
    int maxIndex = -1;
    for (int i = 0; i < m_poly.countPaths(); i++) {
      float currentLength = m_poly.paths[i].getCurveLength();
      if (currentLength > maxLength) {
        maxLength = currentLength;
        maxIndex = i;
      }
    }
  
    if (maxIndex == -1) return;
    
    RPoint[] points = m_poly.paths[maxIndex].getPoints();

    for (int i=0; i<points.length; i++) {
      this.vertex(points[i].x, points[i].y);
    }

    this.setFill(0);
    this.setNoStroke();
    
    this.setDamping(0);
    this.setRestitution(0.5);
    this.setBullet(true);
    this.setPosition(posX,posY);
    //this.setPosition(posX+10, height/5);
    
    //posX = (posX + m_poly.getWidth()) % (width-100);
  
    m_bodyCreated = true;
  }
  
  boolean bodyCreated(){
    return m_bodyCreated;  
  }
  
  void draw(PGraphics applet){
    preDraw(applet);
    m_shape.draw(applet);
    postDraw(applet);
  }
}
import processing.video.*;          //  Imports the OpenCV library

int sumpixels;
int Vwidth;
int Vheight;

PImage movementImg;   
ArrayList bubbles; 
PImage[] bubblePNG;

int poppedBubbles;
static int maxBubbles=10;
static float SPEED=0.2;


Capture video;
int[] previousFrame;

float alpha,beta;
float maxValue;
int maxPos;


void setup(){
  size(1280,960);
  
  Vwidth=640;
  Vheight=480;
  sumpixels=Vwidth*Vheight;
  
    bubblePNG=new PImage[25];
    for(int i=0;i<7;i++){
      int  j=i+1;
        bubblePNG[i]=loadImage("image/"+j+".png");
        bubblePNG[i].resize(120,120);
    }
  
    movementImg = new PImage( 640, 480 ); 
    bubbles = new ArrayList();              //  Initialises the ArrayList
    //bubblePNG = loadImage("cloud.png");  
    poppedBubbles = 0; 
    

    video = new Capture(this, Vwidth, Vheight);
    video.start(); 
    previousFrame=new int[sumpixels];
    
    alpha=1;
    beta=0.5;
    maxValue=0;
    maxPos=0;

    background(0);

}


void draw(){
    //background(0);
    
            if(video.available()){
                  video.read();
                  video.loadPixels();
            
            maxValue=0;
            maxPos=0;
    
                for(int i=0;i<sumpixels/Vwidth;i++){
                  for(int j=0;j<sumpixels/Vheight;j++){
                    int pos=i*Vwidth+j;
                    int soq=i*Vwidth+Vwidth-j-1;
                    
                    color c=video.pixels[pos];
                    float sz=findBrightness(pos);
                    //if(i>1&&i<sumpixels/Vwidth-1){
                    //sz=findBrightness(pos)+findBrightness(pos-1)+findBrightness(pos+1)+findBrightness(pos-Vwidth)+findBrightness(pos+Vwidth);
                    //sz/=6;
                    //}
                    
                    
                    
                    if(sz>0.9){
                       video.pixels[pos] = color(0,0,0);
                    }
                    
                    //==================================
                    
                    color currColor = c;
                    color prevColor = previousFrame[i];
                   
                    int currR = (currColor >> 16) & 0xFF; 
                    int currG = (currColor >> 8) & 0xFF;
                    int currB = currColor & 0xFF;
                    
                    int prevR = (prevColor >> 16) & 0xFF;
                    int prevG = (prevColor >> 8) & 0xFF;
                    int prevB = prevColor & 0xFF;
                    
                    int diffR = abs(currR - prevR);
                    int diffG = abs(currG - prevG);
                    int diffB = abs(currB - prevB);
                   
                    previousFrame[i] = currColor;
                    //==================================
                    
                    float find=sz*alpha+(diffR+diffG+diffB)/(255.0*3)*beta;
                      if(find>maxValue){
                        maxValue=find;
                        int x=soq%Vwidth;
                        int y=soq/Vwidth;
                        if(Math.pow(x-i,2)+Math.pow(y-j,2)>10)
                        maxPos=soq;
                       }
                    
                
               }
              }
              

             }
             background(0);
             // image(video,0,0);
              println(maxValue);
              
    
    
    
    
    
    
    
    
    if(poppedBubbles<maxBubbles){
    bubbles.add(new Bubble( (float)random( 40, Vwidth-100 ),(float)random( 40, Vheight-100 ), 40.0, 40.0));
    poppedBubbles++;
    }

    for ( int i = 0; i < bubbles.size(); i++ ){   
    Bubble _bubble = (Bubble) bubbles.get(i);    
    //ellipse(_bubble.bubbleX,_bubble.bubbleY,_bubble.bubbleWidth,_bubble.bubbleHeight);
    image(bubblePNG[_bubble.PNGNo],_bubble.bubbleX*2,_bubble.bubbleY*2);
    _bubble.update();   
     _bubble.collider(mouseX/2,mouseY/2);
    //_bubble.collider(maxPos%Vwidth,maxPos/Vwidth);
    if(_bubble.bubbleX<0||_bubble.bubbleX>Vwidth||_bubble.bubbleY<0||_bubble.bubbleY>Vheight)
    {
        bubbles.remove(i);
        _bubble=null;
        poppedBubbles--;
    }
   
    }
  
  
     
     fill(255);
     rect(maxPos%Vwidth*2,maxPos/Vwidth*2,6,6);
  
  
  
}


float findBrightness(int pos){
      return brightness(video.pixels[pos])/255.0;
}








class Bubble
{
  
  float bubbleX, bubbleY, bubbleWidth, bubbleHeight;    //  Some variables to hold information about the bubble
  
  float forceStrength;
  float forceAngle;
  
  int PNGNo;
  
  Bubble ( float bX, float bY, float bW, float bH )           //  The class constructor- sets the values when a new bubble object is made
  {
    bubbleX = bX;
    bubbleY = bY;
    bubbleWidth = bW;
    bubbleHeight = bH;
    forceStrength=0;
    forceAngle=0;
    PNGNo=(int)random(0,7);
  }
  
  int update()      //   The Bubble update function
  {
      if (forceStrength>0){
          bubbleX+=this.forceStrength*Math.cos(this.forceAngle);
          bubbleY-=this.forceStrength*Math.sin(this.forceAngle);
          return 1;
      }                    
    return 0;
  }
  
  public int collider(float forceX, float forceY){
    double distance=Math.pow(forceX-bubbleX,2)+Math.pow(forceY-bubbleY,2);
    if(distance<Math.pow( bubbleWidth,2)){
      int flag=forceX<bubbleX?1:-1;
      int flag2=forceY>bubbleY?1:-1;
      forceStrength+=SPEED;
      double forceAngleCos=Math.pow(forceX-bubbleX,2)/distance;
      float www=(float)forceAngleCos;
      forceAngle=(float)Math.acos(sqrt(www))*flag*flag2;
      return 1;
    }   
    
    return 0;
  }
  
  
}
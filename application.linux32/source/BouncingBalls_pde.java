import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class BouncingBalls_pde extends PApplet {

float G = pow(66.74f,-12); 
String imageString = "http://images.spaceref.com/news/2012/ooM170334512L_thumb.jpg";
float collisionFactor = 0.77f;
float frictionFactor = 0.5f;
int totalBalls = 15;
Ball[] balls = new Ball[totalBalls];
int currentBall;
int totalNeuStars = 10;
float neutronStarMassScaler = pow(10, 25);
NeutronStar[] neuStars = new NeutronStar[totalNeuStars];
boolean cometMode;
int currentNeuStar;
float[] distance;

int loadingTime = 20000;
int startTime;
int width, height;
int startPhase; 

public void setup() {
    width = 600;
    height = 700;
    
    noStroke();
    
    background(0);
    cometMode = false;
};

public void InitScen(){
    println("Starting Program: Load phase initiated.");
    println("Starting InitScen");
    currentBall = 0;
    currentNeuStar = 0;
    for (int i = 0; i < totalNeuStars; i++)
    {
      NeutronStar neuStar = new NeutronStar();
      neuStars[i] = neuStar;
      println(" -- Neutron Star  nr " + i + " constructed");
    }
    println("- Neutron Stars initialized");

    for (int i = 0; i < totalBalls; i++) { 
      PVector initPos = new PVector(0, 0);
      PVector initVelo = new PVector(0,0);
      PVector initAcc = new PVector( 0, 0);
      float r = 30.0f;
      int c = color(random(255), random(255), random(255));
      float m = r; 
      Ball ball = new Ball(i, imageString, initPos, initVelo, initAcc, r, c, m);
      balls[i] = ball;
      println(" -- Ball nr " + i + " constructed");
    }
    println("- Balls initialied");
    println("InitScen finished");
    println("Load phase is complete.");
}

public void ShowLoadingScreen()
{
      background(0);
      textSize(32);
      fill(255);
      textAlign(CENTER);
      text("Loading...", width/2, height/2);
      textSize(24);
      text("Controls:", width/2, height*0.7f);
      textSize(16);
      text("Mouse (R/L)  -  Add/Remove Neutron Star", width/2, height*0.75f);
      text("n/N  -  Add/Remove Ball", width/2, height*0.8f);
      text("+/-  -  Preset size of Ball", width/2, height*0.85f);
      text("Space  -  Toggle Texture Mode", width/2, height*0.9f);
      noFill();
}

public void draw() {
    switch(startPhase)
    {
      case 0:
        ShowLoadingScreen();
        thread("InitScen");
        startPhase++;
        return;
      case 1:
      while(balls[totalBalls -1] == null)
        delay(10000);
        
      background(0); 

      /* Render neutron stars who have been initiated  */
      for (int i = 0; i < totalNeuStars; i++)
      {
        if(neuStars[i].present == true)
          neuStars[i].Render();
      }

      /* Render balls who have been initiated  */
      for (int i = 0; i < totalBalls; i++) 
      {
          if(balls[i].present == true)
          {
            /* Apply gravity pull from all neutron stars  */
            for(int j = 0; j < totalNeuStars; j++)
            {
              if(neuStars[j].present == true)
              {
                balls[i].ApplyGravity(neuStars[j].mass, neuStars[j].pos);
              }
            }
             /* Update balls and render  */
              balls[i].Wallcollision();
              balls[i].Move();
              balls[i].Render();
          }
      }
      /* Check which balls who has collided  */ 
      for (int i = 0; i < totalBalls; i++) 
      {
           balls[i].Ballcollision(balls, totalBalls);
      }
      textSize(16);
      fill(255);
      textAlign(LEFT);
      text("Number of balls: " + currentBall, 10, 20);
      text("Number of neuron stars: " + currentNeuStar, 10, 40);
      noFill();

      return;
    }
};

public void keyPressed()
{
  if(key == '+')
  {
    balls[currentBall].AddToRadius(3.00f);
    if(balls[currentBall].radius > 75.0f)
      balls[currentBall].AddToRadius(-3.00f);
  } 
  
  if(key == '-')
  {
    balls[currentBall].AddToRadius(-3.00f);
    if(balls[currentBall].radius < 10.0f)
      balls[currentBall].AddToRadius(3.00f);
  } 
  
  if(key == ' ')
  {
    cometMode = !cometMode;
  }
  
  if(key == 'n') // Add ball
  {
    println("Making ball nr " + currentBall + " active.");
    balls[currentBall].present = !balls[currentBall].present;
    balls[currentBall].pos.set(mouseX, mouseY);
    currentBall++;
    if(currentBall >= totalBalls)
      currentBall = 0;
  }

  if(key == 'N') // Remove ball
  {
    currentBall--;
    if(currentBall < 0)
      currentBall = 0;
      
    balls[currentBall].present = !balls[currentBall].present;
    println("Making ball nr " + currentBall + " deactive.");

  }

   if(key == ESC)
  {
    exit();
  }
}

public void mousePressed()
{
  if(mouseButton == LEFT)
    startTime = millis();
  else if(mouseButton == RIGHT)
  {
    currentNeuStar--;
    if(currentNeuStar < 0)
        currentNeuStar = 0;
  }
}

public void mouseReleased()
{
  if(mouseButton == LEFT)
  {
    println("Making neutron star nr " + currentNeuStar + " active.");
    int timeElapsed = (millis() - startTime)/1000;
    neuStars[currentNeuStar].Init(timeElapsed);
    currentNeuStar++;
  }
  else if(mouseButton == RIGHT && currentNeuStar >= 0)
  {
    println("Making neutron star nr " + currentNeuStar + " deactive.");
    neuStars[currentNeuStar].present = false;
  }
}

class Ball {
  boolean present;
  int id;
  PVector pos;
  PVector velo;
  PVector acc;
  float radius;
  int col;
  float mass;
  PShape ballShape;
  PImage imageAsTexture;
  float angleOfVelo;
  PVector angularVelo;
  float momOfinertia;

  Ball(int i, String texString, PVector p, PVector v, PVector a, float r, int c, float  m)
  {
    present = false;
    id = i;
    pos = p;
    velo = v;
    acc = a;
    radius = r;
    col = c;
    mass = m;
    imageAsTexture = loadImage(texString); //<>//
    ballShape = createShape(SPHERE, radius);
    ballShape.setTexture(imageAsTexture);
    angleOfVelo = velo.heading();
    angularVelo = new PVector(0,0);
    momOfinertia = 0.4f * this.mass * this.radius * this.radius;
  }

  public void AddToRadius(float r)
  {
    /* Updates both radius and shape  */
    this.radius += r;
    this.ballShape = createShape(SPHERE, radius);
    this.ballShape.setTexture(imageAsTexture);
  }

  public void Move()
  {
    this.pos.x += this.velo.x;
    this.pos.y += this.velo.y;
    this.velo.x = (this.velo.x + this.acc.x);
    this.velo.y = (this.velo.y + this.acc.y);

    this.angleOfVelo = this.velo.heading();
    this.ballShape.rotate(this.angularVelo.mag()); 
  }
  
  /* Reflects current speed and keeps the balls in the window  */
  public void Wallcollision()
  {
    if( this.pos.x + this.radius > width )
   {
     this.velo.x *= -1;
     this.pos.x = width - this.radius;
   }
   
   else if( this.pos.x - this.radius < 0)
   {
     this.velo.x *= -1;
     this.pos.x = this.radius;
   }
  
   else if( this.pos.y + this.radius > height )
   {
     this.velo.y *= -1;
     this.pos.y = height - this.radius;
   }
   else if(this.pos.y - this.radius < 0)
   {
     this.velo.y *= -1;
     this.pos.y = this.radius;
   }
  }
  
  public void Ballcollision(Ball[] otherBalls, int size)
  {
    float collisionMass; 
    float distanceVecMag, minimumDistance, dot_Vrel;
    float veloDiff1, veloDiff2;
    float v1_p, v2_p, u1_p, u2_p;
    PVector u1 = new PVector(0,0), u2 = new PVector(0,0);
    PVector e_p = new PVector(0,0), e_n = new PVector(0,0);
    PVector e_Vrel = new PVector(0,0);

    for( int i = this.id + 1; i < size; i++ )
    {
          PVector distanceBalls = new PVector(0, 0);
          minimumDistance = (this.radius) + (otherBalls[i].radius);
          distanceBalls = PVector.sub(otherBalls[i].pos, this.pos);
          distanceVecMag = distanceBalls.mag();
          if ( distanceVecMag < minimumDistance )
          {
            /* collision as course formula */
            e_p = distanceBalls.normalize();
            e_Vrel = PVector.sub(otherBalls[i].velo, this.velo).normalize();
            dot_Vrel = PVector.dot(e_Vrel, e_p);
            if( dot_Vrel < 0)
            {
              e_n = (e_Vrel.cross(e_p)).cross(e_p).normalize(); 
              collisionMass = (this.mass + otherBalls[i].mass);
              v1_p = PVector.dot( this.velo, e_p);
              v2_p = PVector.dot( otherBalls[i].velo, e_p);
              
              u1_p  = ((this.mass - collisionFactor * otherBalls[i].mass)/collisionMass) * v1_p
                            + (((1 + collisionFactor)* otherBalls[i].mass)/collisionMass) * v2_p;
                            
              u2_p  = ((otherBalls[i].mass - collisionFactor * this.mass)/collisionMass) * v2_p
                            + (((1 + collisionFactor)*this.mass)/collisionMass) * v1_p;
                            
              /* Update new velocities */
              veloDiff1 = u1_p - v1_p;
              veloDiff2 = u2_p - v2_p;
              PVector mye_n = e_n.mult(frictionFactor);
              PVector e_pn = e_p.add(mye_n);
              u1 = PVector.add(this.velo, PVector.mult(e_pn, veloDiff1));
              u2 = PVector.add(otherBalls[i].velo, PVector.mult(e_pn, veloDiff2));
              
              this.velo = u1;
              otherBalls[i].velo = u2;

              /* Update new angular velocities  */
              /* Using formla  w = m*r*my*(u-v)/I */
              float angluarVeloCoef1 = this.mass * this.radius * frictionFactor * veloDiff1/
                                      this.momOfinertia;
              this.angularVelo = e_p.cross(e_n).mult(angluarVeloCoef1);

              float angluarVeloCoef2 = otherBalls[i].mass * otherBalls[i].radius * frictionFactor * veloDiff1/
                                      otherBalls[i].momOfinertia;

              this.angularVelo = e_p.cross(e_n).mult(-angluarVeloCoef2);  // Since e_p is the opposite direction, make angularVeloCoef negative

            }
            distanceBalls.set(0,0);
            
          }
    }
  } 

  /* Uses an external object to generate an acceleration toward it  */
  public void ApplyGravity(float M, PVector gravityPos)
  {
      float a;
      float distance;
      PVector R =  PVector.sub(gravityPos, this.pos); 

      distance = R.mag();
      if(distance < this.radius)
        distance = this.radius;
      
      float F = G*M*this.mass/(distance*distance);
      a = F/this.mass;
      R = R.normalize();
      R = R.mult(a);
      this.acc = R.mult(a);
  }

  /* Render with two different modes  */
  public void Render()
  {
    if(cometMode == false)
    {
      fill(this.col);
      ellipse(this.pos.x, this.pos.y, 2*this.radius, 2*this.radius );
      fill(255);
      line(this.pos.x, this.pos.y, this.pos.x + this.radius, this.pos.y + this.radius);
    }
    else
      shape(this.ballShape, this.pos.x, this.pos.y);
  }

}

class NeutronStar
{
  boolean present;
  float mass;
  float radius;
  PVector pos;
  int col;

  NeutronStar()
  {
    this.present = false;
    this.mass = 0;
    this.radius = 0;
    this.pos = new PVector(0,0);
    this.col = 255;
  }

  public void Init(int timePressed)
  {
    if(timePressed > 5)
      timePressed = 5; 
    if(timePressed <= 1)
      timePressed = 1;

    this.present = true;
    this.pos.set(mouseX, mouseY);
    this.mass = timePressed * neutronStarMassScaler;
    this.radius = timePressed * 4;
    
  }
  
  public void Render()
  {
    fill(this.col);
    ellipse(this.pos.x, this.pos.y, this.radius, this.radius );
  }
}
  public void settings() {  size(600, 700, P3D);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "BouncingBalls_pde" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

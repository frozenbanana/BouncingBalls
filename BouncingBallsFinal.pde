float G = pow(66.74,-12); 
String imageString = "http://images.spaceref.com/news/2012/ooM170334512L_thumb.jpg";
float collisionFactor = 0.77;
float frictionFactor = 0.5;
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

void setup() {
    width = 600;
    height = 700;
    size(600, 700, P3D);
    noStroke();
    smooth();
    background(0);
    cometMode = false;
};

void InitScen(){
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
      float r = 30.0;
      color c = color(random(255), random(255), random(255));
      float m = r; 
      Ball ball = new Ball(i, imageString, initPos, initVelo, initAcc, r, c, m);
      balls[i] = ball;
      println(" -- Ball nr " + i + " constructed");
    }
    println("- Balls initialied");
    println("InitScen finished");
    println("Load phase is complete.");
}

void ShowLoadingScreen()
{
      background(0);
      textSize(32);
      fill(255);
      textAlign(CENTER);
      text("Loading...", width/2, height/2);
      textSize(24);
      text("Controls:", width/2, height*0.7);
      textSize(16);
      text("Mouse (R/L)  -  Add/Remove Neutron Star", width/2, height*0.75);
      text("n/N  -  Add/Remove Ball", width/2, height*0.8);
      text("+/-  -  Preset size of Ball", width/2, height*0.85);
      text("Space  -  Toggle Texture Mode", width/2, height*0.9);
      noFill();
}

void draw() {
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

void keyPressed()
{
  if(key == '+')
  {
    balls[currentBall].AddToRadius(3.00);
    if(balls[currentBall].radius > 75.0)
      balls[currentBall].AddToRadius(-3.00);
  } 
  
  if(key == '-')
  {
    balls[currentBall].AddToRadius(-3.00);
    if(balls[currentBall].radius < 10.0)
      balls[currentBall].AddToRadius(3.00);
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

void mousePressed()
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

void mouseReleased()
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
  color col;
  float mass;
  PShape ballShape;
  PImage imageAsTexture;
  float angleOfVelo;
  PVector angularVelo;
  float momOfinertia;

  Ball(int i, String texString, PVector p, PVector v, PVector a, float r, color c, float  m)
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
    momOfinertia = 0.4 * this.mass * this.radius * this.radius;
  }

  void AddToRadius(float r)
  {
    /* Updates both radius and shape  */
    this.radius += r;
    this.ballShape = createShape(SPHERE, radius);
    this.ballShape.setTexture(imageAsTexture);
  }

  void Move()
  {
    this.pos.x += this.velo.x;
    this.pos.y += this.velo.y;
    this.velo.x = (this.velo.x + this.acc.x);
    this.velo.y = (this.velo.y + this.acc.y);

    this.angleOfVelo = this.velo.heading();
    this.ballShape.rotate(this.angularVelo.mag()); 
  }
  
  /* Reflects current speed and keeps the balls in the window  */
  void Wallcollision()
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
  
  void Ballcollision(Ball[] otherBalls, int size)
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
  void ApplyGravity(float M, PVector gravityPos)
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
  void Render()
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
  color col;

  NeutronStar()
  {
    this.present = false;
    this.mass = 0;
    this.radius = 0;
    this.pos = new PVector(0,0);
    this.col = 255;
  }

  void Init(int timePressed)
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
  
  void Render()
  {
    fill(this.col);
    ellipse(this.pos.x, this.pos.y, this.radius, this.radius );
  }
}

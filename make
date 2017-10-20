float collisionFactor = 0.97;
float frictionFactor = 0.0;
int totalBalls = 2;
Ball[] balls = new Ball[totalBalls];
PVector spawnPos;
float[] distance;
int width, height;
 
void setup() {
    width = 600;
    height = 700;
    size(600, 700);
    noStroke();
    smooth();
    background(0);
    spawnPos = new PVector(width / 2, height / 2);
    
    for (int i = 0; i < totalBalls; i++) { 
        PVector initPos = new PVector(spawnPos.x, spawnPos.y);
        PVector initVelo = new PVector( random(8) - 4, random(8) - 4);
        PVector initAcc = new PVector( 0, 4.41);
        float r = random(10) + 4.0;
        color c = color(random(255), random(255), random(255));
        float m = r/2; 
        Ball ball = new Ball(i, initPos, initVelo, initAcc, r, c, m);
        balls[i] = ball;
    }
};
 
void draw() {
    background(0);
    for (int i = 0; i < totalBalls; i++) {
        balls[i].WallCollision();
        balls[i].BallCollision(balls, totalBalls);
        balls[i].Move();
        balls[i].Render(); 
    }
};
 
 
class Ball {
  int id;
  PVector pos;
  PVector velo;
  PVector acc;
  float radius;
  color col;
  float mass;
  
  Ball(int i, PVector p, PVector v, PVector a, float r, color c, float m)
  {
    id = i;
    pos = p;
    velo = v;
    acc = a;
    radius = r;
    col = c;
    mass = m;
  }
  
  void Move()
  {
    this.pos.x += this.velo.x;
    this.pos.y += this.velo.y;
   // this.velo.x -= this.acc.x;
   // this.velo.y -= this.acc.y;
  }
  
  void WallCollision()
  {
    if( this.pos.x + this.radius > width || this.pos.x - this.radius < 0)
   {
     this.velo.x *= -1;
   }
    if( this.pos.y + this.radius > height || this.pos.y - this.radius < 0)
   {
     this.velo.y *= -1;
   }
  }
  
  void BallCollision(Ball[] otherBalls, int size)
  {
    float minimalDistance;
    for( int i = this.id + 1; i < size; i++ )
    {
          PVector distanceBalls = new PVector(0, 0);
          minimalDistance = this.radius + otherBalls[i].radius; //<>//
          distanceBalls.add(this.pos).sub(otherBalls[i].pos);
          if ( distanceBalls.mag() < minimalDistance || distanceBalls.mag() > 0.5 )
          {
            /* Collision as course formula */
            PVector e_p = distanceBalls.normalize();
            PVector e_Vrel = this.velo.sub(otherBalls[i].velo).normalize();
            PVector e_n = e_Vrel.cross(e_p).cross(e_p);
            float collisonMass = (this.mass + otherBalls[i].mass);
            float v1_p = this.velo.dot(e_p);
            float v2_p = otherBalls[i].velo.dot(e_p);
            
            float u1_p  = (this.mass - collisionFactor * otherBalls[i].mass/collisonMass) * v1_p
                          + ((1 + collisionFactor)*otherBalls[i].mass/collisonMass) * v2_p;
                          
            float u2_p  = (otherBalls[i].mass - collisionFactor * this.mass/collisonMass) * v2_p
                          + ((1 + collisionFactor)*this.mass/collisonMass) * v1_p;
                          
            /* Update new velocities */
            float veloDiff1 = u1_p - v1_p;
            float veloDiff2 = u2_p - v2_p;
            this.velo.add(e_p.add(e_n.mult(frictionFactor).mult(veloDiff1)));
            otherBalls[i].velo.add(e_p.add(e_n.mult(frictionFactor).mult(veloDiff2)));
            distanceBalls.set(0,0);
            }
    }
} 


void Render()
{
       fill(this.col); //<>//
       ellipse(this.pos.x, this.pos.y, this.radius * 2, this.radius * 2);
  }
}

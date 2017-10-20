# BouncingBalls
*Physics Project*

## Q: What is Bouncing Balls?
 Bouncing Balls is a light-weight space simulation made by me for a physics project. 
 The user can spawn spheres called Balls with various radii, mass and color. The user can also spawn
 a so called Neutron Stars causing gravitational pull on the Balls.
   
 
## Q: What is the main features?
Ball collision in two dimensions, acceleration calculation.

   The equation used for collision is:
   
   - Calculate new velocity:
   
   **u_i = v_i + (u_ip - v_ip) (e_p + e_n)     ,where e,v,e are 2D - vectors**
   
   - Calculate new angular velocity:
   
   **w = m*r*my*(u_p - v_p)/I * (e_r x e_n)     ,where e,v,e are 2D - vectors  and I = 0.4mr^2**
   
   - Calculate gravitational pull:
   
  **F = G*M*m/R^2                             ,where R is distance between objects and G is 6.674 * 10^-11**
  **a = F/m**
   
  
## Q: What are the limitations?
   - The Balls and Neutron Stars are initiated with a predefined sized array. The maximum number of Balls and 
    Neutron Stars are 15 and 10.
   - When balls are colliding with a wall there is no energy lost in the collision.
   - Neutron Stars are not subject to collision. 
   - The density of the balls are constant. The value of radius is the same as the mass.
   - Movement is restricted to two dimensions.
  
  
## Q: How to run?
 Run the .exe-file approriate to your system or use the makefile. 
   Enjoy!

class Particle {
  
  int lifetime;
  float x, y;
  color c; 
  
  Particle() {
    x = random(0,1000);
    y = random(0,400);
    lifetime = (int)random(0,life);
    c = color(random(0,255), random(0,255), random(0,255));
  }
  
  void move(float x, float y) {
    stroke(c);
    strokeWeight(2);
    
    beginShape(POINTS);
    vertex(x,y);
    endShape();
    lifetime--;
    
    if (lifetime == 0) {
      x = random(0,width);
      y = random(0,height);
      lifetime = (int)random(0,200);
    } 
    
   this.x = x;
   this.y = y;
  }
  
  float getX() {return x;}
  float getY() {return y;}
}
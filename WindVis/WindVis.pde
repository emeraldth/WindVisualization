// uwnd stores the 'u' component of the wind.
// The 'u' component is the east-west component of the wind.
// Positive values indicate eastward wind, and negative
// values indicate westward wind.  This is measured
// in meters per second.
Table uwnd;

// vwnd stores the 'v' component of the wind, which measures the
// north-south component of the wind.  Positive values indicate
// northward wind, and negative values indicate southward wind.
Table vwnd;

// An image to use for the background.  The image I provide is a
// modified version of this wikipedia image:
//https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
// If you want to use your own image, you should take an equirectangular
// map and pick out the subset that corresponds to the range from
// 135W to 65W, and from 55N to 25N
PImage img;

Particle[] particles;
int particleAmount = 5000;
int life = 100;
int step = 1;

void setup() {
  // If this doesn't work on your computer, you can remove the 'P3D'
  // parameter.  On many computers, having P3D should make it run faster
  size(700, 400, P3D);
  pixelDensity(displayDensity());
  
  img = loadImage("background.png");
  uwnd = loadTable("uwnd.csv");
  vwnd = loadTable("vwnd.csv");
  
  particles = new Particle[particleAmount];
  for (int i = 0; i < particles.length; i++) {
    particles[i] = new Particle();
  }
}

void draw() {
  background(255);
  image(img, 0, 0, width, height);
  drawMouseLine();
  
  for (Particle p : particles) {
    float x = p.getX();
    float y = p.getY();
    
    //1
    
    // get direction
    float dx = readInterp(uwnd, x, y);
    float dy = -readInterp(vwnd, x, y);
    
    // set distance to step size
    float dist = dist(x, y, x+dx, y+dy);
    dist = step/dist;
    
    //2
    
    float dx2 = readInterp(uwnd, x+dx*dist, y+dy*dist);
    float dy2 = -readInterp(vwnd, x+dx*dist, y+dy*dist);
    
    dist = dist(x, y, x+dx, y+dy);
    dist = .5*step/dist;
    
    // 3
    float dx3 = readInterp(uwnd, x+dx2*dist, y+dy2*dist);
    float dy3 = -readInterp(vwnd, x+dx2*dist, y+dy2*dist);
    
    dist = dist(x, y, x+dx3, y+dy3);
    dist = step/dist;
    
    //4
    
    p.move(x + dx3*dist,y + dy3*dist);
  }
  
}

void drawMouseLine() {
  stroke(0);
  // Convert from pixel coordinates into coordinates
  // corresponding to the data.
  float a = mouseX * uwnd.getColumnCount() / width;
  float b = mouseY * uwnd.getRowCount() / height;
  
  // Since a positive 'v' value indicates north, we need to
  // negate it so that it works in the same coordinates as Processing
  // does.
  float dx = readInterp(uwnd, a, b) * 10;
  float dy = -readInterp(vwnd, a, b) * 10;
  line(mouseX, mouseY, mouseX + dx, mouseY + dy);
}

// Reads a bilinearly-interpolated value at the given a and b
// coordinates.  Both a and b should be in data coordinates.
float readInterp(Table tab, float x, float y) {
  
  int x1 = int(x);
  int x2 = int(x)+1;
  int y1 = int(y);
  int y2 = int(y)+1;
  
  float q11 = readRaw(tab, x1, y1);
  float q21 = readRaw(tab, x1, y2);
  float q12 = readRaw(tab, x2, y1);
  float q22 = readRaw(tab, x2, y2);
  
  float fxy1 = (x2-x)/(x2-x1)*q11 + (x-x1)/(x2-x1)*q21;
  float fxy2 = (x2-x)/(x2-x1)*q12 + (x-x1)/(x2-x1)*q22;
  
  return (y2-y)/(y2-y1)*fxy1 + (y-y1)/(y2-y1)*fxy2;
}

// Reads a raw value 
float readRaw(Table tab, int x, int y) {
  if (x < 0) {
    x = 0;
  }
  if (x >= tab.getColumnCount()) {
    x = tab.getColumnCount() - 1;
  }
  if (y < 0) {
    y = 0;
  }
  if (y >= tab.getRowCount()) {
    y = tab.getRowCount() - 1;
  }
  return tab.getFloat(y,x);
}
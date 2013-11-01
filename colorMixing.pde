import de.voidplus.leapmotion.*;
LeapMotion leap;

Boolean debug = true;
int fps = 60;
float blade_w = PI/3.0;
int inner_r = 0, outer_r = 0;
int slowdown = 10;

PVector hand_position = new PVector(0, 0, 0);
PVector hand_position_pre = new PVector(0, 0, 0);
float dist = 0;
//float[] avrg_dist = new float[5];
float velocity = 0;
float speed = 0; // the accumulated speed
int count = 0;
int interval = 6;
int x = 0;
int startTimmer = 0;
float rotate_interval = 0, rotate_angle = 0;
float[] blade_color = new float[3];
float saturation = 100, brightness = 100;
float blade_alpha = 100, bg_alpha = 0;
int point = 0;
float dot_move = 0;

void setup() {
  if (debug) size(800, 800, P3D);
  else size(1600, 1600);
  frameRate(fps);
  colorMode(HSB, 360, 100, 100, 100);

  init_var();

  leap = new LeapMotion(this);
}

void draw() {
  background(360, 0, 0, 100);

  drawFan();
  count++;
  if (count==6) {
    count = 0;
    getHand();
  }
  update();

  drawInterface();
  // draw the velocity map
  //drawVelocity();
}

void init_var() {
  //  for (int i=0; i<avrg_dist.length; i++) avrg_dist[i] = 0;
  inner_r = width/10;
  outer_r = width/2;
  float c = random(0, 120);
  for (int i=0; i<3; i++) {
    blade_color[i] = c+120*i;
  }
  PFont myFont = createFont("Georgia", inner_r/2);
  textFont(myFont);
  startTimmer = second()+15;
}

void drawFan() {
  noStroke();
  fill(0, 0, 100, blade_alpha);
  rect(0, 0, width, height);

  rotate_angle += rotate_interval;
  pushMatrix();
  translate(width/2, height/2);
  rotate(rotate_angle);
  for (int i=0; i<6; i+=2) {
    fill(blade_color[i/2], saturation, brightness, 100);
    beginShape();
    vertex(inner_r*cos(blade_w*i), inner_r*sin(blade_w*i));
    vertex(outer_r*cos(blade_w*i), outer_r*sin(blade_w*i));
    vertex((outer_r+width/40)*cos(blade_w*i+PI/10), (outer_r+width/40)*sin(blade_w*i+PI/10));
    vertex((outer_r+width/40)*cos(blade_w*(i+1)-PI/10), (outer_r+width/40)*sin(blade_w*(i+1)-PI/10));
    vertex(outer_r*cos(blade_w*(i+1)), outer_r*sin(blade_w*(i+1)));
    vertex(inner_r*cos(blade_w*(i+1)), inner_r*sin(blade_w*(i+1)));
    endShape(CLOSE);

    // the circle
    fill(abs(blade_color[i/2]-180), 0, 100, 100);
    ellipse((inner_r+dot_move)*cos(blade_w*i+PI/6.0), (inner_r+dot_move)*sin(blade_w*i+PI/6.0), inner_r/2, inner_r/2);
  }
  popMatrix();

  // draw the onion layer
  pushMatrix();
  translate(width/2, height/2);
  rotate(rotate_angle+PI);
  for (int i=0; i<6; i+=2) {
    fill(blade_color[i/2], 0, 100, blade_alpha);
    beginShape();
    vertex(inner_r*cos(blade_w*i), inner_r*sin(blade_w*i));
    vertex(outer_r*cos(blade_w*i), outer_r*sin(blade_w*i));
    vertex((outer_r+width/40)*cos(blade_w*i+PI/10), (outer_r+width/40)*sin(blade_w*i+PI/10));
    vertex((outer_r+width/40)*cos(blade_w*(i+1)-PI/10), (outer_r+width/40)*sin(blade_w*(i+1)-PI/10));
    vertex(outer_r*cos(blade_w*(i+1)), outer_r*sin(blade_w*(i+1)));
    vertex(inner_r*cos(blade_w*(i+1)), inner_r*sin(blade_w*(i+1)));
    endShape(CLOSE);
  }
  popMatrix();
}

void update() {
  speed -= slowdown;
  if (speed<0) speed = 0;
  println(speed); // 0-8000
  rotate_interval = map(constrain(speed, 0, 8000), 0, 8000, 0, PI/1.7);
  blade_alpha = map(constrain(speed, 0, 8000), 0, 2000, 0, 100);
  dot_move = map(constrain(speed, 0, 8000), 0, 3000, 0, outer_r-inner_r);
}

void drawInterface() {  
  stroke(0, 0, 0, 100);
  fill(0, 0, 100, 100);
  ellipse(width/2, height/2, inner_r*2, inner_r*2);
  noFill();
  ellipse(width/2, height/2, inner_r*2-10, inner_r*2);
  ellipse(width/2, height/2, inner_r*2, inner_r*2-10);

  textSize(inner_r/3);
  fill(0);
  textAlign(CENTER, CENTER);
  int timmer = constrain(15-int(millis()/1000), 0, 100);
  if (count>2) text(timmer, width/2, height/2-inner_r/2);
  textSize(inner_r/1.5);
  text(point, width/2, height/2+inner_r/2);
}

void getHand() {
  if (leap.getHands().size()==0) {
    println("no hand");
  }
  for (Hand hand : leap.getHands()) {
    //hand.draw();
    hand_position_pre = hand_position;
    hand_position   = hand.getPosition();

    //println(hand_position);
    //    dist = sq(hand_position.x-hand_position_pre.x)+sq(hand_position.y-hand_position_pre.y)+sq(hand_position.z-hand_position_pre.z);
    dist = dist(hand_position.x, hand_position.y, hand_position.z, hand_position_pre.x, hand_position_pre.y, hand_position_pre.z);
    //println(dist); // 0-125

    if (15-int(millis()/1000)>0) {
      speed += dist;
      point += int(dist)/10;
    }

    //    for (int i=1; i<avrg_dist.length-1; i++) {
    //      avrg_dist[i-1] = avrg_dist[i];
    //    }
    //    avrg_dist[avrg_dist.length-1] = dist;
    //    float sum = 0;
    //    for (int i=0; i<avrg_dist.length; i++) sum += avrg_dist[i];
    //    velocity = sum/avrg_dist.length;
    //    // println(velocity);
  }
}

void drawVelocity() {
  //ellipse(x, map(velocity, 0, 100, 0, 800),5, 5);
  ellipse(x, speed, 5, 5);
  x++;
}

// For Leap Motion
void leapOnInit() {
  println("Leap Motion is ready.");
}

void leapOnConnect() {
  println("Leap Motion Connect");
}


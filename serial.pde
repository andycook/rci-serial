
SerialThread serialThread;
String portName;
RCIPacket packet;
Serial testPort;

float offset = 0;

void setup() {
  size(600, 400);
  background(255);
  fill(0);
  PFont font;
  font = loadFont("Calibri-20.vlw"); 
  textFont(font);
  portName = "COM1";
  String listPorts[] = Serial.list();
  for (int i=0; i<listPorts.length; i++) {
    text(i + ") " + listPorts[i], 20, 20+30*i);
  }
  
  testPort = new Serial(this, "COM3", 115200);
  delay(50);
  // Create the thread
  serialThread = new SerialThread(testPort, "serial1", "COM3");//portName);
  serialThread.start();
}

void draw() {
  background(255);
  
  // Check to see if there is new data available from the thread
  if (serialThread.available()) {
    packet = serialThread.getPacket();
    text(packet.value,10,(20 + 20*offset) % height);
    offset++;
  }
  // Render everything
//  for (int i = 0; i < packet.length; i++) {
//    fill(0);
//    text(packet[i],10,(20+i*20 + offset) % height);
//  }

}


import processing.serial.*;
SerialReader serialReader;
String portName;
RCIPacket packet;
Serial serialPort;

float offset = 0;

  final int SlipEnd = int(0xC0);
  final int SlipEsc = int(0xDB);
  final int SlipEscEnd = int(0xDC);
  final int SlipEscEsc = int(0xDD);
  

void setup() {
  size(600, 450);
  background(255);
  fill(0);
  PFont font;
  font = loadFont("Calibri-20.vlw"); 
  textFont(font);
  portName = "COM8";                      // Change port number here for now...
  String listPorts[] = Serial.list();
  for (int i=0; i<listPorts.length; i++) {
    text(i + ") " + listPorts[i], 20, 20+30*i);
  }
  
  //
  // Eventually listen for keyboard input and select from that.
  //
  
  serialPort = new Serial(this, portName, 115200);
  serialPort.clear();
  serialPort.bufferUntil(byte(SlipEnd));
  
  delay(50);    
  // Create the reader object
  serialReader = new SerialReader(serialPort, "serial1", portName);
}

void draw() {
  // Check to see if there is new data available from the thread
  if (serialReader.available()) {
    packet = serialReader.getPacket();
    text(packet.value,10,(30 + 30*offset) % height);
    offset++;
  }
}

void serialEvent(Serial p) {
  serialReader.checkSerial();
}


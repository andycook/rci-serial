import processing.serial.*;

public class RCIPacket {
  public int packetType;
  public int value;
}

public class SerialThread extends Thread {
  final int SlipEnd = 0xC0;
  final int SlipEsc = 0xDB;
  final int SlipEscEnd = 0xDC;
  final int SlipEscEsc = 0xDD;
  
  private boolean running; // Is the thread running?
  private String id; // Thread name/id, in case of multiple instances
  private String port; // Serial port name to open for the thread
  private boolean available; // Has a new packet been received and parsed?
  private boolean newData;
  private Serial myPort;
  private int readResult;
  private int[] packetBuffer;
  private int bufferPosition;
  private RCIPacket packet;
  
  private PApplet parent;

  // Constructor, probably want the serial port name passed in here
  public SerialThread(Serial tempSerial/*PApplet theParent*/, String s, String portName) {
    //parent = theParent;
    running = false;
    id = s;
    port = portName;
    readResult = 0;
    packetBuffer = new int[30];
    packet = new RCIPacket();
    bufferPosition = 0;
    newData = false;
    available = false;
    
    myPort = tempSerial;
  }

  public void start() {
    running = true;
    System.out.println("Starting serial thread " + id + " for port " + port + ".");
//    myPort = new Serial(parent, port, 57600);
//    delay(50);
//    myPort.clear();
//    myPort.bufferUntil(SlipEnd);

    super.start();
  }
  
  public void run() {
    println("Running...");
    
    while (running){
        println(myPort.read());
//      println(myPort.available());
      if(myPort.available() > 0) readResult = slipRead(packetBuffer, bufferPosition, 20);
      if (newData) {
        newData = false;
        if(bufferPosition > 6) {
          switch(packetBuffer[3]) {
            case 4:  //AMP packet
              packet.packetType = packetBuffer[3];
              packet.value = (packetBuffer[5] << 8) & packetBuffer[6];
              println(packet.value);
              available = true;
              break;
              default:
              break;
          }
        
          bufferPosition = 0;
        }
      }
    }
    System.out.println("Serial thread " + id + "for port " + port + " ended.");
  }
  
  public void quit() {
    System.out.println("Quitting serial thread " + id + "for port " + port + ".");
    running = false;
    interrupt();
  }
  
  public boolean available() {
    return available;
  }
  
  public RCIPacket getPacket() {
    return packet;
  }
  
//  void serialEvent(Serial myPort) {
//    int tempRead = slipRead(packetBuffer, bufferPosition, 20);
//    if(tempRead > 2) {    
//      newData = true;
//    }
//    println("Event");
//    bufferPosition += tempRead;
//  }
  
  /// <summary>
  /// Overrides base SerialProvider.Read() method to provide SLIP framing.
  /// </summary>
  /// <param name="buffer"></param>
  /// <param name="offset"></param>
  /// <param name="size"></param>
  public int slipRead(int[] buffer, int offset, int size) {
    int bytesReceived = 0;  
    int failures = 0;  
    int b = -1;
    boolean readComplete = false;
  
    while ((!readComplete) && (myPort.available() > 0) && (bytesReceived <= size) && (failures < 3)) {
      if (b != -1) {
          buffer[offset + bytesReceived++] = int(b);
      }
  
      try {
        b = -1;
        b = myPort.read();
      } catch (Exception ex) {
        println("SlipProvider.Read - An exception occured while trying to read from port. <" + ex + ">");
        failures++;
      }
      
      switch (b) {
        case -1:
        case SlipEnd:
          if (bytesReceived == 0) {
            b = -1;
            continue;
          }
          readComplete = true;
          newData = true;
          break;
        case SlipEsc:
          b = myPort.read();
          switch (b) {
            case SlipEscEnd:
              b = SlipEnd;
              break;
            case SlipEscEsc:
              b = SlipEsc;
              break;
            default:
              break;
          }
        break;
        default:
          break;  
      }
    }
    
    //base.lastReadBytesReceived = bytesReceived;
    return bytesReceived;
  }
  
  
  /// <summary>
  /// Serial Write function to provide SLIP framing.
  /// </summary>
  /// <param name="buffer"></param>
  /// <param name="pSize"></param>
  void slipWrite(int[] buffer, int offset, int pSize) {
    int[] framedBuffer = new int[pSize * 2 + 2];
  
    int pos = 0;
    framedBuffer[pos++] = SlipEnd;
  
    int i = 0;
    while (i < pSize) {
      switch (buffer[i + offset])
      {
        case SlipEnd:
          framedBuffer[pos++] = SlipEsc;
          framedBuffer[pos++] = SlipEscEnd;
          break;
  
        case SlipEsc:
          framedBuffer[pos++] = SlipEsc;
          framedBuffer[pos++] = SlipEscEsc;
          break;
  
        default:
          framedBuffer[pos++] = buffer[i + offset];
          break;
      }
      i++;
    }
  
    framedBuffer[pos++] = SlipEnd;
  
    myPort.write("Finish this function!");
  }
  
}

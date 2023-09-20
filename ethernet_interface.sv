interface switch_intf (
  input clk,
  input resetN,
  input [31:0] inDataA, //Port A input data, start and end of packet pulses
  input inSopA,
  input inEopA,
  input [31:0] inDataB,
  input inSopB,
  input inEopB,
  input [31:0] outDataA, //input Data and Sop and Eop packet pulses
  input outSopA,
  input outEopA,
  input [31:0] outDataB, 
  input outSopB,
  input outEopB,
  input portAStall, //Backpressure or stall signals on portA/B
  input portBStall

);

  
    
  modport monitor(clocking cb_monitor);
  modport driver(clocking cb_driver);
  
  clocking cb_driver@(posedge clk);
    default input #2ns output #2ns;
    input clk, resetN;
    output inDataA, inDataB, inSopA, inEopA, inSopB, inEopB;
    
  endclocking
    
    clocking cb_monitor@(posedge clk);
      default input #2ns output #2ns;
      input clk, resetN, inDataA, inDataB, inSopA, inEopA, inSopB, inEopB, outDataA, outSopA, outEopA, outDataB, outSopB, outEopB, portAStall, portBStall;
         
    endclocking
  
endinterface

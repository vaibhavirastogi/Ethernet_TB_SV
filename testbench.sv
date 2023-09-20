`include "packet_interface.sv"
`include "packet_test.sv"
import tb_env_pkg::*;

module packet_top;
  reg clk;
  reg resetN;
  wire [31:0] inDataA;
  wire inSopA;
  wire inEopA;
  wire [31:0] inDataB;
  wire inSopB;
  wire inEopB;
  wire [31:0] outDataA;
  wire outSopA;
  wire outEopA;
  wire [31:0] outDataB;
  wire outSopB;
  wire outEopB;
  wire portAStall;
  wire portBStall;

  eth_sw ethernet_switch(
    .clk(clk),
    .resetN(resetN),
    .inDataA(inDataA), 
    .inSopA(inSopA),
    .inEopA(inEopA),
    .inDataB(inDataB),
    .inSopB(inSopB),
    .inEopB(inEopB),
    .outDataA(outDataA),
    .outSopA(outSopA),
    .outEopA(outEopA),
    .outDataB(outDataB), 
    .outSopB(outSopB),
    .outEopB(outEopB),
    .portAStall(portAStall),
    .portBStall(portBStall)
  );  //instantiating the DUT

  switch_intf top_intf(
    .clk(clk),
    .resetN(resetN),
    .inDataA(inDataA), 
    .inSopA(inSopA),
    .inEopA(inEopA),
    .inDataB(inDataB),
    .inSopB(inSopB),
    .inEopB(inEopB),
    .outDataA(outDataA),
    .outSopA(outSopA),
    .outEopA(outEopA),
    .outDataB(outDataB), 
    .outSopB(outSopB),
    .outEopB(outEopB),
    .portAStall(portAStall),
    .portBStall(portBStall)
  ); //instantiate the interface
  packet_env env =new("my_env", top_intf);

  packet_test test = new(top_intf,env);

  initial 
  begin
    resetN=0;
    clk=0;
   
    test.run_test();
  end
  
   always@(posedge clk) resetN<=1;

  always
    #1 clk=~clk;
    
endmodule

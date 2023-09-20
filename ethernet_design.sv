// Code your design here

module fifo (
  clk, 
  resetN, 
  write_en, 
  read_en, 
  data_in, 
  data_out, 
  empty, 
  full
); 
  parameter FIFO_WIDTH = 8;
  parameter FIFO_DEPTH = 16;
  input clk; 
  input resetN; 
  input write_en; 
  input read_en; 
  input  [FIFO_WIDTH-1:0] data_in; 
  output [FIFO_WIDTH-1:0] data_out; 
  output empty; 
  output full; 

  wire clk; 
  wire write_en; 
  wire read_en; 
  wire [FIFO_WIDTH-1:0] data_in; 
  reg [FIFO_WIDTH-1:0] data_out; 
  wire empty; 
  wire full; 
  reg [FIFO_WIDTH-1:0] ram [0:FIFO_DEPTH]; 
  reg tmp_empty; 
  reg tmp_full; 

  integer write_ptr; 
  integer read_ptr; 

  always@(negedge resetN)  begin
    data_out = 0;
    tmp_empty = 1'b1; 
    tmp_full = 1'b0; 
    write_ptr = 0; 
    read_ptr = 0; 
  end 

  assign empty = tmp_empty; 
  assign full = tmp_full; 

  always @(posedge clk) begin 
    if ((write_en == 1'b1) && (tmp_full == 1'b0)) begin 
      ram[write_ptr] = data_in; 
      tmp_empty <= 1'b0; 
      write_ptr = (write_ptr + 1) % FIFO_DEPTH; 
      if ( read_ptr == write_ptr ) begin 
        tmp_full <= 1'b1; 
      end 
    end 
    if ((read_en == 1'b1) && (tmp_empty == 1'b0)) begin 
      data_out <= ram[read_ptr]; 
      tmp_full <= 1'b0; 
      read_ptr = (read_ptr + 1) % FIFO_DEPTH; 
      if ( read_ptr == write_ptr ) begin 
        tmp_empty <= 1'b1; 
      end 
    end 
  end 

endmodule //fifo 

module eth_rcv_fsm(
  input clk,
  input resetN,
  input [31:0] inData, 
  input inSop,
  input inEop,
  output reg outWrEn, //assert this as we write intout output queue
  output reg [33:0] outData  //31:0 data and bit 32 indicating start and bit 33 indicating end -encoded by FSM
);


parameter PORTA_ADDR = 'hABCD;
parameter PORTB_ADDR = 'hBEEF;


reg[2:0] nState;
reg[2:0] pState;

parameter IDLE = 3'b000;
parameter DEST_ADDR_RCVD = 3'b001;
parameter DATA_RCV = 3'b010;
parameter DONE = 3'b011;

reg[31:0] dest_addr;
reg[31:0] src_addr;
reg[33:0] data_word;
reg inSop_d;
reg inEop_d;
reg[31:0] inData_d;

//compute next state
always @(pState or inSop or inEop or inData ) begin
  nState = IDLE;
  case(pState) 
    IDLE: begin
      if(inSop ==1) begin
        dest_addr=inData;
        nState = DEST_ADDR_RCVD;
      end else begin
        nState = IDLE;
      end
    end
    DEST_ADDR_RCVD: begin
      src_addr = inData;
      nState=DATA_RCV;
    end
    DATA_RCV: begin
      if(inEop) begin //last dword -> CRC
        nState = DONE;
      end else begin
        nState = DATA_RCV;
      end
    end
    DONE: begin
        nState = IDLE;
    end
  endcase
end

//assign next state to present state on clk
always @(posedge clk) begin
  pState <= nState;
  inSop_d <= inSop;
  inEop_d <= inEop;
  inData_d <= inData;
end

always @(posedge clk) begin
  if(resetN==0) begin
    outWrEn <=1'b0;
  end else if(pState != IDLE) begin
    outWrEn <=1'b1;
    outData = {inEop_d, inSop_d, inData_d};
  end else begin
    outWrEn <=1'b0;
  end
end

endmodule

//-------------------------
// DUT for testing an ethernet switch example
//-------------------------

module eth_sw(
  input clk,
  input resetN,
  input [31:0] inDataA, //Port A input data, start and end of packet pulses
  input inSopA,
  input inEopA,
  input [31:0] inDataB,
  input inSopB,
  input inEopB,
  output reg [31:0] outDataA, //output Data and Sop and Eop packet pulses
  output reg outSopA,
  output reg outEopA,
  output reg [31:0] outDataB, 
  output reg outSopB,
  output reg outEopB,
  output reg portAStall, //Backpressure or stall signals on portA/B
  output reg portBStall

);

parameter PORTA_ADDR = 'hABCD;
parameter PORTB_ADDR = 'hBEEF;

wire fifo_wr_en[2];
wire[33:0] fifo_wr_data[2];
wire[33:0] fifo_rddata[2];
wire fifo_empty[2];
wire fifo_full[2];
reg fifo_rd_en[2];

//A Receive FSM per port will receive and store packet in a per port input queue (FIFO)
//(Hence two FIFO/buffer per input port to buffer the received packets )
//Based on FIFO  head not blocking and port availability - a tx FSM will dequee packets from FIFO
fifo #(.FIFO_DEPTH(32), .FIFO_WIDTH(34)) inA_queue(
  .clk(clk),
  .resetN(resetN),
  .write_en(fifo_wr_en[0]),
  .read_en(fifo_rd_en[0]),
  .data_in(fifo_wr_data[0]),
  .data_out(fifo_rddata[0]),
  .empty(fifo_empty[0]),
  .full(fifo_full[0])
);

fifo #(.FIFO_DEPTH(32), .FIFO_WIDTH(34)) inB_queue(
  .clk(clk),
  .resetN(resetN),
  .write_en(fifo_wr_en[1]),
  .read_en(fifo_rd_en[1]),
  .data_in(fifo_wr_data[1]),
  .data_out(fifo_rddata[1]),
  .empty(fifo_empty[1]),
  .full(fifo_full[1])
);

//On each port as packet is received - decode and save in one of output queues
eth_rcv_fsm portA_rcv_fsm(
  .clk(clk),
  .resetN(resetN),
  .inData(inDataA),
  .inSop(inSopA),
  .inEop(inEopA),
  .outWrEn(fifo_wr_en[0]),
  .outData(fifo_wr_data[0])
);

eth_rcv_fsm portB_rcv_fsm(
  .clk(clk),
  .resetN(resetN),
  .inData(inDataB),
  .inSop(inSopB),
  .inEop(inEopB),
  .outWrEn(fifo_wr_en[1]),
  .outData(fifo_wr_data[1])
);

reg read_fifo_head[2];
reg read_fifo_data[2];
reg port_busy[2];
reg[1:0] dest_port[2];

//Read both FIFO head
//Check if destined to port A or B and if that port is currently busy
//If not busy - set port Busy and keep reading FIFO until you see EOP and drive the datea from FIFO on output port
//If busy - stall untill busy goes low
always @(posedge clk) begin
  if(!resetN) begin
    for(int i=0; i <2; i++) begin
      read_fifo_head[i] <= 1'b1;
      read_fifo_data[i] <=1'b0;
      dest_port[i] <= 'b11; //invalid
      port_busy[i]='b0;
    end
    outDataA <='x;
    outDataB <='x;
    outSopA <='b0;
    outSopB <='b0;
    outEopA <='b0;
    outEopB <='b0;
  end else begin
    outSopA <='b0;
    outSopB <='b0;
    outEopA <='b0;
    outEopB <='b0;
    for(int i=0; i <2; i++) begin
      if(read_fifo_head[i] &&  ~fifo_empty[i]) begin
        fifo_rd_en[i]<=1'b1;
        read_fifo_head[i]<=1'b0;
        read_fifo_data[i] <=1'b1;
      end else if (read_fifo_data[i] && ~fifo_full[i]) begin
        if(fifo_rddata[i][32]) begin //sop
          dest_port[i] = (fifo_rddata[i][31:0]==PORTB_ADDR) ? 'b01: 'b00;
          if(port_busy[dest_port[i]]) begin
             fifo_rd_en[i] <=1'b0; //stall untill this dest port can acccept
          end else begin
             fifo_rd_en[i] <=1'b1; //stall untill this dest port can acccept
             port_busy[dest_port[i]] <=1'b1; //now that we start sending to this port - set busy
          end
        end else if(fifo_rddata[i][33]) begin //eop
          fifo_rd_en[i]<=1'b0;
          read_fifo_data[i] <=1'b0;
          read_fifo_head[i]<=1'b1;
          port_busy[dest_port[i]] <=1'b0; //clean port busy
        end else begin
          fifo_rd_en[i]<=1'b1;
        end
        if(dest_port[i] ==0) begin
          outDataA <= fifo_rddata[i][31:0];
          outSopA <= fifo_rddata[i][32];
          outEopA <= fifo_rddata[i][33];
        end
        if(dest_port[i] ==1) begin
          outDataB <= fifo_rddata[i][31:0];
          outSopB <= fifo_rddata[i][32];
          outEopB <= fifo_rddata[i][33];
        end
      end
    end
  end
end

always @(posedge clk) begin
  if(resetN==0) begin
    portAStall<=0;
    portBStall<=0;
  end else begin
    portAStall<=fifo_full[0];
    portBStall<=fifo_full[1];
  end
end

endmodule : eth_sw

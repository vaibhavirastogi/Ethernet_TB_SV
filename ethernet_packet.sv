`define PORTA_ADDR 'hABCD
`define PORTB_ADDR 'hBEEF

class packet;

  rand bit[31:0] src_addr;
  rand bit[31:0] dest_addr;
  rand byte data[$];
  bit[31:0] pkt_crc;
  byte full_pkt[];
  int pkt_size;

  function bit[31:0] crc_gen;
    return 'hABBADEAD;
  endfunction

  constraint data_size_constraint {
    data.size() inside {[53:399], [401:999], [1001:1505]};  }

  constraint src_addr_cons {src_addr inside {`PORTA_ADDR, `PORTB_ADDR};}

  constraint dest_addr_cons {dest_addr inside {`PORTA_ADDR, `PORTB_ADDR};}
  
 // constraint trial_cons { pkt_size inside {[12:45], [55:90], [102:109]}; }

  //constraint data_pattern_fixed {
  //  foreach(data[i]) data[i] == 8'hcc;
 // }

//  constraint data_pattern_incr {
 //   foreach(data[i]) data[i + 1] == data[i] + 1;
  //}

  constraint data_pattern_rand {
    foreach(data[i]) data[i] inside {[8'h00:8'hff]};
  }
  
function void fill_packet();
  pkt_size = data.size() + 12;
  full_pkt = {crc_gen(), data, dest_addr, src_addr};
  $display("FUNCTION FILL_PACKET in PACKET::The full packet here is crc value: %h, dest_addr is %h and src_addr is %h", crc_gen(), dest_addr, src_addr);
 // $display("Data:");
//  foreach (data[i]) $display("  data[%0d] = %h", i, data[i]);
endfunction



 
  

endclass

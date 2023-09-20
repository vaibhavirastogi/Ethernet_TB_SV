class packet_gen;
  
 int num_pkt;
  mailbox mbx_gen[4]; 
  
  function new(mailbox mbx_gen[4]);
    this.mbx_gen=mbx_gen;
  endfunction
  
  task create_and_send_pkt;
    for(int i=0;i<5;i++)
      begin
        packet pkt;
        pkt=new();
        
        if (!pkt.randomize() with {
          src_addr inside {`PORTA_ADDR, `PORTB_ADDR};
          dest_addr inside {`PORTA_ADDR, `PORTB_ADDR};
  data.size() inside {[53:399], [401:999], [1001:1505]};
          foreach(data[i]) data[i] inside {[8'h00:8'hff]}; }) begin
  $error("Failed to randomize with selected constraints");
end
        
        $display("before fill_packet task call in generator");
        pkt.pkt_crc=pkt.crc_gen();
        pkt.fill_packet();
        $display("after fill_packet task call in generator");
        //$display("TASK CREATE_AND_SEND_PKT: Packet created:");
    $display("TASK CREATE_AND_SEND_PKT:  dest_addr: %h", pkt.dest_addr);
    $display("TASK CREATE_AND_SEND_PKT:  src_addr: %h", pkt.src_addr);
   // foreach (pkt.data[i]) $display("TASK CREATE_AND_SEND_PKT:  data[%0d] = %h", i, pkt.data[i]);
    $display("TASK CREATE_AND_SEND_PKT:  pkt_crc: %h", pkt.pkt_crc);
        
        
       if (pkt.src_addr == `PORTA_ADDR) begin
         $display("TASK CREATE_AND_SEND_PKT: About to put pkt on port 0 mailbox");
      mbx_gen[0].put(pkt);
    end else if (pkt.src_addr == `PORTB_ADDR) begin
      $display("TASK CREATE_AND_SEND_PKT: About to put pkt on port 1 mailbox");
      mbx_gen[1].put(pkt);
      
    end
        
      end
      
  endtask
  

  
  
endclass

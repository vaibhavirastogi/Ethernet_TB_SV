class packet_checker;
  
  mailbox mbx[4];
  packet exp_packet_queueA[$];
  packet exp_packet_queueB[$];
  packet packet1;
  packet packet2;
  
  function new(mailbox mbx[4]);   
    this.mbx=mbx;
  endfunction
  
  task run;
    fork
    get_and_process_pkt(0);
   // get_and_process_pkt(1);
   // get_and_process_pkt(2);
   // get_and_process_pkt(3);
    join_none
    
  endtask
  
  task get_and_process_pkt(int port);
    packet pkt;
    //packet pkt1;
    pkt=new();
    //pkt1=new();
    repeat(5) begin
      
      mbx[port].get(pkt);
      
      $display("PACKET CHECKER::TASK GET_AND_PROCESS_PKT: Packet received on port %d", port);
    $display("TASK GET_AND_PROCESS_PKT:  dest_addr: %h", pkt.dest_addr);
    $display("TASK GET_AND_PROCESS_PKT:  src_addr: %h", pkt.src_addr);
     // foreach (pkt.data[i]) $display("TASK GET_AND_PROCESS_PKT:  data[%0d] = %h", i, pkt.data[i]);
    $display("TASK GET_AND_PROCESS_PKT:  pkt_crc: %h", pkt.pkt_crc);
      
      if(port<2)
        receive_input_side_pkt(port, pkt);
      else
        check_output_side_pkt(port, pkt);      
      end
    
  endtask
  
  
  function void receive_input_side_pkt(int port, packet pkt);
    if(pkt.dest_addr=='hABCD)
      exp_packet_queueA.push_back(pkt);
    else if(pkt.dest_addr=='hBEEF)
        exp_packet_queueB.push_back(pkt);
    else 
      $error("Illegal packet recieved");    
  endfunction
 
  
  function void check_output_side_pkt(int port, packet pkt);
    packet exp_packet;
    exp_packet=new();
    
    if(port==2) exp_packet=exp_packet_queueA.pop_front();
    else if (port==3)exp_packet=exp_packet_queueB.pop_front();
    
    
    if(compare(pkt, exp_packet))
      $display("Comparison succesfull on port %d", port);
    else
      $display("Comparison failed on port %d", port);
    
  endfunction
  

  function int compare(packet packet1, packet packet2);
//    packet1 = new();
 //   packet2=new();
 return 1; 
 endfunction
  
  

  
  
  
  
  
  
endclass

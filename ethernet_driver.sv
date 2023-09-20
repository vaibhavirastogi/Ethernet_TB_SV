
class packet_drv;  
  
 virtual switch_intf vif_drv;
  mailbox mbx[4];
  
  function new(virtual switch_intf vif_drv, mailbox mbx[4]);
    this.vif_drv=vif_drv;
    this.mbx=mbx;  
  endfunction
   
      
  task run;
    $display("Inside driver run task");
    repeat(5)@(posedge vif_drv.cb_driver.clk)
    begin
      packet pkt;
      pkt=new();
      $display("DRIVER:: before get_pkt_from_gen task call");
       wait(mbx[0].num() > 0);
      get_pkt_from_gen(pkt);
     // drv_pkt_to_dut(pkt);
    end
    #10;
  endtask
  
  task get_pkt_from_gen(packet pkt);
    
    
      begin
        
        $display("PACKET DRIVER:: TASK GET_PKT_FROM_GEN:: before mbx.get call");
        mbx[0].get(pkt);
        $display("PACKET DRIVER::TASK GET_PKT_FROM_GEN: Packet received");
        //mbx[1].get(pkt);
      //  $display("PACKET DRIVER::TASK GET_PKT_FROM_GEN: Packet received on port %d", port);
    $display("PACKET DRIVER::TASK GET_PKT_FROM_GEN:  dest_addr: %h", pkt.dest_addr);
    $display("PACKET DRIVER::TASK GET_PKT_FROM_GEN:  src_addr: %h", pkt.src_addr);
     // foreach (pkt.data[i]) $display("TASK GET_AND_PROCESS_PKT:  data[%0d] = %h", i, pkt.data[i]);
        $display("PACKET DRIVER::TASK GET_PKT_FROM_GEN:  pkt_crc: %h", pkt.pkt_crc);
        
        $display("driver got packet from generator");
        if(pkt.src_addr==`PORTA_ADDR)
          drv_pkt_to_dut_portA(pkt);
        else if (pkt.src_addr==`PORTB_ADDR)
          drv_pkt_to_dut_portB(pkt);
        else
          $display("Packet src addr neither A nor B, drop execution");
      end
  endtask
  
  
  
task drv_pkt_to_dut_portA(packet pkt);
  int count;
  int no_of_dwords;
  byte cur_dword[];
  int dword_idx;
  count = 0;
  dword_idx = 0;

  no_of_dwords = pkt.pkt_size / 4;
  $display("Inside driver, driving port A, no. of dwords %0d", no_of_dwords);
  
  cur_dword = pkt.full_pkt;
  
  forever@(posedge vif_drv.cb_driver.clk)
  begin
    if (!vif_drv.portAStall)
    begin
      vif_drv.cb_driver.inSopA <= 1'b0;
      vif_drv.cb_driver.inEopA <= 1'b0;

      if (count == 0)
      begin
        vif_drv.cb_driver.inSopA <= 1'b1;
        vif_drv.cb_driver.inDataA <= {cur_dword[dword_idx+3], cur_dword[dword_idx+2], cur_dword[dword_idx+1], cur_dword[dword_idx]};
        dword_idx += 4;
        count++;
      end
      else if (count == no_of_dwords - 1)
      begin
        vif_drv.cb_driver.inEopA <= 1'b1;
        vif_drv.cb_driver.inDataA <= {cur_dword[dword_idx+3], cur_dword[dword_idx+2], cur_dword[dword_idx+1], cur_dword[dword_idx]};
        dword_idx += 4;
        count = count + 1;
      end
      else if (count == no_of_dwords)
      begin
        count = 0;
        break;
      end
      else
      begin
        vif_drv.cb_driver.inDataA <= {cur_dword[dword_idx+3], cur_dword[dword_idx+2], cur_dword[dword_idx+1], cur_dword[dword_idx]};
        dword_idx += 4;
        count = count + 1;
      end
    end
  end
endtask

      
task drv_pkt_to_dut_portB(packet pkt);
  int count;
  int no_of_dwords;
  byte cur_dword[];
  int dword_idx;
  count = 0;
  dword_idx = 0;

  no_of_dwords = pkt.pkt_size / 4;
  $display("Inside driver, driving port B, no. of dwords %0d", no_of_dwords);
  
  cur_dword = pkt.full_pkt;
  
  forever@(posedge vif_drv.cb_driver.clk)
  begin
    if (!vif_drv.portBStall)
    begin
      vif_drv.cb_driver.inSopB <= 1'b0;
      vif_drv.cb_driver.inEopB <= 1'b0;

      if (count == 0)
      begin
        vif_drv.cb_driver.inSopB <= 1'b1;
        vif_drv.cb_driver.inDataB <= {cur_dword[dword_idx+3], cur_dword[dword_idx+2], cur_dword[dword_idx+1], cur_dword[dword_idx]};
        dword_idx += 4;
        count++;
      end
      else if (count == no_of_dwords - 1)
      begin
        vif_drv.cb_driver.inEopB <= 1'b1;
        vif_drv.cb_driver.inDataB <= {cur_dword[dword_idx+3], cur_dword[dword_idx+2], cur_dword[dword_idx+1], cur_dword[dword_idx]};
        dword_idx += 4;
        count = count + 1;
      end
      else if (count == no_of_dwords)
      begin
        count = 0;
        break;
      end
      else
      begin
        vif_drv.cb_driver.inDataB <= {cur_dword[dword_idx+3], cur_dword[dword_idx+2], cur_dword[dword_idx+1], cur_dword[dword_idx]};
        dword_idx += 4;
        count = count + 1;
      end
    end
  end
endtask
     
endclass

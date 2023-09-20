class packet_monitor;
  
  virtual switch_intf vif;
   
  mailbox mbx_mon[4];
  
  //constructor
  function new(mailbox mbx_mon[4], virtual switch_intf vif );
    this.mbx_mon=mbx_mon;
    this.vif=vif;
  endfunction
  
  task run;
    
    fork
      sample_portA_input_pkt();
      sample_portB_input_pkt();
      sample_portA_output_pkt();
      sample_portB_output_pkt();
      
    join
  endtask
  
  
  
  task sample_portA_input_pkt();
    packet pkt;
    int count;
    count=0;
    
    forever@(vif.cb_monitor.clk) begin
      
      if(vif.cb_monitor.inSopA)
        begin
        pkt=new();
      pkt.src_addr<=vif.cb_monitor.inDataA;
      count=1;
        end
      
      else if (count==1)
        begin
          pkt.dest_addr<=vif.cb_monitor.inDataA;
          count++;
        end
      
      else if(count>1)
        begin
          pkt.data.push_back(vif.cb_monitor.inDataA);
          count++;
        end
      else if(vif.cb_monitor.inEopA)
        begin
        pkt.pkt_crc<=vif.cb_monitor.inDataA;
      count=0;
        end
      
      mbx_mon[0].put(pkt);
      
    end
  endtask
  
 
    task sample_portB_input_pkt();
    packet pkt;
    int count;
    count=0;
    
    forever@(vif.cb_monitor.clk) begin
      
      if(vif.cb_monitor.inSopB)
        begin
        pkt=new();
      pkt.src_addr<=vif.cb_monitor.inDataB;
      count=1;
        end
      
      else if (count==1)
        begin
          pkt.dest_addr<=vif.cb_monitor.inDataB;
          count++;
        end
      
      else if(count>1)
        begin
          pkt.data.push_back(vif.cb_monitor.inDataB);
          count++;
        end
      else if(vif.cb_monitor.inEopB)
        begin
        pkt.pkt_crc<=vif.cb_monitor.inDataB;
      count=0;
        end
      mbx_mon[1].put(pkt);;
    end
  endtask
  
    task sample_portA_output_pkt();
    packet pkt;
    int count;
    count=0;
    
    forever@(vif.cb_monitor.clk) begin
      
      if(vif.cb_monitor.outSopA)
        begin
        pkt=new();
      pkt.src_addr<=vif.cb_monitor.outDataA;
      count=1;
        end
      
      else if (count==1)
        begin
          pkt.dest_addr<=vif.cb_monitor.outDataA;
          count++;
        end
      
      else if(count>1)
        begin
          pkt.data.push_back("vif.cb_monitor.outDataA");
          count++;
        end
      else if(vif.cb_monitor.outEopA)
        begin
        pkt.pkt_crc<=vif.cb_monitor.outDataA;
      count=0;
        end
      mbx_mon[2].put(pkt); 
    end
  endtask
  
  
    task sample_portB_output_pkt();
    packet pkt;
    int count;
    count=0;
    
    forever@(vif.cb_monitor.clk) begin
      
      if(vif.cb_monitor.outSopB)
        begin
        pkt=new();
      pkt.src_addr<=vif.cb_monitor.outDataB;
      count=1;
        end
      
      else if (count==1)
        begin
          pkt.dest_addr<=vif.cb_monitor.outDataB;
          count++;
        end
      
      else if(count>1)
        begin
          pkt.data.push_back(vif.cb_monitor.outDataB);
          count++;
        end
      else if(vif.cb_monitor.outEopB)
        begin
        pkt.pkt_crc<=vif.cb_monitor.outDataB;
      count=0;
        end
      mbx_mon[3].put(pkt);
    end
  endtask
endclass

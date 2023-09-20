package tb_env_pkg;
`define PORTA_ADDR 'hABCD
`define PORTB_ADDR 'hBEEF
`include "packet.sv"
`include "packet_driver.sv"
`include "packet_generator.sv"
`include "packet_monitor.sv"
`include "packet_checker.sv"

class packet_env;  
  
  packet_drv drv_top;
  packet_gen gen_top;
  packet_monitor mon_top;
  packet_checker check_top;
  
  
  virtual switch_intf vif_intf_top;
  
//  mailbox gen_to_drv[4];
  mailbox mon_to_chk[4];
  string name;
  
  
  
  function new(string name, virtual switch_intf vif_intf_top);
    this.name=name;
    this.vif_intf_top=vif_intf_top;
  
  for(int i=0;i<4;i++)
    begin
      mon_to_chk[i]=new();
    //  gen_to_drv[i]=new();
    end

  
    drv_top=new(vif_intf_top, mon_to_chk);
    gen_top=new(mon_to_chk);
    mon_top=new( mon_to_chk, vif_intf_top);
    check_top=new(mon_to_chk);
    
    
     endfunction
  
  
  task run();
    fork
     // if(!gen_top.randomize())
       // $display("Generator is not able to randomize packet");
      $display("Before create_and_send_pkt task in env");
	      gen_top.create_and_send_pkt();
      $display("After create_and_send_pkt task in env");
      
   //  drv_top.create_pkt();
     drv_top.run();
      $display("After driver run task call in env");
      
      mon_top.run();
      $display("After monitor run task call in env");
      check_top.run();
      $display("After checker run task call in env");
      
    join_none
    
  endtask
  
  
  
  
endclass

endpackage

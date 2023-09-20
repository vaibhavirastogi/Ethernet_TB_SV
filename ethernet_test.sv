`include "packet_env.sv"
`include "packet_interface.sv"
class packet_test;
  
   import tb_env_pkg::*;
  
  //declaring environment instance
  packet_env env;
  virtual switch_intf intf;
  
  function new(virtual switch_intf intf, packet_env env);
   // intf=new();
    //creating environment
    this.intf=intf;
    this.env=env;
  //  env = new("env", intf);
  endfunction
  
  task run_test();
    env.run();
  endtask
  
  
endclass

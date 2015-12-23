// ***********************************************************************
// File:   2.Watchdog Component.sv
// Author: bhunter
/* About:
   Copyright (C) 2015  Brian P. Hunter

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 *************************************************************************/

`ifndef __GLOBAL_WATCHDOG_SV__
   `define __GLOBAL_WATCHDOG_SV__

// class: watchdog_c
class watchdog_c extends uvm_component;
   `uvm_component_utils_begin(global_pkg::watchdog_c)
      `uvm_field_int(watchdog_time, UVM_COMPONENT | UVM_DEC)
   `uvm_component_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Configuration Fields

   // var: watchdog_time
   // The time, in ns, at which the test will timeout
   int watchdog_time = 100000;

   // var: timeout_occurred
   // Set to 1 on deadlock
   bit timeout_occurred = 0;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="watchdog",
                uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   ////////////////////////////////////////////
   // func: start_of_simulation_phase
   // Check for plusargs to override any modifications to the watchdog_time
   virtual function void start_of_simulation_phase(uvm_phase phase);
      int  plus_wdog_time;
      super.start_of_simulation_phase(phase);
      if($value$plusargs("wdog=%d", plus_wdog_time))
         watchdog_time = plus_wdog_time;
      `cmn_info(("Global Watchdog Timer set to %0dns.", watchdog_time))
   endfunction : start_of_simulation_phase

   ////////////////////////////////////////////
   virtual task run_phase(uvm_phase phase);
      uvm_phase current_phase;
      if(watchdog_time == 0)
         return;

      `cmn_info(("Waiting for watchdog timeout at %0dns...", watchdog_time))
      #(watchdog_time * 1ns);

      `cmn_err(("Watchdog Timeout! Objection report:"))
      objector_report();

      timeout_occurred = 1;

      current_phase = get_current_phase();
      if(current_phase == null) begin
         `cmn_fatal(("Exiting due to timeout, but could not identify phase responsible"))
      end else begin
        uvm_domain::jump_all(uvm_extract_phase::get());
      end
   endtask : run_phase
   ////////////////////////////////////////////
   // func: final_phase
   // Issue a fatal error
   virtual function void final_phase(uvm_phase phase);
      if(timeout_occurred)
         `cmn_fatal(("Exiting due to watchdog timeout."))
   endfunction : final_phase

   ////////////////////////////////////////////
   // func: objector_report
   // Print out all of the objectors to the current phase
   virtual function void objector_report();
      string str;
      uvm_object objectors[$];
      uvm_phase current_phase = get_current_phase();

      if(current_phase == null)
         `cmn_fatal(("Unable to determine the current phase."))

      current_phase.get_objection().get_objectors(objectors);

      str = $sformatf("\n\nCurrently Executing Phase :  %s\n", current_phase.get_name());
      str = {str, "List of Objectors   \n"};
      str = {str, "Hierarchical Name                              Class Type\n"};
      foreach(objectors[obj]) begin
         str = {str, $sformatf("%-47s%s\n", objectors[obj].get_full_name(),
                                objectors[obj].get_type_name())};
      end

      `cmn_info((str))
   endfunction : objector_report
endclass : watchdog_c

`endif // __GLOBAL_WATCHDOG_SV__

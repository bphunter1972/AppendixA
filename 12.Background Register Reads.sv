// ***********************************************************************
// File:   12.Background Register Reads.sv
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

// class: reg_background_cfg_c
class reg_background_cfg_c extends uvm_object;
   `uvm_object_utils_begin(cmn_pkg::reg_background_cfg_c)
      `uvm_field_queue_string(exclude_regs, UVM_DEFAULT)
      `uvm_field_object(rand_delays, UVM_DEFAULT)
   `uvm_object_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: exclude_regs
   // Registers that must be excluded
   string exclude_regs[$];

   // var: exclude_types
   // A queue of register TYPE names that should also be excluded
   string exclude_types[$];

   // var: rand_delays
   // A random delay object
   rand rand_delays_c rand_delays;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="reg_background_cfg");
      super.new(name);
      // create the rand_delays object
      rand_delays = cmn_pkg::rand_delays_c::type_id::create("rand_delays");
   endfunction : new
endclass : reg_background_cfg_c

//****************************************************************************************
// class: reg_background_vseq_c
class reg_background_vseq_c extends uvm_sequence;
   `uvm_object_utils_begin(cmn_pkg::reg_background_vseq_c)
   `uvm_object_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: reg_block
   // A UVM register block containing the CSRs to read from
   uvm_reg_block reg_block;

   // var: cfg
   // The cfg policy class for background register reads
   reg_background_cfg_c cfg;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="reg_background_vseq");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: get_regs
   // Use the cfg.exclusion lists to return a queue of all registers
   virtual function void get_regs(output uvm_reg _regs[$]);
      uvm_reg all_regs[$];
      reg_block.get_registers(all_regs);
      _regs = all_regs.find(it) with (
         !(it.get_name() inside cfg.exclude_regs) &&
         !(it.get_type_name() inside cfg.exclude_types)
      );
      `cmn_info(("There are %0d registers to read from:", _regs.size()))
   endfunction : get_regs

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      uvm_reg regs[$];
      uvm_reg reg_to_read;
      uvm_status_e status;
      uvm_phase main_phase = uvm_main_phase::get();

      assert(reg_block) else
         `cmn_fatal(("There is no reg_block"))
      assert(cfg) else
         `cmn_fatal(("There is no cfg"))

      get_regs(regs);

      // emit a warning if all registers were excluded
      if(regs.size() == 0) begin
         `cmn_warn((“All registers were excluded.”))
         return;
      end

      forever begin
         // wait a random delay
         cfg.rand_delays.wait_delay();

         // get a random register from the queue and read it
         regs.shuffle();
         reg_to_read = regs[0];
         `cmn_dbg(200, ("Background reading from %s", reg_to_read.get_name()))
         main_phase.raise_objection(this, "Reading CSR");
         reg_to_read.mirror(status);
         main_phase.drop_objection(this, "Done Reading CSR");
      end
   endtask : body
endclass : reg_background_vseq_c

// ***********************************************************************
// File:   6.Virtual Sequence Library.sv
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

// class: lib_vseq_cfg_c
class lib_vseq_cfg_c extends uvm_object;
   `uvm_object_utils_begin(cmn_pkg::lib_vseq_cfg_c)
      `uvm_field_int(vseqs_to_send,              UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(max_outstanding,            UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: vseqs_to_send
   // The number of virtual sequences that will be sent
   rand int unsigned vseqs_to_send;

   // var: max_outstanding
   // The number of virtual sequences outstanding at a time
   int unsigned max_outstanding = 5;

   //----------------------------------------------------------------------------------------
   // Group: Constraints

   // constraint: vseqs_to_send_L0_cnstr
   // Keep less than 1000
   constraint vseqs_to_send_L0_cnstr {
      vseqs_to_send inside {[1:1000]};
   }

   // constraint: vseqs_to_send_L1_cnstr
   // Keep less than 10 (for testbenches just getting started)
   constraint vseqs_to_send_L1_cnstr {
      vseqs_to_send inside {[1:10]};
   }

   //----------------------------------------------------------------------------------------
   // Group: Local Fields

   // var: dist_chooser
   // A distribution chooser
   cmn_pkg::dist_chooser_c#(string) dist_chooser;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="exer_vseq_cfg");
      super.new(name);
      dist_chooser = cmn_pkg::dist_chooser_c#(string)::type_id::create(“dist_chooser”);
   endfunction : new

   ////////////////////////////////////////////
   // func: post_randomize
   // Ensure that sequences have been added
   function void post_randomize();
      assert(dist_chooser.is_configured()) else
         `cmn_fatal(("No virtual sequences were added to this policy class."))
   endfunction : post_randomize

   ////////////////////////////////////////////
   // func: add_vseq
   // Add a sequence to the library, with a given distribution weight
   virtual function void add_vseq(string _vseq_name,
                                  int unsigned _weight);
      if(_weight) begin
         dist_chooser.add_item(_weight, _vseq_name);
         dist_chooser.configure();
      end
   endfunction : add_vseq

   ////////////////////////////////////////////
   // func: get_next_vseq
   // Returns the string of the next sequence to send
   virtual function string get_next_vseq();
      return(dist_chooser.get_next());
   endfunction : get_next_vseq
endclass : lib_vseq_cfg_c

//****************************************************************************************
// class: lib_vseq_c
class lib_vseq_c extends uvm_sequence;
   `uvm_object_utils(cmn_pkg::lib_vseq_c)

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: cfg
   // The cfg class for an exer_vseq
   lib_vseq_cfg_c cfg;

   // var: curr_cnt
   // The number of vseqs currently outstanding
   int unsigned curr_cnt;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="lib_vseq");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: body
   virtual task body();
      string type_name;

      `cmn_seq_raise
      `cmn_info(("Launching %0d vseqs.", cfg.vseqs_to_send))

      for(int num_sent = 0; num_sent < cfg.vseqs_to_send; num_sent++) begin
         automatic uvm_sequence vseq;

         // wait until the number outstanding is less than the maximum that are outstanding
         if(curr_cnt >= cfg.max_outstanding) begin
            `cmn_info(("Blocking until at least 1 sequence completes."))
            wait(curr_cnt < cfg.max_outstanding);
         end

         // get the sequence type to send by getting the name of its type
         type_name = cfg.get_next_vseq();

         // create the sequence based on the string. Set the sequence’s sequencer to be the one
         // this sequence is operating on.
         if(!$cast(vseq, uvm_factory::get().create_object_by_name(type_name,
                                                                  get_full_name(), type_name)))
            `cmn_fatal(("Unable to create a sequence of type %s", type_name))
         vseq.set_item_context(this, m_sequencer);

         // Randomize
         assert(vseq.randomize()) else begin
            `cmn_err(("Randomization of %s failed.", type_name))
            continue;
         end

         `cmn_info(("Launching a sequence of type %s", type_name))

         // The fork..join_none is what allows this code to send multiple sequences at once
         curr_cnt++;
         fork
            begin
               `uvm_send(vseq)
               curr_cnt--;
            end
         join_none
      end

      // ensure that all sequences complete before exiting.
      wait(curr_cnt == 0);
      `cmn_info(("Exerciser complete after %0d sequences.", cfg.vseqs_to_send))

      // drop objection
      `cmn_seq_drop
   endtask : body
endclass : lib_vseq_c

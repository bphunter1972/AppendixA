// ***********************************************************************
// File:   1.Messaging Macros.sv
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

////////////////////////////////////////////
// macro: `cmn_base_msg(LVL, TYPE, MSG, FILE, LINE)
// base-level macro used by the real macros
`define cmn_base_msg(LVL, TYPE, MSG, FILE, LINE)                                      \
   begin                                                                              \
      string full_name = get_full_name();                                             \
      if(uvm_report_enabled(LVL,TYPE,full_name)) begin                                \
         uvm_report_object report_object;                                             \
         uvm_sequence_item sequence_item;                                             \
         if($cast(report_object, this) || $cast(sequence_item, this)) begin           \
            uvm_report_info(full_name, $sformatf MSG, 0, `uvm_file, `uvm_line);       \
         end else begin                                                               \
            uvm_report_handler report_handler = uvm_top.get_report_handler();         \
            report_handler.report(UVM_INFO, full_name, full_name, $sformatf MSG, LVL, \
                                  FILE, LINE, uvm_top);                               \
        end                                                                           \
      end                                                                             \
   end

////////////////////////////////////////////
// macro: `cmn_info(MSG)
// Print the MSG argument out at debug level 0
`define cmn_info(MSG) \
  `cmn_base_msg(UVM_NONE, UVM_INFO, MSG, `uvm_file, `uvm_line)

////////////////////////////////////////////
// macro: `cmn_dbg(LVL, MSG)
// Print the message MSG out at level LVL.
  `define cmn_dbg(LVL, MSG) \
  `cmn_base_msg(LVL, UVM_INFO, MSG, `uvm_file, `uvm_line)
////////////////////////////////////////////
// macro: cmn_err(MSG)
// Print out the MSG as an error.
`define cmn_err(MSG) \
   `cmn_base_msg(UVM_NONE, UVM_ERROR, MSG, `uvm_file, `uvm_line)

////////////////////////////////////////////
// macro: cmn_fatal(MSG)
// Print the MSG out as a fatal error and immediately end simulation.
`define cmn_fatal(MSG) \
   `cmn_base_msg(UVM_NONE, UVM_FATAL, MSG, `uvm_file, `uvm_line)

////////////////////////////////////////////
// macro: cmn_warn(MSG)
// Print the MSG out as a warning
`define cmn_warn(MSG) \
   `cmn_base_msg(UVM_NONE, UVM_WARNING, MSG, `uvm_file, `uvm_line)

////////////////////////////////////////////
// The same as above, but must be used in any functions of static UVM classes
`define cmn_base_static(LVL, TYPE, MSG, FILE, LINE)                        \
   begin                                                                   \
      string full_name = {type_name, "::<static>"};                        \
      if(uvm_top.uvm_report_enabled(LVL,TYPE,full_name)) begin             \
         uvm_report_handler report_handler = uvm_top.get_report_handler(); \
         report_handler.report(TYPE, full_name, full_name, $sformatf MSG,  \
                               LVL, FILE, LINE, uvm_top);                  \
      end                                                                  \
   end

`define cmn_info_static(MSG) \
   `cmn_base_static(UVM_NONE, UVM_INFO, MSG, `uvm_file, `uvm_line)

`define cmn_dbg_static(LVL, MSG) \
   `cmn_base_static(LVL, UVM_INFO, MSG, `uvm_file, `uvm_line)

`define cmn_err_static(MSG) \
   `cmn_base_static(UVM_NONE, UVM_ERROR, MSG, `uvm_file, `uvm_line)

`define cmn_fatal_static(MSG) \
   `cmn_base_static(UVM_NONE, UVM_FATAL, MSG, `uvm_file, `uvm_line)

`define cmn_warn_static(MSG) \
   `cmn_base_static(UVM_NONE, UVM_WARNING, MSG, `uvm_file, `uvm_line)

////////////////////////////////////////////
// The same as above, but used for RTL, interfaces, etc.
`define cmn_base_intf(LVL, TYPE, MSG, FILE, LINE, PATH)                 \
   begin                                                                \
      uvm_report_handler report_handler = uvm_top.get_report_handler(); \
      report_handler.report(TYPE, PATH, PATH, $sformatf MSG,            \
                           LVL, FILE, LINE, uvm_top);                   \
   end

`define cmn_info_intf(MSG) \
   `cmn_base_intf(UVM_NONE, UVM_INFO, MSG, `uvm_file, `uvm_line, $sformatf("%m"))

`define cmn_dbg_intf(LVL, MSG) \
   `cmn_base_intf(LVL, UVM_INFO, MSG, `uvm_file, `uvm_line, $sformatf("%m"))

`define cmn_err_intf(MSG) \
   `cmn_base_intf(UVM_NONE, UVM_ERROR, MSG, `uvm_file, `uvm_line, $sformatf("%m"))


`define cmn_fatal_intf(MSG) \
   `cmn_base_intf(UVM_NONE, UVM_FATAL, MSG, `uvm_file, `uvm_line, $sformatf("%m"))

`define cmn_warn_intf(MSG) \
   `cmn_base_intf(UVM_NONE, UVM_WARNING, MSG, `uvm_file, `uvm_line, $sformatf("%m"))

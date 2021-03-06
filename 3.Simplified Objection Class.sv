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

// class: objection_c
// A simpler objection class that removes hierarchy-related things.
class objection_c extends uvm_object;
   `uvm_object_utils_begin(objection_c)
      `uvm_field_int(count,             UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(last_raised_time,  UVM_DEFAULT)
      `uvm_field_int(last_dropped_time, UVM_DEFAULT)
   `uvm_object_utils_end

   //----------------------------------------------------------------------------------------
   // Group: Fields

   // var: count
   // The current objection count, goes up when raised and down when dropped
   local int unsigned count;

   // var: last_raised_time
   // The last time this objection was raised
   time last_raised_time;

   // var: last_dropped_time
   // The last time this objection was dropped
   time last_dropped_time;

   //----------------------------------------------------------------------------------------
   // Group: Methods
   function new(string name="objection");
      super.new(name);
   endfunction : new

   ////////////////////////////////////////////
   // func: get_count
   function int unsigned get_count();
      return count;
   endfunction : get_count

   ////////////////////////////////////////////
   // func: raise
   function void raise(int unsigned _count = 1);
      count += _count;
      last_raised_time = $realtime();
   endfunction : raise

   ////////////////////////////////////////////
   // func: drop
   function void drop(int unsigned _count = 1);
      count -= _count;
      last_dropped_time = $realtime();
   endfunction : drop

   ////////////////////////////////////////////
   // func: clear
   function void clear();
      count = 0;
      last_dropped_time = $realtime();
   endfunction : clear
endclass : objection_c

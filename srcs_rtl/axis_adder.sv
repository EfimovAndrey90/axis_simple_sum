// +FHDR------------------------------------------------------------------------
// FILE NAME      : axis_adder.sv
// DEPARTMENT     : 
// AUTHOR         : Andrey Efimov
// AUTHOR'S EMAIL : efan_90_@mail.ru
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE    AUTHOR      DESCRIPTION
// 1.0 2023-02-16  A. Efimov   Initial
// 1.1 2023-02-17  A. Efimov   Changing the reset strategy according to the xilinx ultrafast methodology
// 1.2 2023-02-21  A. Efimov   Change overal project topology.
// -----------------------------------------------------------------------------
// KEYWORDS : axis, sum
// -----------------------------------------------------------------------------
// PURPOSE : sum two data streams. input and output interface - axi4stream.
// -----------------------------------------------------------------------------
// PARAMETERS
// PARAM NAME RANGE : DESCRIPTION : DEFAULT : UNITS
// 		PAR_WDATA_BYTE : [1...2] : data bus width : 2 : unsigned int
// -----------------------------------------------------------------------------
// REUSE ISSUES
// Reset Strategy      : synch, negative
// Clock Domains       : single
// Critical Timing     : 
// Test Features       : 
// Asynchronous I/F    : 
// Instantiations      : 
// Synthesizable (y/n) : y
// Other               : 
// -FHDR------------------------------------------------------------------------

`default_nettype none

module axis_adder 
#(
	  int PAR_WDATA_BYTE = 2
)(
	  input  wire  [1 : 0][(8 * PAR_WDATA_BYTE) - 1 : 0] s_axis_tdata
	, input  wire  [1 : 0]                               s_axis_tvalid
	, output logic [1 : 0]                               s_axis_tready
	
	, output logic [(8 * PAR_WDATA_BYTE) - 1 : 0] m_axis_tdata
	, output logic                                m_axis_tvalid
	, input  wire                                 m_axis_tready
);

// Module level time parameters. Eliminates dependencies from compilation order and directives.
timeunit 1ns;
timeprecision 1ps;

/////////////////////////////////////////////////////////////////////////////////

/* pure combinational variant */
assign m_axis_tdata = s_axis_tdata[0] + s_axis_tdata[1];
assign m_axis_tvalid = (&s_axis_tvalid);
assign s_axis_tready = '{2{(&s_axis_tvalid) && m_axis_tready}};

endmodule : axis_adder

`default_nettype wire

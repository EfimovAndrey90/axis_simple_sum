// +FHDR------------------------------------------------------------------------
// FILE NAME      : axis_reg.sv
// DEPARTMENT     : 
// AUTHOR         : Andrey Efimov
// AUTHOR'S EMAIL : efan_90_@mail.ru
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE    AUTHOR      DESCRIPTION
// 1.0 2023-02-21  A. Efimov   Initial
// -----------------------------------------------------------------------------
// KEYWORDS : axis, sum
// -----------------------------------------------------------------------------
// PURPOSE : Double axis buffer ("ping-pong" buffer)
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

module axis_reg
#(
	  int PAR_WDATA_BYTE = 2
)(
	  input  wire aclk
	, input  wire aresetn
	
	, input  wire  [(8 * PAR_WDATA_BYTE) - 1 : 0] s_axis_tdata
	, input  wire                                 s_axis_tvalid
	, output logic                                s_axis_tready
	
	, output logic [(8 * PAR_WDATA_BYTE) - 1 : 0] m_axis_tdata
	, output logic                                m_axis_tvalid
	, input  wire                                 m_axis_tready
);

// Module level time parameters. Eliminates dependencies from compilation order and directives.
timeunit 1ns;
timeprecision 1ps;

// synch siglals
logic [1 : 0][(8 * PAR_WDATA_BYTE) - 1 : 0] reg_data;
logic [1 : 0]                               reg_valid;
logic [1 : 0] ready_dl;

// combinatorial signals
logic [1 : 0][(8 * PAR_WDATA_BYTE) - 1 : 0] internal_data;
logic [1 : 0]                               internal_valid;

/////////////////////////////////////////////////////////////////////////////////

// assign output signals
assign m_axis_tdata  = reg_data[1];
assign m_axis_tvalid = reg_valid[1];
assign s_axis_tready = ready_dl[1];

// internal combinatorial logic
// out ready if master ready or out is unused (no valid)
assign ready_dl[0] = (m_axis_tready || ((!m_axis_tready) && (!reg_valid[1])));

// multiplexers for writing data to one of two buffers from double buffering scheme
// registers numbers according to its bus direction
// prev_ready | ready | wr0    | wr1
//     0      |   0   | keep   | keep
//     0      |   1   | keep   | from reg 0
//     1      |   0   | in     | keep
//     1      |   1   | keep   | in

assign internal_data[1] = // (!aresetn) ? '0 : 
	(ready_dl[0]) ? ((ready_dl[1]) ? s_axis_tdata : reg_data[0]) : reg_data[1];
	
assign internal_data[0] = // (!aresetn) ? '0 : 
	((!ready_dl[0]) && ready_dl[1]) ? s_axis_tdata : reg_data[0];

assign internal_valid[1] = // (!aresetn) ? '0 : 
	(ready_dl[0]) ? ((ready_dl[1]) ? s_axis_tvalid : reg_valid[0]) : reg_valid[1];
	
assign internal_valid[0] = // (!aresetn) ? '0 : 
	((!ready_dl[0]) && ready_dl[1]) ? s_axis_tvalid : reg_valid[0];
	

// synch DFFs
always_ff @(posedge aclk)
	begin
		if (!aresetn) begin
			reg_valid <= '0;
		end else begin
			reg_data  <= internal_data;
			reg_valid <= internal_valid;
		end
	end

always_ff @(posedge aclk)
	begin
		if (!aresetn) begin
			ready_dl[1]  <= '0;
		end else begin
			ready_dl[1]  <= ready_dl[0];
		end
	end

endmodule : axis_reg

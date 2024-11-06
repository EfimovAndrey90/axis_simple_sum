// +FHDR------------------------------------------------------------------------
// FILE NAME      : axis_adder_top.sv
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

module axis_adder_top
#(
	  int PAR_WDATA_BYTE = 2
)(
	  input  wire aclk
	, input  wire aresetn
				 
	, input  wire  [1 : 0][(8 * PAR_WDATA_BYTE) - 1 : 0] s_axis_tdata
	, input  wire  [1 : 0]                               s_axis_tvalid
	, output logic [1 : 0]                               s_axis_tready
	
	, output logic [(8 * PAR_WDATA_BYTE) - 1 : 0] m_axis_tdata
	, output logic                                m_axis_tvalid
	, input  wire                                 m_axis_tready
);

// Module level time parameters. Eliminates dependencies from compilation order and directives.
timeunit 1ns;
timeprecision 1ps;

logic  [1 : 0][(8 * PAR_WDATA_BYTE) - 1 : 0] axis_tdata;
logic  [1 : 0]                               axis_tvalid;
logic  [1 : 0]                               axis_tready;

// signals for extra output reg
logic  [(8 * PAR_WDATA_BYTE) - 1 : 0] add_axis_tdata;
logic                                 add_axis_tvalid;
logic                                 add_axis_tready;

// input double buffers
generate
	genvar n_gen;
	for (n_gen = 0; n_gen < 2; n_gen++) begin : gen_buf_in
		axis_reg #(PAR_WDATA_BYTE) inst_reg_in (
			  .aclk(aclk)
			, .aresetn(aresetn)

			, .s_axis_tdata(s_axis_tdata[n_gen])
			, .s_axis_tvalid(s_axis_tvalid[n_gen])
			, .s_axis_tready(s_axis_tready[n_gen])

			, .m_axis_tdata(axis_tdata[n_gen])
			, .m_axis_tvalid(axis_tvalid[n_gen])
			, .m_axis_tready(axis_tready[n_gen])
		);
	end : gen_buf_in
endgenerate

// adder module
axis_adder #(PAR_WDATA_BYTE) inst_addr (
	  .s_axis_tdata(axis_tdata)
	, .s_axis_tvalid(axis_tvalid)
	, .s_axis_tready(axis_tready)

	// if adder is pure combinational use separate output reg
	, .m_axis_tdata(add_axis_tdata)
	, .m_axis_tvalid(add_axis_tvalid)
	, .m_axis_tready(add_axis_tready)	
);

// output double buffer
axis_reg #(PAR_WDATA_BYTE) inst_reg_out (
	  .aclk(aclk)
	, .aresetn(aresetn)

	, .s_axis_tdata(add_axis_tdata)
	, .s_axis_tvalid(add_axis_tvalid)
	, .s_axis_tready(add_axis_tready)

	, .m_axis_tdata(m_axis_tdata)
	, .m_axis_tvalid(m_axis_tvalid)
	, .m_axis_tready(m_axis_tready)
);

endmodule : axis_adder_top
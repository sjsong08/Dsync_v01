// megafunction wizard: %LPM_MUX%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_MUX 

// ============================================================
// File Name: data_MUX.v
// Megafunction Name(s):
// 			LPM_MUX
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.1.0 Build 162 10/23/2013 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module data_MUX (
	data0x,
	data1x,
	data2x,
	sel,
	result);

	input	[23:0]  data0x;
	input	[23:0]  data1x;
	input	[23:0]  data2x;
	input	[1:0]  sel;
	output	[23:0]  result;

	wire [23:0] sub_wire0;
	wire [23:0] sub_wire4 = data2x[23:0];
	wire [23:0] sub_wire3 = data1x[23:0];
	wire [23:0] result = sub_wire0[23:0];
	wire [23:0] sub_wire1 = data0x[23:0];
	wire [71:0] sub_wire2 = {sub_wire4, sub_wire3, sub_wire1};

	lpm_mux	LPM_MUX_component (
				.data (sub_wire2),
				.sel (sel),
				.result (sub_wire0)
				// synopsys translate_off
				,
				.aclr (),
				.clken (),
				.clock ()
				// synopsys translate_on
				);
	defparam
		LPM_MUX_component.lpm_size = 3,
		LPM_MUX_component.lpm_type = "LPM_MUX",
		LPM_MUX_component.lpm_width = 24,
		LPM_MUX_component.lpm_widths = 2;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_SIZE NUMERIC "3"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MUX"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "24"
// Retrieval info: CONSTANT: LPM_WIDTHS NUMERIC "2"
// Retrieval info: USED_PORT: data0x 0 0 24 0 INPUT NODEFVAL "data0x[23..0]"
// Retrieval info: USED_PORT: data1x 0 0 24 0 INPUT NODEFVAL "data1x[23..0]"
// Retrieval info: USED_PORT: data2x 0 0 24 0 INPUT NODEFVAL "data2x[23..0]"
// Retrieval info: USED_PORT: result 0 0 24 0 OUTPUT NODEFVAL "result[23..0]"
// Retrieval info: USED_PORT: sel 0 0 2 0 INPUT NODEFVAL "sel[1..0]"
// Retrieval info: CONNECT: @data 0 0 24 0 data0x 0 0 24 0
// Retrieval info: CONNECT: @data 0 0 24 24 data1x 0 0 24 0
// Retrieval info: CONNECT: @data 0 0 24 48 data2x 0 0 24 0
// Retrieval info: CONNECT: @sel 0 0 2 0 sel 0 0 2 0
// Retrieval info: CONNECT: result 0 0 24 0 @result 0 0 24 0
// Retrieval info: GEN_FILE: TYPE_NORMAL data_MUX.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL data_MUX.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL data_MUX.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL data_MUX.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL data_MUX_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL data_MUX_bb.v TRUE
// Retrieval info: LIB_FILE: lpm

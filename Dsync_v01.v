		module Dsync_v01(
				input in_clk, Reset, Connect, reset2,
				input GPIO_BT,
				input [3:0] SW,
			
				output clk, clkout,
				output MAP, RS, RF, 
				output [3:0] RES,
				output reg TX_DE, TX_Hsync, TX_Vsync,
				output TX_out_R, TX_out_DE,
				output [59:0] TX_D,
				
				
				output BT_sig, BT_reset,
				
				output reg [3:0] LED,
				output reg [3:0] LED2
				
				);
						
						
				
//=============== LVDS TX CONFIG ==================
assign MAP 	= 1'b1; 
assign RS 	= 1'b1;
assign RF	= 1'b0;
assign RES  = 4'd0;

//=============== FOR CDR & BT CON ================
wire En_BT_out, CDR_BT_out, BT_RESET;
wire [2:0] Pattern;
assign BT_reset = (!Reset)? 1'b0 : (BT_RESET)? 1'b0 : 1'b1;

//=============== Parameters =====================
parameter htotal = 12'd520;//12'd2080;

parameter hres = 12'd480;//12'd1920;
parameter vres = 13'd1080;
parameter HFP = 12'd12;//12'd48;
parameter HS = 12'd8;//12'd32;
parameter VFP = 13'd3;
parameter VS = 13'd5;		

parameter vtotal30 = 13'd5280;
parameter vtotal60 = 13'd2640;//1100 + 1540
parameter vtotal90 = 13'd1760;
parameter vtotal120 = 13'd1320;
parameter vtotal144 = 13'd1100;

wire[12:0] vtotal2use;
wire[2:0] frameNum;
assign vtotal2use = (FR_mode==4'd0)? vtotal30 : (FR_mode==4'd1)? vtotal60 : (FR_mode==4'd2)? vtotal90 : (FR_mode==4'd3)? vtotal120 : vtotal144;			
/*
always @(posedge clkout)
begin
	if(vcnt==13'd1)
	begin
		if(FR_mode==4'd0)
			vtotal2use<=vtotal30;
		else if(FR_mode==4'd1)
			vtotal2use<=vtotal60;
		else if(FR_mode==4'd2)
			vtotal2use<=vtotal90;
		else if(FR_mode==4'd3)
			vtotal2use<=vtotal120;
		else
			vtotal2use<=vtotal144;
	end
end
	*/		
//=============== DATAs=====================
assign TX_D[9:0] = {out_MUX1[7:0],2'b11};
assign TX_D[19:10] = {out_MUX1[15:8],2'b11};
assign TX_D[29:20] = {out_MUX1[23:16],2'b11};
assign TX_D[39:30] = {out_MUX2[7:0],2'b11};
assign TX_D[49:40] = {out_MUX2[15:8],2'b11};
assign TX_D[59:50] = {out_MUX2[23:16],2'b11};

assign TX_out_R = out_MUX1[0];
assign TX_out_DE = TX_DE;

//=============== WIRES ====================
wire [31:0] frameRate;


//=============== sub module ========================
clkgen 		u0 (.inclk0(in_clk), .c0(clk));

clkgen10 	u1	(.inclk0(in_clk), .c0(CLOCK_10));

clkgen_out 	u2	(.inclk0(in_clk), .c0(clkout));

wire clk_329;
clkgen_329  u3 (.inclk0(in_clk), .c0(clk_329));

CDR_BT 		u20 (
	.CLOCK_10					(CLOCK_10),
	.dat_in						(GPIO_BT),
	.dat_out						(CDR_BT_out),
	.reset						(!Reset),
	.En_out						(En_BT_out)
);

BT_Con 		u21 (
	.CLOCK_10					(CLOCK_10),
	.reset 						(!Reset),
	.reset2						(!reset2),
	.Connect						(!Connect),
	.BT_Rx						(CDR_BT_out),
	.C_en							(En_BT_out),
	
	.BT_sig						(BT_sig),
	.Pattern						(Pattern),
	.BT_RESET					(BT_RESET),
	.frameRate					(frameRate),
	.frameNum					(frameNum)
	//.abc							(abc)
);

wire [23:0] out_MUX1, out_MUX2;
data_MUX 	u30 (
			.data0x({R2,G2,B2}),
			.data1x({R1,G1,B1}),
			.data2x(24'd0),
			.sel({!TX_DE,clkout}),
			.result(out_MUX1)
			);
			
data_MUX 	u31 (
			.data0x({R4,G4,B4}),
			.data1x({R3,G3,B3}),
			.data2x(24'd0),
			.sel({!TX_DE,clkout}),
			.result(out_MUX2)
			);			
			
wire [7:0] Rtmp, Gtmp, Btmp;
PatternGen   u32 (
			.clk (clkout),
			.hcnt (hcnt),
			.vcnt (vcnt),
			.mode (SW),
			
			.R (Rtmp),
			.G (Gtmp),
			.B (Btmp)
			);

//=============== RGB data Gen =====================
reg [7:0] R1, R2, R3, R4;
reg [7:0] G1, G2, G3, G4;
reg [7:0] B1, B2, B3, B4;
always @(posedge clkout)
begin
	if(!Reset)
	begin
		R1<=8'd255;R2<=8'd255;R3<=8'd255;R4<=8'd255;
		G1<=8'd255;G2<=8'd255;G3<=8'd255;G4<=8'd255;
		B1<=8'd255;B2<=8'd255;B3<=8'd255;B4<=8'd255;
	end
	else
	begin
		R1<=Rtmp; R2<=Rtmp; R3<=Rtmp; R4<=Rtmp;
		G1<=Gtmp; G2<=Gtmp; G3<=Gtmp; G4<=Gtmp;
		B1<=Btmp; B2<=Btmp; B3<=Btmp; B4<=Btmp;
	end
	
end
			
		

//=============== Frame Rate Variance ============
reg [3:0] FR_cnt;
reg [3:0] FR_mode;
reg FR_change;
always @(posedge clkout)
begin
	if(!Reset)
		FR_cnt <= 4'd0;
	
	else
	begin	
		if(vcnt == vres && hcnt == hres)
		begin		
			FR_change<=1'b1;

			if(FR_cnt >= frameNum-3'd1)
				FR_cnt <= 4'd0;
			else
				FR_cnt <= FR_cnt + 4'd1;
		end
		else
			FR_change<=1'b0;
	end
end
	
always @(posedge clkout)
begin
	if(!Reset)
		FR_mode <=4'd4;
	else
	begin	
		if(FR_change)
		begin
		case(FR_cnt)
		4'd0: FR_mode <=frameRate[3:0];
		4'd1: FR_mode <=frameRate[7:4];
		4'd2: FR_mode <=frameRate[11:8];
		4'd3: FR_mode <=frameRate[15:12];
		4'd4: FR_mode <=frameRate[19:16];
		4'd5: FR_mode <=frameRate[23:20];
		4'd6: FR_mode <=frameRate[27:24];
		4'd7: FR_mode <=frameRate[31:28];
		endcase
		end
		else
			FR_mode<=FR_mode;
	end
end
//=============== Patter Select ==================
/*
always @(posedge clkout)
begin
	if(!Reset)
		LED<=4'd0;
	else
	begin
		if(Pattern == 3'd1)
			LED<=4'd1;
		else if(Pattern == 3'd2)
			LED<=4'd2;
		else if(Pattern == 3'd3)
			LED<=4'd4;
		else if(Pattern == 3'd4)
			LED<=4'd8;
	end
end
*/
always @(posedge clkout)
begin
	if(!Reset)
	begin
		LED<=4'd0;
		LED2<=4'd0;
	end
	else
	begin
		LED[2:0]<=frameNum;
	end
end

//=============== Signal Gen =====================
reg [11:0] hcnt; 
reg [12:0] vcnt;

always @(posedge clkout)
begin
	if(!Reset)
		hcnt <= 12'd0;
	else if(hcnt == htotal - 12'b1)
		hcnt <= 12'd0;
	else
		hcnt <= hcnt + 12'd1;
end

always @(posedge clkout)
begin
	if(!Reset)
		vcnt <= 13'd0;
	else
	begin
		if (hcnt == htotal - 12'b1)
		begin
			if (vcnt == vtotal2use - 13'b1)
				vcnt <= 13'd0;
			
			else
				vcnt <=  vcnt + 13'd1;
		end
		else
			vcnt <= vcnt;
	end
end

always @(posedge clkout)
begin
	if(vcnt <= vres - 13'b1)
	begin
		if (hcnt <= hres -12'b1)
		begin
			TX_DE<=1'b1;  
			TX_Hsync<=1'b1;
			TX_Vsync<=1'b1;
		end
		else
		begin
			TX_DE<=1'b0;
			TX_Hsync<=1'b0;
			TX_Vsync<=1'b0;
		end
	end
end
/*
always @(posedge clkout)
begin
	if(hcnt >= hres + HFP && hcnt < hres + HFP + HS)
		TX_Hsync <= 1'd1;
	else
		TX_Hsync <= 1'd0;
end

always @(posedge clkout)
begin
	if(vcnt >= vres + VFP && vcnt < vres + VFP + VS)
		TX_Vsync <= 1'd1;
	else
		TX_Vsync <= 1'd0;
end
*/

endmodule

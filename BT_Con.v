module BT_Con (input CLOCK_10, reset, reset2,
					input BT_Rx, C_en,
					input Connect,					
					output reg BT_sig, BT_RESET,				
					output reg [2:0] Pattern, frameNum,
					output reg [31:0] frameRate
					);

					
					
reg En;
reg [9:0] En_cnt;

always @(posedge CLOCK_10)
begin
	if(En_cnt == 10'd999)
	begin
		En<=1'b1;
		En_cnt<=10'd0;
	end
	
	else
	begin
		En<=1'b0;
		En_cnt<=En_cnt+10'd1;
	end
end


reg [29:0] delay_cnt;
reg ATD_START, PLUS, ATZ_START;

always @(posedge CLOCK_10)
begin
	if(reset2)
	begin
		ATD_START<=1'b0;
		delay_cnt<=30'd0;
		BT_RESET<=1'b0;
		PLUS<=1'b0;
		ATZ_START<=1'b0;
	end
	
	else if(Connect)
	begin
		delay_cnt<=30'd1;
	end
	
	else
	begin
		if(delay_cnt>=30'd1)
		begin
			if(delay_cnt==30'd1)
			begin
			BT_RESET<=1'b1;
			delay_cnt<=delay_cnt+30'd1;
			end
			
			else if(delay_cnt==30'd500_0000)
			begin
			BT_RESET<=1'b0;
			delay_cnt<=delay_cnt+30'd1;
			end			
			

		
		
			else if(delay_cnt==30'd2000_0000)
			begin
			ATD_START<=1'b1;
			delay_cnt<=delay_cnt+30'd1;
			end
			
			else if(delay_cnt==30'd2500_0000)
			begin
			ATD_START<=1'b0;
			delay_cnt<=30'd3000_0000;
			end		
			
			else
			delay_cnt<=delay_cnt+30'd1;
		end
		
		else
		begin
		ATD_START<=1'b0;
		delay_cnt<=30'd0;
		BT_RESET<=1'b0;
		PLUS<=1'b0;
		ATZ_START<=1'b0;
		end		
	end
end
	



//reg [29:0] AT = {30'b0_1000_0010_10_0010_1010_10_1011_0000_1};
reg [39:0] plus = {40'b0_1101_0100_10_1101_0100_10_1101_0100_10_1011_0000_1};
reg [39:0] ATZ = {40'b0_1000_0010_10_0010_1010_10_01011010_10_1011_0000_1};
//reg [99:0] BTSCAN = {100'b0_1000_0010_10_0010_1010_10_1101_0100_10_0100_0010_10_0010_1010_10_1100_1010_10_1100_0010_10_1000_0010_10_0111_0010_10_1011_0000_1};
reg [39:0] ATD = {40'b0_10000010_10_00101010_10_00100010_10_10110000_1};   //_10011100_10_00001100_10_00001100_10_00001100_10_00100010_10_01000010_10_01000010_10_11000010_10_10001100_10_11000010_10_11101100_10_01001100_10_10110000_1}; //9000DBBC1C72

always @(posedge CLOCK_10)
begin
	if(En)
	begin
		if(reset2)
		begin
			BT_sig<=plus[39];
			plus[39:1]<=plus[38:0];
			plus[0]<=1'b1;
			//BTSCAN <={100'b0_1000_0010_10_0010_1010_10_1101_0100_10_0100_0010_10_0010_1010_10_1100_1010_10_1100_0010_10_1000_0010_10_0111_0010_10_1011_0000_1};
			//AT <= {30'b0_1000_0110_10_0010_1110_10_1011_0000};
			ATD <= {40'b0_10000010_10_00101010_10_00100010_10_10110000_1}; 
			//plus <= {40'b0_1101_0100_10_1101_0100_10_1101_0100_10_1011_0000_1};
			ATZ <= {40'b0_1000_0010_10_0010_1010_10_01011010_10_1011_0000_1};
		end
		
		else
		begin
			if(ATD_START==1'b1)
			begin
				BT_sig<=ATD[39];
				ATD[39:1]<=ATD[38:0];
				ATD[0]<=1'b1;
			end
			
			else if(PLUS == 1'b1)
			begin
				BT_sig<=plus[39];
				plus[39:1]<=plus[38:0];
				plus[0]<=1'b1;//ATZ[39];
				//ATZ[39:1]<=ATZ[38:0];
				//ATZ[0]<=1'b1;				
			end
			
			else if(ATZ_START)
			begin
				BT_sig<=ATZ[39];
				ATZ[39:1]<=ATZ[38:0];
				ATZ[0]<=1'b1;
			end
			/*
			else if(Open==1'b0)
			begin
				//BTSCAN <={100'b0_1000_0010_10_0010_1010_10_1101_0100_10_0100_0010_10_0010_1010_10_1100_1010_10_1100_0010_10_1000_0010_10_0111_0010_10_1011_0000_1};
				//AT <= {30'b0_1000_0110_10_0010_1110_10_1011_0000};
				ATD <= {40'b0_10000010_10_00101010_10_00100010_10_10110000_1}; 
				plus <= {40'b0_1101_0100_10_1101_0100_10_1101_0100_10_1011_0000_1};
				ATZ <= {40'b0_1000_0010_10_0010_1010_10_01011010_10_1011_0000_1};
			end
			*/
			else
			begin	
				BT_sig<=1'b1;
				ATD <= {40'b0_10000010_10_00101010_10_00100010_10_10110000_1}; 
				plus <= {40'b0_1101_0100_10_1101_0100_10_1101_0100_10_1011_0000_1};
				ATZ <= {40'b0_1000_0010_10_0010_1010_10_01011010_10_1011_0000_1};
			end
		end
	end
end

reg [9:0] BT_RX_data;
always @(posedge CLOCK_10)
begin
	if(C_en)
	begin
		BT_RX_data[9:1]<=BT_RX_data[8:0];
		BT_RX_data[0]<=BT_Rx;
	end
end

reg [19:0] Sequence;
always @(posedge CLOCK_10)
begin
	if(reset)
		Sequence<=20'd0;
	else
	begin
		if(C_en)
		begin
			Sequence[19:1]<=Sequence[18:0];
			Sequence[0]<=BT_Rx;
		end
	end
end


reg D_en;
always @(posedge CLOCK_10)
begin
	if(reset)
	begin
		D_en 	<= 1'b0;
	end
	else
	begin
		if(C_en)
		begin
			if(!D_en)
			begin
				if(!BT_Rx)
					D_en<=1'b1;			
			end
			
			else
			begin
				if(Sequence==20'b1111_1111_1111_1111_1111)
					D_en<=1'b0;
			end
		end
	end
end

reg [3:0] D_cnt;
always @(posedge CLOCK_10)
begin
	if(reset)
		D_cnt<=4'd0;
	else
	begin
		if(C_en)
		begin
			if(D_en)
			begin
				if(D_cnt==4'd9)
					D_cnt<=4'd0;
				else
					D_cnt<=D_cnt+4'd1;
			end
			else
				D_cnt<=4'd0;
		end
	end
end
				
				
	
	

reg frame_En;
always @(posedge CLOCK_10)
begin	
	if(reset)
		Pattern<=3'd0;
	else if(frame_En_stop || D_en==1'b0)
		frame_En<=1'b0;

	else
	begin
		if(D_cnt==4'd9)
		begin
			if(frame_En)
				Pattern<=Pattern;
			else
			begin
				if(BT_RX_data == 10'b01000_11001)//1
				begin
					Pattern<=3'd1;
				end
				else if(BT_RX_data == 10'b00100_11001)//2
				begin
					Pattern<=3'd2;
				end
			
				else if(BT_RX_data == 10'b01100_11001)//3
				begin
					Pattern<=3'd3;
				end
			
				else if(BT_RX_data == 10'b00010_11001)//4
				begin
					Pattern<=3'd4;
				end
			
				else if(BT_RX_data == 10'b00110_01101)//f
				begin
					frame_En<=1'b1;
				end
			end
		end
	end
end



reg frame_En_stop;
reg [3:0] frame_cnt;
always @(posedge CLOCK_10)
begin
	if(reset)
	begin
		frameRate <= 32'd4;
		frame_En_stop <=1'b0;
		frame_cnt <=4'd0;
		frameNum <=4'd1;
	end
	
	else
	begin
		if(frame_En)
		begin
			frame_En_stop<=1'b0;
			if(frame_cnt==4'd0)
				frame_cnt<=4'd1;				
			
			if(C_en)
			begin
				if(D_cnt==4'd9)
				begin
				case(frame_cnt)
				4'd1: begin
						if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameNum<=4'd1;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameNum <=4'd2;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameNum <=4'd3;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameNum <=4'd4;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b01010_11001)//5
						begin
							frameNum <=4'd5;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b00110_11001)//6
						begin
							frameNum <=4'd6;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b01110_11001)//7
						begin
							frameNum <=4'd7;
							frame_cnt<=4'd2;
						end
						else if(BT_RX_data == 10'b00001_11001)//8
						begin
							frameNum <=4'd8;
							frame_cnt<=4'd2;
						end
					end
						
				4'd2: begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[3:0] <=4'd0;
							frame_cnt<=4'd3;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[3:0] <=4'd1;
							frame_cnt<=4'd3;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[3:0] <=4'd2;
							frame_cnt<=4'd3;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[3:0] <=4'd3;
							frame_cnt<=4'd3;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[3:0] <=4'd4;
							frame_cnt<=4'd3;
						end
					end
				4'd3: begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[7:4] <=4'd0;
							frame_cnt<=4'd4;
							end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[7:4] <=4'd1;
							frame_cnt<=4'd4;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[7:4] <=4'd2;
							frame_cnt<=4'd4;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[7:4] <=4'd3;
							frame_cnt<=4'd4;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[7:4] <=4'd4;
							frame_cnt<=4'd4;
						end
					end
				4'd4: begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[11:8] <=4'd0;
							frame_cnt<=4'd5;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[11:8] <=4'd1;
							frame_cnt<=4'd5;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[11:8] <=4'd2;
							frame_cnt<=4'd5;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[11:8] <=4'd3;
							frame_cnt<=4'd5;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[11:8] <=4'd4;
							frame_cnt<=4'd5;
						end
					end
				4'd5: begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[15:12] <=4'd0;
							frame_cnt<=4'd6;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[15:12] <=4'd1;
							frame_cnt<=4'd6;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[15:12] <=4'd2;
							frame_cnt<=4'd6;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[15:12] <=4'd3;
							frame_cnt<=4'd6;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[15:12] <=4'd4;
							frame_cnt<=4'd6;
						end
					end
				4'd6: begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[19:16] <=4'd0;
							frame_cnt<=4'd7;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[19:16] <=4'd1;
							frame_cnt<=4'd7;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[19:16] <=4'd2;
							frame_cnt<=4'd7;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[19:16] <=4'd3;
							frame_cnt<=4'd7;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[19:16] <=4'd4;
							frame_cnt<=4'd7;
						end
					end
				4'd7: begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[23:20] <=4'd0;
							frame_cnt<=4'd8;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[23:20] <=4'd1;
							frame_cnt<=4'd8;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[23:20] <=4'd2;
							frame_cnt<=4'd8;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[23:20] <=4'd3;
							frame_cnt<=4'd8;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[23:20] <=4'd4;
							frame_cnt<=4'd8;
						end
					end
				4'd8:  begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[27:24] <=4'd0;
							frame_cnt<=4'd9;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[27:24] <=4'd1;
							frame_cnt<=4'd9;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[27:24] <=4'd2;
							frame_cnt<=4'd9;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[27:24] <=4'd3;
							frame_cnt<=4'd9;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[27:24] <=4'd4;
							frame_cnt<=4'd9;
						end
					end
					
				4'd9:  begin
						if(BT_RX_data == 10'b00000_11001)//0
						begin
							frameRate[31:28] <=4'd0;
							frame_cnt<=4'd0;
							frame_En_stop<=1'b1;
						end
						else if(BT_RX_data == 10'b01000_11001)//1
						begin
							frameRate[31:28] <=4'd1;
							frame_cnt<=4'd0;
							frame_En_stop<=1'b1;
						end
						else if(BT_RX_data == 10'b00100_11001)//2
						begin
							frameRate[31:28] <=4'd2;
							frame_cnt<=4'd0;
							frame_En_stop<=1'b1;
						end
						else if(BT_RX_data == 10'b01100_11001)//3
						begin
							frameRate[31:28] <=4'd3;
							frame_cnt<=4'd0;
							frame_En_stop<=1'b1;
						end
						else if(BT_RX_data == 10'b00010_11001)//4
						begin
							frameRate[31:28] <=4'd4;
							frame_cnt<=4'd0;
							frame_En_stop<=1'b1;
						end
					end
				endcase
				end
			end
		end
		else
			frame_cnt<=4'd0;
	end
end

endmodule

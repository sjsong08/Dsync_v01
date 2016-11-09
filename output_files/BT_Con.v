
module BT_Con (input CLOCK_10, reset, 
					input BT_Rx, C_en,
					input Connect,					
					output reg BT_sig, 					
					output reg [2:0] Pattern);
					

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
reg ATD_START;

always @(posedge CLOCK_10)
begin
	if(reset)
	begin
		ATD_START<=1'b0;
		delay_cnt<=30'd0;
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
			delay_cnt<=delay_cnt+30'd1;
			end
			
			else if(delay_cnt==30'd600_0000)
			begin
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
		if(reset)
		begin
			BT_sig<=ATZ[39];
			ATZ[39:1]<=ATZ[38:0];
			ATZ[0]<=1'b1;
			//BTSCAN <={100'b0_1000_0010_10_0010_1010_10_1101_0100_10_0100_0010_10_0010_1010_10_1100_1010_10_1100_0010_10_1000_0010_10_0111_0010_10_1011_0000_1};
			//AT <= {30'b0_1000_0110_10_0010_1110_10_1011_0000};
			ATD <= {40'b0_10000010_10_00101010_10_00100010_10_10110000_1}; 
			plus <= {40'b0_1101_0100_10_1101_0100_10_1101_0100_10_1011_0000_1};
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
			/*
			else if(Force == 1'b1)
			begin
				BT_sig<=plus[39];
				plus[39:1]<=plus[38:0];
				plus[0]<=ATZ[39];
				ATZ[39:1]<=ATZ[38:0];
				ATZ[0]<=1'b1;				
			end
			
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

			end
		end
	end
end

reg [7:0] BT_RX_data;
always @(posedge CLOCK_10)
begin
	if(C_en)
	begin
		BT_RX_data[7:1]<=BT_RX_data[6:0];
		BT_RX_data[0]<=BT_Rx;
	end
end

always @(posedge CLOCK_10)
begin	
	if(reset)
		Pattern<=3'd0;
	
	else
	begin
		if(BT_RX_data == 8'b1000_1100)//1
		begin
			Pattern<=3'd1;
		end
		else if(BT_RX_data == 8'b0100_1100)//2
		begin
			Pattern<=3'd2;
		end
		
		else if(BT_RX_data == 8'b1100_1100)//3
		begin
			Pattern<=3'd3;
		end
		
		else if(BT_RX_data == 8'b0010_1100)//4
		begin
			Pattern<=3'd4;
		end
	end
end

endmodule

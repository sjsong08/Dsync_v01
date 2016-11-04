module CDR_BT (input CLOCK_10, dat_in, reset,
					output dat_out, En_out
					);
		

////////////Normal En signal////////////		
reg [9:0] ckcnt;
reg N_en;
always @(posedge CLOCK_10)
begin
	if(reset)
	begin
		N_en<=1'b0;
		ckcnt<=10'd0;
	end
	
	else
	begin
		if(ckcnt==10'd999)
		begin
			N_en<=1'b1;
			ckcnt<=10'b0;
		end
		else
		begin
			ckcnt<=ckcnt+10'd1;
			N_en<=1'b0;
		end
	end
end
					
////////////Sub En signal////////////
reg [9:0] Cnt_Sam;
reg S_en;
always @(posedge CLOCK_10)
begin
	if(reset)
	begin
		Cnt_Sam<=10'd333;
		S_en<=1'b0;
	end
	
	else
	begin	
		
		if(Cnt_Sam==10'd0)
		begin
			S_en <=1'b1;
			Cnt_Sam <= 10'd333;
//			Cnt_Sam <= (Up) ? 5'd14 : (Down) ? 5'd16 : 5'd15;
		end
		else
		begin
			S_en<=1'b0;
			Cnt_Sam <= (Up) ? Cnt_Sam - 10'd111 : (Down) ? Cnt_Sam + 10'd111 : Cnt_Sam - 10'd1;
//			Cnt_Sam<=Cnt_Sam-5'd1;
		end
	end
end

//////////data Sampling///////////
reg [2:0] dat_Sam;
always @(posedge CLOCK_10)
begin
	if(reset)
		dat_Sam<=3'd0;
	
	else
	begin
		if(S_en)
		begin
		dat_Sam[2:1] <= dat_Sam[1:0];
		dat_Sam[0] <= dat_in;
		end
	end
end

//////////Sub En numbering///////////
reg	[1:0]	Cnt_En;
always @(posedge CLOCK_10)
begin
	if (reset)
		Cnt_En <= 2'd2;
	else
	begin
		if (S_en)
		begin
			if (Cnt_En == 2'd0)
				Cnt_En <= 2'd2;
			else
				Cnt_En <= Cnt_En - 2'd1;
		end
	end
end

//////////Final En signal////////////
reg D_en;
always @(posedge CLOCK_10)
begin
	if (reset)
		D_en <= 1'd0;
	else
		if (S_en == 1'b1 && Cnt_En == 2'd0)
			D_en <= 1'd1;
		else
			D_en <= 1'd0;
end




////////////majority voting///////////////
reg Up, Down;
reg	majorData1;

always @(posedge CLOCK_10)
begin
		if (reset)
		begin
			majorData1 <= 1'b0;
			Up <= 1'b0;
			Down <= 1'b0;
		end
		else
		begin
			if (D_en)
			begin
				case (dat_Sam)
				3'b000: begin
					majorData1 <= 1'b0;
					Up <= 1'b0;
					Down <= 1'b0;
					end
				3'b001: begin
					majorData1 <= 1'b0;
					Up <= 1'b1;
					Down <= 1'b0;
					end
				3'b010: begin
					majorData1 <= 1'b0; //
					Up <= 1'b0;
					Down <= 1'b0;
					end
				3'b011: begin
					majorData1 <= 1'b1;
					Up <= 1'b0;
					Down <= 1'b1;
					end
				3'b100: begin
					majorData1 <= 1'b0;
					Up <= 1'b0;
					Down <= 1'b1;
					end
				3'b101: begin
					majorData1 <= 1'b1; //
					Up <= 1'b0;
					Down <= 1'b0;
					end
				3'b110: begin
					majorData1 <= 1'b1;
					Up <= 1'b1;
					Down <= 1'b0;
					end
				3'b111: begin
					majorData1 <= 1'b1;
					Up <= 1'b0;
					Down <= 1'b0;
					end
				endcase

			end
			else
			begin
					majorData1 <= majorData1;
					Up <= 1'b0;
					Down <= 1'b0;
			end
				
		end

end

reg majorData;

assign dat_out = majorData;
assign En_out =  D_en;

always @(posedge CLOCK_10)
begin
	if (reset)
	begin 
		majorData <= 1'b0;
	end
	else
	begin
		if (S_en)
			majorData <= majorData1;
		
	end
end

endmodule

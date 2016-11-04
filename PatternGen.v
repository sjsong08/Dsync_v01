module PatternGen (input clk,
						input[3:0] mode, 
						input[10:0] hcnt,
						input[11:0] vcnt,
						output reg[7:0] R, G, B
						);
						
always @(posedge clk)
begin
	if (mode==4'd0)
	begin
		R<=8'd255;
		G<=8'd255;
		B<=8'd255;
	end
	
	else if(mode==4'd1)
	begin
		R<=8'd127;
		G<=8'd127;
		B<=8'd127;
	end
	
	else if(mode==4'd2)
	begin
		if(vcnt<=12'd359)
		begin
			R<=8'd15;
			G<=8'd15;
			B<=8'd15;
		end
		else if(vcnt<12'd719)
		begin
			R<=8'd127;
			G<=8'd127;
			B<=8'd127;
		end
		else
		begin
			R<=8'd255;
			G<=8'd255;
			B<=8'd255;
		end
	end
end

endmodule
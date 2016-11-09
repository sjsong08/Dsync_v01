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
		R<=8'd159;
		G<=8'd159;
		B<=8'd159;
	end
	
	else if(mode==4'd3)
	begin
		R<=8'd95;
		G<=8'd95;
		B<=8'd95;
	end
end

endmodule
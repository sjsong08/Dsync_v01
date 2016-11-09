module memcon(
				input clk, reset, RorW, Act_start, Pre_start, Write_start, ActR_start, PreR_start, Read_start,
				input [10:0] row_cnt, col_cnt,
				input [2:0] BA_cnt,
				output reg CKE, CS, RAS, CAS, WE,
				output reg [2:0] BA,
				output reg [12:0] A,
				output reg DQML, DQMH,
				output reg [10:0] Write_add, Read_add, Read_burst
				);



reg intend;
reg [20:0]cntint;


//Initialize//
always@(posedge clk or negedge reset)
begin
	if(reset == 1'b0)
		cntint <= 21'd0;
	else
	begin
		if(intend == 1'b0)
		begin
			if(cntint == 21'd52000)
				cntint<= 21'd0;
			else
				cntint<=cntint + 21'd1;
		end
		
		else
			cntint<=cntint;
	end
end

reg [10:0] Write_burst;
reg Proc_start;
reg [3:0] Proc;
parameter s0 = 4'd0;
parameter s1 = 4'd1;
parameter s2 = 4'd2;
parameter s3 = 4'd3;
parameter s4 = 4'd4;
parameter s5 = 4'd5;
parameter s6 = 4'd6;
parameter s7 = 4'd7;
parameter s8 = 4'd8;
parameter s9 = 4'd9;
parameter s10 = 4'd10;
parameter s11 = 4'd11;

always @(posedge clk)
begin
	if(Read_burst == 11'd2)
	Write_add <= 11'd0;
	
	else if(Read_burst >= 11'd3 && Read_burst <= 11'd1025)
	Write_add <= Write_add + 11'd1;
	
	else
	Write_add <= 11'd2000;
end

always @(posedge clk)
begin
	if(Write_burst == 11'd1)
	Read_add <= 11'd0;
	
	else if(Write_burst >= 11'd2 && Write_burst <= 11'd1024)
	Read_add <= Read_add + 11'd1;
	
	else
	Read_add <= 11'd2000;
end


always @(posedge clk or negedge reset)
begin
	if(reset == 1'b0)
	begin
		CKE <= 1'b0;
		CS <= 1'b1;
		intend <= 1'b0;
		DQML <= 1'b0;
		DQMH <= 1'b0;
		BA<=BA_cnt; 
		RAS <= 1'b1;
		CAS <= 1'b1;
		WE <= 1'b1;
	end

	else
	begin
		if(intend == 1'b0)
		begin
			if(cntint == 21'd5)
			begin
			CKE <= 1'b1; DQML<=1'b1; DQMH<=1'b1; 			
			end
			else if(cntint == 21'd10110) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40200) // after T, precharge
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b1; WE<=1'b0; A[10]<=1'b0;
			end
			else if(cntint == 21'd40201) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; DQML<=1'b1; DQMH<=1'b1;
			end
///////////////////// 8 Auto Refresh commnads
			else if(cntint == 21'd40204) // after Trp, Auto Refresh 1
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40205) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40215) // Auto Refresh 2
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40216) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40226) // Auto Refresh 3
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40227) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40237) // Auto Refresh 4
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40238) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40248) // Auto Refresh 5
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40249) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40259) // Auto Refresh 6
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40260) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40270) // Auto Refresh 7
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40271) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			else if(cntint == 21'd40281) // Auto Refresh 8
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b1; 
			end
			else if(cntint == 21'd40282) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
/////////////////////Load Mode Register
			else if(cntint == 21'd40292) // load mode register
			begin
				CS<=1'b0; RAS<=1'b0; CAS<=1'b0; WE<=1'b0; BA<=BA_cnt;
				A[10]<=1'b0; A[9:0]<=10'b0_00_011_0_111;
			end
			
			else if(cntint == 21'd40293) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
			end
			
			
			else if(cntint == 21'd40298) // NOP
			begin
				CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1;
				intend <= 1;
			end
		end
/////////////////////Initialize Finish



		else if(intend)
		begin
					
			if(RorW == 1'b0) //Write
			begin
				if(row_cnt >= 11'd1081)
				begin
					CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
					Proc_start <= 1'b0; Proc <= s0;
					Write_burst <= 11'd0;
				end
				
				else
				begin

					if(Act_start)
					begin
						CS<=1'b0; RAS<=1'b0; CAS<=1'b1; WE<=1'b1; //BANK ACTIVE
						A[12:0] <= {2'b00, row_cnt};
						BA <= BA_cnt;
						Proc_start <= 1'b1; Proc<=s1;
						Write_burst <= 11'd0;
					end
				
					if(Proc_start)
					begin
						case(Proc)
						s1 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Proc<=s2;
							Write_burst <= 11'd1;
						end

						s2 : begin
							Proc<=s3;
							Write_burst <= 11'd1;
						end

						s3 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b0; WE<=1'b0; DQML<=1'b0; DQMH<=1'b0; //WRITE
							A[10:0] <= {1'b0, col_cnt};
							Write_burst <= Write_burst + 11'd1;
							Proc<=s4;
						end

						s4 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Write_burst <= Write_burst + 11'd1;
							if(Write_burst == 11'd12)
							begin
								Proc<=s5;
								Write_burst <= 11'd0;
							end
						end

						s5 : begin
							CS<=1'b0; RAS<=1'b0; CAS<=1'b1; WE<=1'b0; A[10]<=1'b0; // Precharge
							Proc<=s0;
						end
						
						s0 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Proc_start <= 1'b0;
						end
						endcase
					end							

					
				end			

			end

			else  //Read
			begin
		
				if(row_cnt >= 11'd1080)
				begin
					CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
					Proc <= s0; Proc_start <= 1'b0;
					Read_burst <= 11'd0;
				end
				
				else
				begin

					if(ActR_start)
					begin
						CS<=1'b0; RAS<=1'b0; CAS<=1'b1; WE<=1'b1; //BANK ACTIVE
						A[12:0] <= {2'b00, row_cnt};
						BA <= BA_cnt;
						Proc_start <= 1'b1; Proc<=s1;
						Read_burst <= 11'd0;
					end
				
					if(Proc_start)
					begin
						case(Proc)
						s1 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Proc<=s2;
						end

						s2 : begin
							Proc<=s3;
						end

						s3 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b0; WE<=1'b1; DQML<=1'b0; DQMH<=1'b0; //READ
							A[10:0] <= {1'b0, col_cnt};
							Read_burst <= 11'd0;
							Proc<=s4;
						end


						s4 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Proc<=s5;
							Read_burst <= 11'd1;
						end

						s5 : begin
							Proc<=s6;
							Read_burst <= Read_burst + 11'd1;
						end
						
						s6 : begin
							Read_burst <= Read_burst + 11'd1;
							if(Read_burst == 11'd10)	
							begin
							Read_burst <= Read_burst + 11'd1;
							Proc<=s7;
							end
						end

						s7 : begin
							CS<=1'b0; RAS<=1'b0; CAS<=1'b1; WE<=1'b0; A[10]<=1'b0; // Precharge
							Proc<=s8;
							Read_burst <= Read_burst + 11'd1;
							end
						
						s8 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Read_burst <= Read_burst + 11'd1;
							Proc<=s0;	
						end

						s0 : begin
							CS<=1'b0; RAS<=1'b1; CAS<=1'b1; WE<=1'b1; // NOP
							Proc_start <= 1'b0;
							Read_burst <= 11'd0;
						end
						endcase
					end							
				end			
			end
		end
	end
end





endmodule


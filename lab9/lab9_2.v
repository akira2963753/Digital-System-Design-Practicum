module lab9_2(	clk,
				reset,
				LCD_DATA,
				LCD_RW,
				LCD_EN,
				LCD_RS,
				LCD_RST,
				clear
				);					
input	clk;
input	reset;
input	clear;

output	[7:0]	LCD_DATA;
output	LCD_RW;
output	LCD_EN;
output	LCD_RS;
output	LCD_RST;

reg		[7:0]	LCD_DATA;
reg		LCD_RW;
reg		LCD_EN;
reg		LCD_RS;
reg		LCD_RST;

reg		[3:0]	state;
reg		[17:0]	counter;
reg		[5:0]	DATA_INDEX;



wire		[7:0]	DATA;

LCDM_table	M1(DATA_INDEX,DATA);

always	@(posedge	clk or negedge	reset)begin
	if(!reset)begin
		LCD_DATA	<= 8'd0;
		LCD_RW	<= 1'b1;
		LCD_EN	<= 1'b1;
		LCD_RS	<= 1'b0;
		state		<= 4'd0;
		counter	<= 18'd0;
		DATA_INDEX	<= 6'd0;
		LCD_RST		<= 1'b1;
	end
	else begin
		case(state)
			//select state
			4'd0:begin
				if(DATA_INDEX == 6'd32)
					state	<= 4'd4;
				else if(DATA_INDEX == 6'd63)
					state	<= 4'd5;
				else begin
					state	<= 4'd1;
				end
				LCD_RST		<= 1'b0;
			end
			// set RS,EN,RW,DATA
			4'd1:begin
				LCD_EN	<= 1'b1;
				LCD_RS	<= 1'b1;
				LCD_RW	<= 1'b0;
				LCD_RST	<= 1'b0;
				LCD_DATA <= DATA[7:0];
				state		<= 4'd2;
			end
			// delay
			4'd2:begin
				if(counter	< 18'd1)//
					counter	<= counter+18'd1;
				else
					state		<= 4'd3;
			end
			4'd3:begin
				LCD_EN	<= 1'b0;
				counter	<= 18'd0;	
				DATA_INDEX		<= DATA_INDEX+6'd1;
				state		<= 4'd0;
			end
			// wating for clear button
			4'd4:begin
				if(!clear)begin
					state		<= 4'd1;
					LCD_RST		<= 1'b1;
				end
				else state	<= 4'd4;
			end
			4'd5:begin //finish
				state	<= 4'd5;
			end
			default:;
		endcase
	end
end

endmodule

module	LCDM_table(table_index,data_out);
input		[5:0]table_index;
output	reg	[7:0]data_out;

always@(table_index)begin
	case(table_index)
		//display 1st page
		6'd0: data_out = 8'h2E; // first row ?????????~~
		6'd1: data_out = 8'h54; 
		6'd2: data_out = 8'h55;
		6'd3: data_out = 8'h53;
		6'd4: data_out = 8'h54;
		6'd5: data_out = 8'h5F;
		6'd6: data_out = 8'h25;
		6'd7: data_out = 8'h25;
		6'd8: data_out = 8'h5F;
		6'd9: data_out = 8'h5F;
		6'd10: data_out = 8'h5F;
		6'd11: data_out = 8'h5F;
		6'd12: data_out = 8'h5F;
		6'd13: data_out = 8'h5F;
		6'd14: data_out = 8'h5F;
		6'd15: data_out = 8'h5F;
		6'd16: data_out = 8'h26; // second row?????????~~
		6'd17: data_out = 8'h30;
		6'd18: data_out = 8'h27;
		6'd19: data_out = 8'h21;
		6'd20: data_out = 8'h5F;
		6'd21: data_out = 8'h43;
		6'd22: data_out = 8'h4F;
		6'd23: data_out = 8'h55;
		6'd24: data_out = 8'h52;
		6'd25: data_out = 8'h53;
		6'd26: data_out = 8'h45;
		6'd27: data_out = 8'h5F;
		6'd28: data_out = 8'h5F;
		6'd29: data_out = 8'h5F;
		6'd30: data_out = 8'h5F;
		6'd31: data_out = 8'h5F; // finish	
		//display 2nd page
		6'd32: data_out = 8'h22;
		6'd33: data_out = 8'h11;
		6'd34: data_out = 8'h11;
		6'd35: data_out = 8'h11;		
		6'd36: data_out = 8'h10;
		6'd37: data_out = 8'h17;
		6'd38: data_out = 8'h11;
		6'd39: data_out = 8'h15;
		6'd40: data_out = 8'h17;
		6'd41: data_out = 8'h5F;//space char
		6'd42: data_out = 8'h5F;
		6'd43: data_out = 8'h5F;
		6'd44: data_out = 8'h5F;
		6'd45: data_out = 8'h5F;
		6'd46: data_out = 8'h5F;
		6'd47: data_out = 8'h5F;
		6'd48: data_out = 8'h5F;
		6'd49: data_out = 8'h5F;
		6'd50: data_out = 8'h5F;
		6'd51: data_out = 8'h5F;
		default:data_out = 8'h000;
	endcase
end

endmodule



module  trigger(clk,reset,sw_in,sw_out);
input   clk,sw_in,reset;
output  reg sw_out;
reg     tri_reg;

always@(posedge clk,negedge reset)begin
	if(!reset)begin
		sw_out <= 1'd0;
		tri_reg <= 1'd0;
	end
	else	begin
		if(sw_in == 1 && tri_reg == 0)sw_out <= 1'd1;
		else sw_out <= 1'd0;
		tri_reg <= sw_in;
	end
end  
endmodule

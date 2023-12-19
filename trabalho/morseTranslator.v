
module morseTranslator(
	input clk,
	input	sound_in,
	input reset,
	output wire [15:0] sound_detected,
	output wire lcd_rs, 
	output wire lcd_rw, 
	output wire lcd_e, 
	output wire lcd_on,
	output wire [7:0]lcd_db
);
	wire clock_debouced;
	wire clock_morse;
	wire clock_lcd;
	DivisorDeFrequencia #(.DIV_VALUE(50)) divide_lcd(.clk(clk),.divided_clk(clock_lcd));
	DivisorDeFrequencia #(.DIV_VALUE(100)) divide(.clk(clk),.divided_clk(clock_debouced));
	DivisorDeFrequencia #(.DIV_VALUE(7000)) counter(.clk(clk),.divided_clk(clock_morse));
	
	reg [15:0] count;
	reg debouced;

always @(posedge clock_debouced) 
begin
	if (reset == 0) 
	begin
		count = 0;
		debouced = 0;
	end
	else 
	begin
			if(sound_in == 1 && count == 0) 
			begin
				count = 1;
				debouced = 1;
			end
			
			if(sound_in == 0 && count > 0)
			begin
				count = count + 1;
			end
			
			if(sound_in == 1 && count > 0)
			begin
				count = 1;
			end
			
			if(count > 5000)
			begin
				count = 0;
				debouced = 0;
			end
			
	end
	
end
	parameter DEFINE_DOT_DASH = 248;
	parameter DEFINE_SPACE_LETTER = 2553; // 2553
	reg [15:0] count_dot_dash;
	reg [15:0] count_space;
	reg [15:0] morse_buffer;
	reg [7:0] morse_character;
	reg [3:0] index;
	reg aux,aux2, aux_ENB;

always @(posedge clock_morse) 
begin
	if (reset == 0) 
	begin
		morse_buffer = 0;
		morse_character = 0;
		count_dot_dash = 0;
		count_space = 0;
		index = 0;
		aux = 1;
		aux2 = 0;
		aux_ENB = 0;
	end
	
	if(debouced == 1)
	begin
		count_dot_dash = count_dot_dash + 1;
		
		if(count_dot_dash < DEFINE_DOT_DASH )// Caso seja um ponto 
		begin
			morse_buffer[index] = 1;
		end
	
		else // Caso seja um traço
		begin
			morse_buffer[index + 1] = 1;
		end
		aux = 0;
		aux2 = 1;
		count_space=0;
		
		aux_ENB = 0;
		 
	end
	else
	begin
		if(aux == 0)
		begin
			if(count_dot_dash >= DEFINE_DOT_DASH)
				index = index + 3;
			else
				index = index + 2;
			
			count_dot_dash = 0;
				
			aux = 1;
		
		end
		
		if(aux2 == 1)
		begin
			count_space = count_space + 1;
		end
		
		if(count_space > DEFINE_SPACE_LETTER) // Outra letra
		begin 
			morse_character = 8'd0;
			case (morse_buffer)
			
				16'b0000000000001101: morse_character = 8'd97; //a
				16'b0000000010101011: morse_character = 8'd98; //b
				16'b0000000101101011: morse_character = 8'd99; //c
				16'b0000000000101011: morse_character = 8'd100; //d
				16'b0000000000000001: morse_character = 8'd101; //e
				16'b0000000010110101: morse_character = 8'd102; //f
				16'b0000000001011011: morse_character = 8'd103; //g
				16'b0000000001010101: morse_character = 8'd104; //h
				16'b0000000000000101: morse_character = 8'd105; //i
				16'b0000001101101101: morse_character = 8'd106; //j
				16'b0000000001101011: morse_character = 8'd107; //k
				16'b0000000010101101: morse_character = 8'd108; //l
				16'b0000000000011011: morse_character = 8'd109; //m
				16'b0000000000001011: morse_character = 8'd110; //n
				16'b0000000011011011: morse_character = 8'd111; //o
				16'b0000000101101101: morse_character = 8'd112; //p
				16'b0000001101011011: morse_character = 8'd113; //q
				16'b0000000000101101: morse_character = 8'd114; //r
				16'b0000000000010101: morse_character = 8'd115; //s
				16'b0000000000000011: morse_character = 8'd116; //t
				16'b0000000000110101: morse_character = 8'd117; //u
				16'b0000000011010101: morse_character = 8'd118; //v
				16'b0000000001101101: morse_character = 8'd119; //w
				16'b0000000110101011: morse_character = 8'd120; //x
				16'b0000001101101011: morse_character = 8'd121; //y
				16'b0000000101011011: morse_character = 8'd122; //z
			
			endcase
			aux_ENB = 1;
			morse_buffer = 16'b0000000000000000;
			index = 0;
		end
		
	end

end

lcd2(.CLK(clock_lcd), .LCD_RS(lcd_rs), .LCD_RW(lcd_rw), .LCD_E(lcd_e), .LCD_DB(lcd_db), .DATA(morse_character), .OPER(1), .ENB(aux_ENB), .RST(~reset));

assign lcd_on = 1;
assign sound_detected = morse_buffer;

endmodule





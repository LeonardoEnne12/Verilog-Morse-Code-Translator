module DivisorDeFrequencia (
  input wire clk,
  output wire divided_clk
);

  reg [31:0] count;
  reg toggle;
  
  parameter DIV_VALUE = 100;

  always @(posedge clk) begin
		if (count == DIV_VALUE - 1) begin
		  count <= 0;
		  toggle <= ~toggle;
		end
		else
		  count <= count + 1;
	
	end

  assign divided_clk = toggle;

endmodule
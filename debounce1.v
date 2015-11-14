/******************************************************************

  Helsinki Hacklab - Protoboard for digital electronics workshops
    
  Debouncer module.
  
  XC9572XL-VQ44
  
******************************************************************/

module debounce1
    (
    input wire sample_clk, 
    input wire d_in,
    output wire d_out
    );
    
    parameter N = 2;

    // N-bit shift register
    reg [N-1:0] sreg;
    wire [N-1:0] s_next;

    always @( posedge sample_clk) begin
        sreg <= s_next;
    end
            
    assign s_next = { d_in, sreg[N-1:1] };

    // N-input AND
    assign d_out = (&sreg) ? 1 : 0;
 
endmodule

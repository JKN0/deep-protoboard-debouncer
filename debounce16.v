/******************************************************************

  Helsinki Hacklab - Protoboard for digital electronics workshops
    
  Button/switch debouncer for CPLD 1  
  
  XC9572XL-VQ44
  
******************************************************************/

module debounce16(
    input wire clk,
    input wire [7:0] pb_in,
    output wire [7:0] pb_out,
    input wire [7:0] sw_in,
    output wire [7:0] sw_out
    );

    // If DEBOUNCE_ALL not defined, buttons b8...b5 are NOT debounced
    
    //`define DEBOUNCE_ALL
    
    `ifdef DEBOUNCE_ALL
        // generating 16 debouncers: only 2-bit shift registers will fit to XC9572
        localparam sreglen = 2;
        localparam presclen = 18;   // use slower sample_clk (48 Hz)
    `else
        // generating 12 debouncers: 3-bit shift registers will fit to XC9572
        localparam sreglen = 3;
        localparam presclen = 17;   // use faster sample_clk (96 Hz)
    `endif
    
    // ------------------------------------------------------------
    // Debouncer clock: 
    //   25MHz/2^19 = 48 Hz, T = 21 ms  or
    //   25MHz/2^18 = 96 Hz, T = 11 ms
    
    wire sample_clk;
    reg [presclen:0] prescaler;

    always @(posedge clk) 
        prescaler <= prescaler+1;

    assign sample_clk = prescaler[presclen];

    genvar i;

    // ------------------------------------------------------------
    // Push button debouncers
    
    `ifdef DEBOUNCE_ALL
        // Generate 8 debouncers for push buttons
        generate
          for (i=0; i < 8; i=i+1) begin : pb_deb
             debounce1 #(sreglen) deb(
                .sample_clk(sample_clk),
                .d_in(~pb_in[i]),
                .d_out(pb_out[i])
                );
          end
        endgenerate
    `else
        // Generate 4 debouncers for push buttons b1...b4
        generate
          for (i=0; i < 4; i=i+1) begin : pb_deb
             debounce1 #(sreglen) deb(
                .sample_clk(sample_clk),
                .d_in(~pb_in[i]),
                .d_out(pb_out[i])
                );
          end
        endgenerate
        
        // connect buttons b8...b5 without debouncing
        assign pb_out[7:4] = ~pb_in[7:4];
    `endif

    // ------------------------------------------------------------
    // Switch debouncers
    
    // Generate 8 debouncers for switches
    generate
      for (i=0; i < 8; i=i+1) begin : sw_deb
         debounce1 #(sreglen) deb(
            .sample_clk(sample_clk),
            .d_in(~sw_in[i]),
            .d_out(sw_out[i])
            );
      end
    endgenerate

endmodule

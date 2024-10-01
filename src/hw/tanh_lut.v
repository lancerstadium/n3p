`timescale 1ns / 1ps

/* verilator lint_off WIDTHCONCAT */
module tanh_lut #(
    parameter AW = 10, //AW will be based on the size of the ROM we can afford in our design.
                       //in the best case AW = N;
    parameter DW = 16,
    parameter N = 16,
    parameter Q = 12
    )(
    input clk,
    input [N-1:0] phase,
    output [DW-1:0] tanh
    );
    /* verilator lint_off UNUSEDSIGNAL */
    reg [9:0] addra_reg;
    reg [9:0] addrb_reg;
    wire [15:0] tanha;
    wire [15:0] tanhb;
    wire ovr1,ovr2;

    wire [15:0] frac,one_minus_frac;
    wire [15:0] A1,A2;
    wire [15:0] one;
    wire [DW-1:0] tanh_temp;

    
    (* ram_style = "block" *)reg [15:0] mem [1<<10-1:0];  //ram_style can be 'block' or 'distributed' based on the
                                                            //utilization and other requirements in the project
    
    initial 
    begin
        $readmemb("tanh_data.mem",mem); //loading our RAM via a file
    end
    
    always@(posedge clk)
    begin
        addra_reg <= phase[9:0];
        addrb_reg <= phase[9:0] + 1'b1;
    end

    assign tanha = mem[addra_reg];
    assign tanhb = mem[addrb_reg];
    
    assign frac = {'d0,phase[N-AW-'d2-1:0]}; //rest of the LSBs that were not accounted for owing to the limited ROM size
    assign one = 16'b0001000000000000;       //'d1 in (N,Q) = (3,12) format
    assign one_minus_frac = one - frac;
    
    //qmult is the fixed point multiplier module, visit the fixed point arithmetic
    //article further in the series to learn of its exact operation
    /* verilator lint_off WIDTHTRUNC */
    qmult #(N,Q) mul1 (tanha,frac,A1,ovr1);              //calculates x*f(Ai)
    qmult #(N,Q) mul2 (tanhb,one_minus_frac,A2,ovr2);    //calculates (1-x)*f(Ai+1)
    
    assign tanh_temp = A1 + A2;    // linear interpolation formula: x*Ai + (1-x)*Ai+1
    
    //now, if the phase input is above 3 or below -3 then we just output 1, otherwise we output the calculated value
    //we also check for the sign, if the phase is negative, we return 2's complemented version of the calculated value
    assign tanh = (phase [N-1]) ? (phase[N-2] ? (16'b1111000000000000) : (~tanh_temp + 1'b1)) :(phase[N-2] ? (16'b0001000000000000):(tanh_temp));
    
endmodule

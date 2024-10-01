//file: mac_manual_fp
module mac_manual_fp(
    input clk,sclr,ce,
    input [15:0] a,
    input [15:0] b,
    input [31:0] c,
    output reg [31:0] p
    );

    wire [31:0] sum;
    wire [31:0] m;
    wire overflow;

    qmult #(3,12) mul(a,b,m, overflow);            //The fixed-point multiplier module
    qadd  #(3,12) add(m,c,sum);          //The fixed-point adder module

    always@(posedge clk,posedge sclr)
    begin
        if(sclr)
        begin
            p<=0;
        end
        else if(ce)
        begin
            p <= sum;
            //p <= (a*b+c);               //The previous mac_manual operation for regular integers
        end
    end
endmodule

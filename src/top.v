`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 08/23/2018 08:56:02 PM
// Design Name:
// Module Name: top
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module top (
       input wire clk_100,
       input wire ck_rst,
       input wire ftdi_rx,
       output wire ftdi_tx,
       input wire [7:0] ja,
       input wire [7:0] jb,
       input wire [3:0] btn
    );

    wire rst;
    reg [7:0] uart_data;
    wire click;

    wire scl = jb[0];
    wire sda = jb[1];
    wire vsync = jb[2];
    wire hsync = jb[3];
    wire pclk = jb[4];
    wire xclk = jb[5];

    debounce rst_debounce(
            .clk(clk_100),
            .din(ck_rst),
            .dout(rst)
        );

    debounce btn0_dbounce(
            .clk(clk_100),
            .din(btn[0]),
            .dout(click)
        );

    
    ov7675 camera(
        .clk_100(clk_100),
        .enable(1),
        .rst(rst),
        .sda(sda),
        .scl(scl),
        .vsync(vsync),
        .hsync(hsync),
        .pclk(pclk),
        .data(ja),
        .xclk(xclk),
        .click(click), // take a photo
        .ftdi_tx(ftdi_tx)
    );

endmodule

module debounce (
    input wire clk,
    input wire din,
    output reg dout = 1'b0
);

reg [7:0] shift = 8'd0;

always @(posedge clk)
begin
    dout <= 1'b0;
    shift <= {din, shift[7:1]};
    if(shift == 8'hff)
    begin
        dout <= 1'b1;
    end
end

endmodule

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 08/23/2018 09:11:55 PM
// Design Name:
// Module Name: ov7675
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


module clk_divider(
    input wire clk_in,
    output wire clk_out
    );
    parameter clk_ratio = 10;

    reg int_clk_out = 0;
    assign clock_out = int_clk_out;

    // ratio clock_in/clock_out

    reg [7:0] counter = 0;

    always @ (posedge clk_in) begin
        if (counter >= clk_ratio) begin
                counter <= 0;
                int_clk_out <= ~int_clk_out;
            end
        else
            counter <= counter + 1;
    end

endmodule

module ov7675(
    input wire clk_100,
    input wire enable,
    input wire rst,

    // control and command
    inout wire sda,
    inout wire scl,

    // camera data synchronized on pclk
    input wire vsync,
    input wire hsync,
    input wire pclk,
    input wire [7:0] data,

    // clock feeding the camera module
    output wire xclk,

    input wire click, // take a photo
    output wire ftdi_tx

    // output data back to us
    //output reg
    );

parameter CMD_WRITE = 0;
parameter CMD_READ = 1;
parameter INIT = 0;
parameter SEND_CONFIG = 1;
parameter SEND_CONFIG_CMD = 2;
parameter SEND_CONFIG_DATA = 3;
parameter CAMERA_READY = 3;
parameter BUFFERING_PHOTO = 4;
parameter BUFFERING_IN_PROGRESS = 5;
parameter config_length = 198;
parameter buffer_size = 1024;
parameter [14:0] qvga_config [config_length-1:0] =
    {
        {7'hff,8'hxff},
        {7'h11,8'h80},
        {7'h3a,8'h4},
        {7'h12,8'h0},
        {7'h17,8'h13},
        {7'h18,8'h1},
        {7'h32,8'hb6},
        {7'h19,8'h63}, // could be 63 decimal,
        {7'h1a,8'h7b},
        {7'h03,8'h01},
        {7'hc,8'h0},
        {7'h3e,8'h0},
        {7'h70,8'h3a},
        {7'h71,8'h35},
        {7'h72,8'h11},
        {7'h73,8'hf0},
        {7'ha2,8'h2},
        {7'h15,8'h0},
        {7'h7a,8'h18},
        {7'h7b,8'h4},
        {7'h7c,8'h9},
        {7'h7d,8'h18},
        {7'h7e,8'h38},
        {7'h7f,8'h47},
        {7'h80,8'h56},
        {7'h81,8'h66},
        {7'h82,8'h74},
        {7'h83,8'h7f},
        {7'h84,8'h89},
        {7'h85,8'h9a},
        {7'h86,8'ha9},
        {7'h87,8'hc4},
        {7'h88,8'hdb},
        {7'h89,8'hee},
        {7'h13,8'he0},
        {7'h1,8'h50},
        {7'h2,8'h68},
        {7'h0,8'h0},
        {7'h10,8'h0},
        {7'hd,8'h40},
        {7'h14,8'h48},
        {7'h15,8'h07},
        {7'hab,8'h8},
        {7'h24,8'h60},
        {7'h25,8'h50},
        {7'h26,8'he3},
        {7'h9f,8'h78},
        {7'ha0,8'h68},
        {7'ha1,8'h3},
        {7'ha6,8'hd8},
        {7'ha7,8'hd8},
        {7'ha8,8'hf0},
        {7'ha9,8'h90},
        {7'haa,8'h14},
        {7'h13,8'he5},
        {7'he,8'h61},
        {7'hf,8'h4b},
        {7'h16,8'h2},
        {7'h1e,8'h27},//0x1e,0x17,
        {7'h21,8'h2},
        {7'h22,8'h91},
        {7'h29,8'h07},
        {7'h33,8'hb},
        {7'h35,8'hb},
        {7'h37,8'h1d},
        {7'h38,8'h71},
        {7'h39,8'h2a},
        {7'h3c,8'h78},
        {7'h4d,8'h40},
        {7'h4e,8'h20},
        {7'h69,8'h0},
        {7'h4e,8'h20},
        {7'h74,8'h10},
        {7'h8d,8'h4f},
        {7'h8e,8'h0},
        {7'h8f,8'h0},
        {7'h90,8'h0},
        {7'h91,8'h0},
        {7'h92,8'h66},
        {7'h96,8'h0},
        {7'h9a,8'h80},
        {7'hb0,8'h84},
        {7'hb1,8'hc},
        {7'hb2,8'he},
        {7'hb3,8'h82},
        {7'hb8,8'h0a},
        {7'h43,8'h14},
        {7'h44,8'hf0},
        {7'h45,8'h41},
        {7'h46,8'h66},
        {7'h47,8'h2a},
        {7'h48,8'h3e},
        {7'h59,8'h8d},
        {7'h5a,8'h8e},
        {7'h5b,8'h53},
        {7'h5c,8'h83},
        {7'h5d,8'h4f},
        {7'h5e,8'he},
        {7'h6c,8'h0a},
        {7'h6d,8'h55},
        {7'h6e,8'h11},
        {7'h6f,8'h9e},
        {7'h62,8'h90},
        {7'h63,8'h30},
        {7'h64,8'h11},
        {7'h65,8'h0},
        {7'h66,8'h5},
        {7'h94,8'h11},
        {7'h95,8'h18},
        {7'h6a,8'h40},
        {7'h1,8'h40},
        {7'h2,8'h40},
        {7'h13,8'he7},
        {7'h4f,8'h80},
        {7'h50,8'h80},
        {7'h51,8'h0},
        {7'h52,8'h22},
        {7'h53,8'h5e},
        {7'h54,8'h80},
        {7'h58,8'h9e},
        {7'h41,8'h8},
        {7'h3f,8'h0},
        {7'h75,8'h3},
        {7'h76,8'he1},
        {7'h4c,8'h0},
        {7'h77,8'h0},
        {7'h3d,8'hc2},
        {7'h4b,8'h9},
        {7'hc9,8'h60},
        {7'h41,8'h38},
        {7'h56,8'h3a},
        {7'h34,8'h11},
        {7'h3b,8'h0a},
        {7'ha4,8'h88},
        {7'h96,8'h0},
        {7'h97,8'h30},
        {7'h98,8'h20},
        {7'h99,8'h30},
        {7'h9a,8'h84},
        {7'h9b,8'h29},
        {7'h9c,8'h3},
        {7'h9d,8'h98},
        {7'h9e,8'h3f},
        {7'h78,8'h4},
        {7'h79,8'h1},
        {7'hc8,8'hf0},
        {7'h79,8'hf},
        {7'hc8,8'h0},
        {7'h79,8'h10},
        {7'hc8,8'h7e},
        {7'h79,8'h0a},
        {7'hc8,8'h80},
        {7'h79,8'hb},
        {7'hc8,8'h1},
        {7'h79,8'hc},
        {7'hc8,8'hf},
        {7'h79,8'hd},
        {7'hc8,8'h20},
        {7'h79,8'h9},
        {7'hc8,8'h80},
        {7'h79,8'h2},
        {7'hc8,8'hc0},
        {7'h79,8'h3},
        {7'hc8,8'h40},
        {7'h79,8'h5},
        {7'hc8,8'h30},
        {7'h79,8'h26},
        {7'h2d,8'h0},
        {7'h2e,8'h0},
        {7'h11,8'h40},
        {7'h6b,8'h0a},
        {7'h2a,8'h0},
        {7'h2b,8'h0},
        {7'h2d,8'h0},
        {7'h2e,8'h0},
        {7'hca,8'h0},
        {7'h92,8'h66},
        {7'h93,8'h0},
        {7'h3b,8'h0a},
        {7'hcf,8'h8c},
        {7'h9d,8'h98},
        {7'h9e,8'h7f},
        {7'ha5,8'h2},
        {7'hab,8'h3},
        {7'h15,8'h2},
        {7'h12,8'h14},
        {7'h8c,8'h0},
        {7'h4,8'h0},
        {7'h40,8'h10},
        {7'h14,8'h48},
        {7'h4f,8'hb3},
        {7'h50,8'hb3},
        {7'h51,8'h0},
        {7'h52,8'h3d},
        {7'h53,8'ha7},
        {7'h54,8'he4},
        {7'h3d,8'hc0},
        {7'h15,8'h2}
    };

reg [3:0] state = INIT;
reg [14:0] i_addr_data;
reg cmd;
reg cmd_counter=0;
reg strobe = 0;
wire [2:0] i2c_status;
wire ready;
wire clk_10;
reg xclk_en = 0;
wire uart_tx_ready;
reg uart_data_en = 0;

reg [7:0] data_buffer [1024];
reg [9:0] buffer_write_index = 0;
reg [9:0] buffer_read_index = 0;

clk_divider divider(
        .clk_in (clk_100),
        .clk_out(clk_10)
    );

assign xclk = xclk_en & clk_10;

i2c_master cam_config(
    .i_addr_data(i_addr_data),		// Address and Data
    .i_cmd(cmd),            // Command (r/w)
    .i_strobe(strobe),            // Latch inputs
    .i_clk(xclk),
    .io_sda(sda),
    .io_scl(scl),
    //output reg [7:0] o_data,        // Output data on reads
    .o_status(i2c_status),        // Request status
    .o_ready(ready)
);

    /// command sender
    always  @ (posedge clk_100) begin
    	case (state)
            INIT: begin
                // todo: introcude a delay here and wait for pclk
                // before moving to the next state
                xclk_en <= 1;
                state <= SEND_CONFIG;
            end

            SEND_CONFIG:
                if (cmd_counter >= config_length) begin
                    state <= CAMERA_READY;
                end else if (ready) begin
                    i_addr_data <= qvga_config[cmd_counter];
                    cmd_counter <= cmd_counter+1;
                    strobe      <= 1;
    	        end else if (strobe) begin
                    strobe      <= 0;
                end

            CAMERA_READY:begin
                if (click)
                    state <= BUFFERING_PHOTO;
            end

            /// Syncronization between the sender of the commands and the buffer
            /// the command sender needs tp wait for the buffering to complete 
            /// to go back to the initial state.
            /// We introduce two state here so the command sender can detect if 
            /// the buffer was ever started before going back to the init case.
            /// We are trying to avoid the possibility that the command returns back 
            /// to the initial state before the buffering takes place.
            BUFFERING_PHOTO:
                if (buffering_photo_state == BUFFER_WAITING_VSYNC) begin 
                    state <= BUFFERING_IN_PROGRESS;
                end 

            BUFFERING_IN_PROGRESS:
            if (buffering_photo_state == BUFFER_INIT) begin 
                    state <= INIT;
                end  

        endcase
    end

    parameter BUFFER_INIT = 0;
    parameter BUFFER_WAITING_VSYNC = 1;
    parameter BUFFER_WAITING_HSYNC = 2;
    parameter BUFFER_BUFFERING = 3;

    reg [3:0] buffering_photo_state = BUFFER_WAITING_VSYNC;
    // Buffering the data
    always @(posedge pclk) begin
        if (state == BUFFERING_PHOTO)

            case (buffering_photo_state)
                BUFFER_INIT: begin
                    buffering_photo_state <= BUFFER_WAITING_VSYNC;
                end
                BUFFER_WAITING_VSYNC: begin
                    if (vsync)
                        buffering_photo_state <= BUFFER_WAITING_HSYNC;
                end
                BUFFER_WAITING_HSYNC: begin
                    if (hsync)
                        buffering_photo_state <= BUFFER_BUFFERING;
                end
                BUFFER_BUFFERING:
                    if (vsync) begin
                        buffering_photo_state <= BUFFER_INIT;
                    end
                    else begin
                        buffer_write_index = buffer_write_index + 1;
                        data_buffer[buffer_write_index] = data;
                    end
            endcase
    end

    uart_tx uart_tx(
        .clk(clk_100),
        .rst(rst),
        .dout(ftdi_tx),
        .data_in(data_buffer[buffer_read_index]),
        .en(uart_data_en),
        .rdy(uart_tx_ready)
    );

    // sending data to uart
    always @(posedge clk_100) begin
        if (uart_tx_ready && buffer_read_index != buffer_write_index) begin
            buffer_read_index = buffer_read_index + 1;
            uart_data_en = 1;
        end

        if (!uart_tx_ready && uart_data_en) begin // pulsing uart_data_en
            uart_data_en = 0;
        end

    end



endmodule

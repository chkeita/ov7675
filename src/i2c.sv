// Author: Nekrasov A.
// UHF Radiosystems (c)
// Created: 19.4.2018

`define SIMULATION
module i2c #(
	parameter integer PRESCALER = 10, 
	parameter integer BYTES_W  = 3,  // expected byte count for write operation
	parameter integer BYTES_R  = 2   // expected byte count to read 
)
(
	input  wire clk,
	input  wire rst,

	inout  wire SDA,
	output wire SCL,

	input  wire [BYTES_W-1:0][7:0] din,  // input data
	input  wire [7:0]              ain,  // 7-bit slave address
	input  wire                    opcode, // 1 = read, 0 = write
	input  wire                    ptr_set, // 1 to set pointer only
	input  wire                    vin,
	output wire [BYTES_R-1:0][7:0] dout,
	output wire                    vout,
	output wire                    busy
);

parameter integer PRESCALER_HALF = integer'(PRESCALER/2);

typedef enum logic [2:0] {
	IDLE_S,
	START_S,
	TX_S,
	ACK_S_S,
	ACK_M_S,
	RX_S,
	STOP_S
} FSM_t;

FSM_t FSM;

logic SCL_r;
logic SDA_r;
logic SDA_oe;
logic SCL_oe;
logic scl_pos;
logic scl_neg;
logic error;
logic [7:0] dts;
logic [7:0] rd;
logic [3:0] bit_ctr;
logic [3:0] byte_ctr;

logic [$clog2(PRESCALER)-1:0] ctr;

always @ (posedge clk) begin
	if (rst) ctr <= 0;
	else ctr <= (ctr == PRESCALER-1 || vin) ? 0 : ctr + 1;
end

assign scl_pos = (ctr == PRESCALER-1);
assign scl_neg = (ctr == PRESCALER_HALF-1);

always @ (posedge clk) begin
	if (rst) SCL_r <= 1;
	else begin
		if (ctr == PRESCALER-1 && FSM != START_S) SCL_r <= 1;
		if (ctr == PRESCALER_HALF-1) SCL_r <= 0;
	end
end
assign SCL = (SCL_oe) ? SCL_r : 1'bz; 
assign SDA = (SDA_oe) ? SDA_r : 1'bz;

assign busy = (FSM != IDLE_S);

always @ (posedge clk) begin
	if (rst) begin
		FSM      <= IDLE_S;
		dts      <= 0;
		vout     <= 0;
		dout     <= 0;
		rd       <= 0;
		bit_ctr  <= 0;
		byte_ctr <= 0;
		SDA_oe   <= 0;
		SDA_r    <= 0;
		SCL_oe   <= 0;
		error    <= 0;
	end
	else begin
		case (FSM)
			IDLE_S : begin
				SCL_oe   <= 0;
				SDA_oe   <= 0;
				byte_ctr <= 0;
				bit_ctr <= 0;

				if (vin) begin
					dts    <= {ain[6:0], opcode};
					FSM    <= START_S;
				end
			end
			START_S : begin
				if (scl_neg) begin
					SDA_oe <= 1;
					SDA_r  <= 0;
				end
				if (scl_pos) begin
					FSM    <= TX_S;
					SCL_oe <= 1;
				end
			end
			TX_S : begin
				if (scl_neg) begin
					dts[7:1] <= dts[6:0];
					SDA_r    <= dts[7];
					bit_ctr  <= bit_ctr + 1;
				end
				if (bit_ctr == 9) begin
					byte_ctr <= byte_ctr + 1;
					FSM      <= ACK_S_S;
					SDA_oe   <= 0;
				end
				else SDA_oe <= 1;
			end
			ACK_S_S : begin // Slave ack
				bit_ctr <= (opcode) ? 0 : 1;
				if (scl_pos) begin 
					dts <= din[BYTES_W-byte_ctr];
				end
				if (scl_neg) begin
					SDA_r  <= (byte_ctr == BYTES_W + 1) ? 0 : dts[7];
					dts[7:1] <= dts[6:0];
					FSM    <= (opcode) ? RX_S : (byte_ctr == BYTES_W + 1 || (byte_ctr == 2 && ptr_set )) ? STOP_S : TX_S;
					SDA_oe <= (opcode) ? 0 : 1;
				end
			end
			RX_S : begin
				vout   <= 0;
				SDA_oe <= 0;
				if (scl_pos) begin
					rd[0]   <= SDA;
					rd[7:1] <= rd[6:0];
					bit_ctr <= bit_ctr + 1;
				end
				if (bit_ctr == 8 && scl_neg) begin
					SDA_oe           <= 1;
					SDA_r            <= (byte_ctr == BYTES_R) ? 1 : 0;
					FSM              <= ACK_M_S;
					dout[BYTES_R-byte_ctr] <= rd;
				end
			end
			ACK_M_S : begin 
				bit_ctr <= 0;
				if (scl_neg) begin
					if (byte_ctr == BYTES_R) vout <= 1;
					byte_ctr <= byte_ctr + 1;
					FSM <= (byte_ctr == BYTES_R) ? STOP_S : RX_S;
				end
			end
			STOP_S : begin
				vout <= 0;
				if (scl_neg) begin
					SCL_oe <= 0;
					SDA_r  <= 0;
					FSM <= IDLE_S;
				end
			end
		endcase
	end
end

endmodule
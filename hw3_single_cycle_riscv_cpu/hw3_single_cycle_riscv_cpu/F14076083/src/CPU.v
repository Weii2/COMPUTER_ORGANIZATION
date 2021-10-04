// Please include verilog file if you write module in other file

module CPU(
    input	clk,
    input	rst,
    output reg	instr_read,
    output reg [31:0]	instr_addr,
    input [31:0]	instr_out,
    output reg	data_read,
    output reg [3:0]	data_write,
    output reg [31:0]	data_addr,
    output reg [31:0]	data_in,
    input [31:0]	data_out
);

reg [31:0]	RegFile[31:0];
reg [31:0]	PC;
reg [6:0]	opcode,funct7,imm_bL,imm_sL;
reg [4:0]	rs1,rs2,rd,imm_bR,imm_sR;
reg [2:0]	cycle,funct3;
reg [11:0]	imm_i;
reg [19:0]	imm_u;

initial begin
	instr_read <= 1'd0;
	instr_addr <= 32'd0;
	data_read <= 1'd0;
	data_write <= 4'b0000;
	data_addr <= 32'd0;
	data_in <= 32'd0;
	RegFile[0] <= 32'd0;
	PC <= 32'd0;
	cycle <= 3'd0;
end

always @ (posedge clk or posedge rst)
begin
	if(!rst)begin
		case(cycle)
		3'd0:begin
			RegFile[0] <= 32'd0;
			instr_read <= 1'd1;
			instr_addr <= PC;
			cycle <= 3'd1;
		end
		3'd1:begin
			cycle <= 3'd2;
		end
		3'd2:begin
			PC <= PC+32'd4;
			instr_read <= 1'd0;
			opcode <= instr_out[6:0];
			
			case(instr_out[6:0])
			7'b0110011:begin
				funct7 <= instr_out[31:25];
				rs2 <= instr_out[24:20];
				rs1 <= instr_out[19:15];
				funct3 <= instr_out[14:12];
				rd <= instr_out[11:7];
			end
			7'b0000011:begin
				imm_i <= instr_out[31:20];
				rs1 <= instr_out[19:15];
				funct3 <= instr_out[14:12];
				rd <= instr_out[11:7];
			end
			7'b0010011:begin
				imm_i <= instr_out[31:20];
				rs1 <= instr_out[19:15];
				funct3 <= instr_out[14:12];
				rd <= instr_out[11:7];
			end
			7'b1100111:begin
				imm_i <= instr_out[31:20];
				rs1 <= instr_out[19:15];
				funct3 <= instr_out[14:12];
				rd <= instr_out[11:7];
			end
			7'b0100011:begin
				imm_sL <= instr_out[31:25];
				rs2 <= instr_out[24:20];
				rs1 <= instr_out[19:15];
				funct3 <= instr_out[14:12];
				imm_sR <= instr_out[11:7];
			end
			7'b1100011:begin
				imm_bL <= instr_out[31:25];
				rs2 <= instr_out[24:20];
				rs1 <= instr_out[19:15];
				funct3 <= instr_out[14:12];
				imm_bR <= instr_out[11:7];
			end
			7'b0010111:begin
				imm_u <= instr_out[31:12];
				rd <= instr_out[11:7];
			end
			7'b0110111:begin
				imm_u <= instr_out[31:12];
				rd <= instr_out[11:7];
			end
			7'b1101111:begin
				imm_u <= instr_out[31:12];
				rd <= instr_out[11:7];
			end	
			endcase
			cycle <= 3'd3;
		end
		3'd3:begin
			case(opcode)
			7'b0110011:begin
				case(funct3)
				3'b000:begin
					if(funct7==7'b0000000)
					RegFile[rd] <= RegFile[rs1] + RegFile[rs2];
					else if(funct7==7'b0100000)
					RegFile[rd] <= RegFile[rs1] - RegFile[rs2];
				end
				3'b001:
					RegFile[rd] <= RegFile[rs1] << RegFile[rs2][4:0];
				3'b010:
					RegFile[rd] <= ($signed(RegFile[rs1]) < $signed(RegFile[rs2]))
										?32'd1:32'd0;
				3'b011:
					RegFile[rd] <= (RegFile[rs1] < RegFile[rs2])?32'd1:32'd0;
				3'b100:
					RegFile[rd] <= RegFile[rs1] ^ RegFile[rs2];
				3'b101:begin
					if(funct7==7'b0000000)
						RegFile[rd] <= RegFile[rs1] >> RegFile[rs2][4:0];
					else if(funct7==7'b0100000)
						RegFile[rd] <= $signed(RegFile[rs1]) >>> RegFile[rs2][4:0];
				end
				3'b110:
					RegFile[rd] <= RegFile[rs1] | RegFile[rs2];
				3'b111:
					RegFile[rd] <= RegFile[rs1] & RegFile[rs2];
				endcase
			end
			7'b0000011:begin
				data_read <= 1'b1;
				data_addr <= RegFile[rs1] + {{20{imm_i[11]}},imm_i};
			end
			7'b0010011:begin
				case(funct3)
				3'b000:
					RegFile[rd] <= RegFile[rs1] + {{20{imm_i[11]}},imm_i};
				3'b001:
					RegFile[rd] <= RegFile[rs1] << imm_i[4:0];
				3'b010:
					RegFile[rd] <= ($signed(RegFile[rs1]) < $signed({{20{imm_i[11]}},imm_i}))
										? 32'd1:32'd0;
				3'b011:
					RegFile[rd] <= (RegFile[rs1] < {{20{imm_i[11]}},imm_i})
										? 32'd1:32'd0;
				3'b100:
					RegFile[rd] <= RegFile[rs1] ^ {{20{imm_i[11]}},imm_i};
				3'b101:begin
					if(imm_i[11:5]==7'd0)
						RegFile[rd] <= RegFile[rs1] >> imm_i[4:0];
					else if(imm_i[11:5]==7'b0100000)
						RegFile[rd] <= $signed(RegFile[rs1]) >>> imm_i[4:0];
				end
				3'b110:
					RegFile[rd] <= RegFile[rs1] | {{20{imm_i[11]}},imm_i};
				3'b111:
					RegFile[rd] <= RegFile[rs1] & {{20{imm_i[11]}},imm_i};
				endcase
			end
			7'b1100111:begin
				RegFile[rd] <= PC;
				PC <= RegFile[rs1] + {{20{imm_i[11]}},imm_i};
			end
			7'b0100011:begin
				data_addr = RegFile[rs1] + {{20{imm_sL[6]}},imm_sL,imm_sR};
				case(funct3)
				3'b010:begin
					data_write<=4'b1111;
					data_in <= RegFile[rs2];
				end
				3'b000:begin
					case(data_addr[1:0])
					2'b00:begin
						data_write<=4'b0001;
						data_in[7:0]<=RegFile[rs2][7:0];
					end
					2'b01:begin
						data_write<=4'b0010;
						data_in[15:8]<=RegFile[rs2][7:0];
					end
					2'b10:begin
						data_write<=4'b0100;
						data_in[23:16]<=RegFile[rs2][7:0];
					end
					2'b11:begin
						data_write<=4'b1000;
						data_in[31:24]<=RegFile[rs2][7:0];
					end
					endcase
				end
				3'b001:begin
				
					case(data_addr[1:0])
					2'b00:begin
						data_write<=4'b0011;
						data_in[15:0]<=RegFile[rs2][15:0];
					end
					2'b01:begin
						data_write<=4'b0011;
						data_in[15:0]<=RegFile[rs2][15:0];
					end
					2'b10:begin
						data_write<=4'b1100;
						data_in[31:16]<=RegFile[rs2][15:0];
					end
					2'b11:begin
						data_write<=4'b1100;
						data_in[31:16]<=RegFile[rs2][15:0];
					end
					endcase
				end
				endcase
			end
			7'b1100011:begin
				case(funct3)
				3'b000:
					PC <= (RegFile[rs1]==RegFile[rs2])?PC + {{19{imm_bL[6]}},imm_bL[6],
							imm_bR[0],imm_bL[5:0],imm_bR[4:1],1'd0} -32'd4:PC;
				3'b001:
					PC <= (RegFile[rs1]!=RegFile[rs2])?PC + {{19{imm_bL[6]}},imm_bL[6],
							imm_bR[0],imm_bL[5:0],imm_bR[4:1],1'd0} -32'd4:PC;
				3'b100:
					PC <= ($signed(RegFile[rs1])<$signed(RegFile[rs2]))?PC + 
							{{19{imm_bL[6]}},imm_bL[6],imm_bR[0],imm_bL[5:0],imm_bR[4:1],1'd0} -32'd4:PC;
				3'b101:
					PC <= ($signed(RegFile[rs1])>=$signed(RegFile[rs2]))?PC + 
							{{19{imm_bL[6]}},imm_bL[6],imm_bR[0],imm_bL[5:0],imm_bR[4:1],1'd0} -32'd4:PC;
				3'b110:
					PC <= (RegFile[rs1]<RegFile[rs2])?PC + {{19{imm_bL[6]}},imm_bL[6],
							imm_bR[0],imm_bL[5:0],imm_bR[4:1],1'd0} -32'd4:PC;
				3'b111:
					PC <= (RegFile[rs1]>=RegFile[rs2])?PC + {{19{imm_bL[6]}},imm_bL[6],
							imm_bR[0],imm_bL[5:0],imm_bR[4:1],1'd0} -32'd4:PC;
				endcase
			end
			7'b0010111:
				RegFile[rd] <= PC+{imm_u,12'd0}-32'd4;
			7'b0110111:
				RegFile[rd] <= {imm_u,12'd0};
			7'b1101111:begin
				RegFile[rd] <= PC;
				PC <= PC + {{11{imm_u[19]}},imm_u[19],imm_u[7:0],imm_u[8],imm_u[18:9],1'd0}
						 - 32'd4;
			end
			endcase
			cycle <= 3'd4;
		end
		3'd4:begin
			cycle <= 3'd5;
		end
		3'd5:begin
			case(opcode)
			7'b0000011:begin
				data_read <= 1'b0;
				case(funct3)
				3'b010:
					RegFile[rd] <= data_out;
				3'b000:
					RegFile[rd] <= {{24{data_out[7]}},data_out[7:0]};
				3'b001:
					RegFile[rd] <= {{16{data_out[15]}},data_out[15:0]};
				3'b100:
					RegFile[rd] <= {{24{1'b0}},data_out[7:0]};
				3'b101:
					RegFile[rd] <= {{16{1'b0}},data_out[15:0]};
				endcase
			end
			7'b0100011:
				data_write <= 4'b0000;
			endcase
			cycle <= 3'd0;		
		end
		endcase	
	end
end

endmodule

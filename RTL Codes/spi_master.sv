module spi_master (
    input logic clk,
    input logic rst,
    input logic start,
    input logic [47:0] write_data,
    input logic miso,
    output logic mosi,
    output logic sclk,
    output logic [47:0] read_data,
    output logic cs_n,
    output logic done
);

    typedef enum logic [1:0] {IDLE, TRANSFER, DONE} state_t;
    state_t state;

    logic [47:0] shift_reg_in, shift_reg_out;
    logic [5:0] bit_cnt;
    logic sclk_reg;

    assign sclk = sclk_reg;
    assign cs_n = (state == IDLE);
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            sclk_reg <= 0;
            bit_cnt <= 0;
            mosi <= 0;
            done <= 0;
            shift_reg_in <= 0;
            shift_reg_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    sclk_reg <= 0;
                    if (start) begin
                        shift_reg_out <= write_data;
                        shift_reg_in <= 0;
                        bit_cnt <= 0;
                        state <= TRANSFER;
                    end
                end
                TRANSFER: begin
                    sclk_reg <= ~sclk_reg;
                    if (!sclk_reg) begin
                        mosi <= shift_reg_out[47];
                        shift_reg_out <= {shift_reg_out[46:0], 1'b0};
                    end else begin
                        shift_reg_in <= {shift_reg_in[46:0], miso};
                        bit_cnt <= bit_cnt + 1;
                        if (bit_cnt == 47) begin
                            state <= DONE;
                            read_data <= {shift_reg_in[46:0], miso};
                            done <= 1;
                        end
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

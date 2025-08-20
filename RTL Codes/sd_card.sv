module sd_card (
    input logic clk,
    input logic rst,
    input logic cs_n,
    input logic sclk,
    input logic mosi,
    output logic miso,
    input logic [47:0] write_cmd_in,
    input logic write_cmd_valid,
    output logic [47:0] write_response_out,
    output logic write_response_valid,
    input logic [47:0] write_data_in,
    input logic write_data_valid,
    output logic [47:0] write_data_response_out,
    output logic write_data_response_valid
);

    typedef enum logic [3:0] {WAIT, RECEIVE, RESPOND, SEND_TOKEN, SEND_DATA, 
                              WRITE_RECEIVE_DATA} state_t;
    state_t state;

    logic [47:0] shift_reg;
    logic [5:0] bit_cnt;
    logic [47:0] full_response;
    logic [5:0] resp_bit_cnt;
    logic sclk_prev;
    logic send_data;
    logic [47:0] last_cmd;
    logic [2:0] r1_cnt;
    logic [2:0] token_cnt;
    logic [7:0] data_token;
    logic is_cmd17;
    logic is_cmd24;

    logic [5:0] r1_pad_cnt;
    logic [5:0] token_pad_cnt;
    logic [47:0] r1_shift_out;
    logic [47:0] token_shift_out;

    localparam BLOCK_WORDS = 1;
    logic [47:0] mem [0:BLOCK_WORDS-1];
    logic [5:0] data_bit_cnt;
    logic [47:0] data_shift_out;
    logic read_active;

    logic [47:0] write_data_reg;
    logic write_active;

    initial begin
        mem[0] = 48'hDEADBEEF1234;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= WAIT;
            shift_reg <= 0;
            bit_cnt <= 0;
            miso <= 1;
            full_response <= 48'h000000000001;
            resp_bit_cnt <= 0;
            sclk_prev <= 0;
            data_bit_cnt <= 0;
            data_shift_out <= 0;
            read_active <= 0;
            write_active <= 0;
            send_data <= 0;
            last_cmd <= 0;
            r1_cnt <= 0;
            token_cnt <= 0;
            data_token <= 8'hFE;
            is_cmd17 <= 0;
            is_cmd24 <= 0;
            r1_pad_cnt <= 0;
            token_pad_cnt <= 0;
            r1_shift_out <= 48'hFFFFFFFFFFFF;
            token_shift_out <= 48'hFFFFFFFFFFFF;
            write_data_reg <= 0;
            write_response_out <= 0;
            write_response_valid <= 0;
            write_data_response_out <= 0;
            write_data_response_valid <= 0;
        end else begin
            sclk_prev <= sclk;
            
            if (write_response_valid) begin
                write_response_valid <= 0;
            end
            if (write_data_response_valid) begin
                write_data_response_valid <= 0;
            end
            
            case (state)
                WAIT: begin
                    miso <= 1;
                    send_data <= 0;
                    read_active <= 0;
                    write_active <= 0;
                    is_cmd17 <= 0;
                    is_cmd24 <= 0;
                    
                    if (write_cmd_valid) begin
                        last_cmd <= write_cmd_in;
                        unique case (write_cmd_in)
                            48'h5800000000FF: begin
                                full_response <= 48'h000000000000;
                                is_cmd24 <= 1;
                                write_active <= 1;
                                write_response_out <= 48'h000000000000;
                                write_response_valid <= 1;
                                state <= WRITE_RECEIVE_DATA;
                            end
                            default: begin
                                full_response <= 48'hFFFFFFFFFFFF;
                                is_cmd24 <= 0;
                                write_response_out <= 48'hFFFFFFFFFFFF;
                                write_response_valid <= 1;
                                state <= WAIT;
                            end
                        endcase
                    end else if (!cs_n) begin
                        state <= RECEIVE;
                        bit_cnt <= 0;
                        shift_reg <= 0;
                    end
                end
                RECEIVE: begin
                    if (!cs_n && sclk && !sclk_prev) begin
                        shift_reg <= {shift_reg[46:0], mosi};
                        bit_cnt <= bit_cnt + 1;
                        if (bit_cnt == 47) begin
                            last_cmd <= {shift_reg[46:0], mosi};
                            unique case ({shift_reg[46:0], mosi})
                                48'h400000000095: begin
                                    full_response <= 48'h000000000001;
                                    is_cmd17 <= 0;
                                end
                                48'h48000001AA87: begin
                                    full_response <= 48'h00000001AA87;
                                    is_cmd17 <= 0;
                                end
                                48'h770000000065: begin
                                    full_response <= 48'h000000000001;
                                    is_cmd17 <= 0;
                                end
                                48'h694000000077: begin
                                    full_response <= 48'h000000000000;
                                    is_cmd17 <= 0;
                                end
                                48'h7A00000000FD: begin
                                    full_response <= 48'h00FF80000000;
                                    is_cmd17 <= 0;
                                end
                                48'h5100000000FF: begin
                                    full_response <= 48'h000000000000;
                                    send_data <= 1;
                                    read_active <= 1;
                                    is_cmd17 <= 1;
                                end
                                default: begin
                                    full_response <= 48'hFFFFFFFFFFFF;
                                    is_cmd17 <= 0;
                                end
                            endcase
                            resp_bit_cnt <= 0;
                            r1_cnt <= 0;
                            r1_pad_cnt <= 0;
                            token_cnt <= 0;
                            token_pad_cnt <= 0;
                            state <= RESPOND;
                        end
                    end
                end
                RESPOND: begin
                    if (!cs_n && !sclk && sclk_prev) begin
                        if (is_cmd17) begin
                            if (r1_pad_cnt < 8) begin
                                miso <= full_response[7 - r1_pad_cnt];
                            end else begin
                                miso <= 1'b0;
                            end
                            r1_pad_cnt <= r1_pad_cnt + 1;
                            if (r1_pad_cnt == 47) begin
                                state <= SEND_TOKEN;
                                token_pad_cnt <= 0;
                            end
                        end else begin
                            miso <= full_response[47 - resp_bit_cnt];
                            resp_bit_cnt <= resp_bit_cnt + 1;
                            if (resp_bit_cnt == 47) begin
                                state <= WAIT;
                            end
                        end
                    end
                end
                SEND_TOKEN: begin
                    if (!cs_n && !sclk && sclk_prev) begin
                        if (token_pad_cnt < 40) begin
                            miso <= 1'b0;
                        end else begin
                            miso <= data_token[7 - (token_pad_cnt - 40)];
                        end
                        token_pad_cnt <= token_pad_cnt + 1;
                        if (token_pad_cnt == 47) begin
                            state <= SEND_DATA;
                            data_bit_cnt <= 0;
                            data_shift_out <= mem[0];
                        end
                    end
                end
                SEND_DATA: begin
                    if (!cs_n && !sclk && sclk_prev) begin
                        miso <= data_shift_out[47];
                        data_shift_out <= {data_shift_out[46:0], 1'b0};
                        data_bit_cnt <= data_bit_cnt + 1;
                        if (data_bit_cnt == 47) begin
                            state <= WAIT;
                        end
                    end
                end
                WRITE_RECEIVE_DATA: begin
                    if (write_data_valid) begin
                        write_data_reg <= write_data_in;
                        mem[0] <= write_data_in;
                        write_data_response_out <= 48'h000000000005;
                        write_data_response_valid <= 1;
                        state <= WAIT;
                    end
                end
            endcase
        end
    end
endmodule

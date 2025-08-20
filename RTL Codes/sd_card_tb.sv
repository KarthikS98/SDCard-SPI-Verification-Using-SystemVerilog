`timescale 1ns/1ps

module sd_card_tb;

    logic clk, rst, start;
    logic mosi, miso, sclk, cs_n;
    logic [47:0] write_data, read_data;
    logic done;

    logic [47:0] resp[0:9];

    logic [47:0] write_cmd_in;
    logic write_cmd_valid;
    logic [47:0] write_response_out;
    logic write_response_valid;
    logic [47:0] write_data_in;
    logic write_data_valid;
    logic [47:0] write_data_response_out;
    logic write_data_response_valid;

    logic [47:0] response;
    int resp_idx;

    spi_master master (
        .clk(clk), .rst(rst), .start(start),
        .write_data(write_data), .miso(miso),
        .mosi(mosi), .sclk(sclk), .cs_n(cs_n),
        .read_data(read_data), .done(done)
    );

    sd_card card (
        .clk(clk), .rst(rst), .cs_n(cs_n),
        .sclk(sclk), .mosi(mosi), .miso(miso),
        .write_cmd_in(write_cmd_in),
        .write_cmd_valid(write_cmd_valid),
        .write_response_out(write_response_out),
        .write_response_valid(write_response_valid),
        .write_data_in(write_data_in),
        .write_data_valid(write_data_valid),
        .write_data_response_out(write_data_response_out),
        .write_data_response_valid(write_data_response_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; start = 0;
        write_data = 48'h000000000000;
        write_cmd_valid = 0;
        write_data_valid = 0;
        response = 48'hFFFFFFFFFFFF;
        resp_idx = -1;
        #20 rst = 0;

        #100;
        
        
        
        write_data = 48'h5800000000FF; //Modify to simulate different commands



        if (write_data == 48'h5100000000FF) begin
            start = 1; #10; start = 0;
            wait(done);
            $display("CMD sent: %012h", write_data);
            
            for (int i = 0; i < 10; i++) begin
                write_data = 48'hFFFFFFFFFFFF;
                start = 1; #10; start = 0;
                wait(done);
                resp[i] = read_data;
            end
            $display("R1 response: %012h", resp[2]);
            $display("Token:      %012h", resp[5]);
            $display("Data block: %012h", resp[8]);
            
            
        end else if (write_data == 48'h5800000000FF) begin
            $display("=== WRITE VERIFICATION SEQUENCE ===");
            $display("Step 1: Reading original data...");
            write_data = 48'h5100000000FF;
            start = 1; #10; start = 0;
            wait(done);
            $display("CMD sent: %012h", write_data);
            
            for (int i = 0; i < 10; i++) begin
                write_data = 48'hFFFFFFFFFFFF;
                start = 1; #10; start = 0;
                wait(done);
                resp[i] = read_data;
            end
            $display("R1 response: %012h", resp[2]);
            $display("Token:      %012h", resp[5]);
            $display("Data block: %012h", resp[8]);
            
            $display("................................................................");
            
            #50;
            rst = 1; #10; rst = 0; #10;
            
            $display("Step 2: Writing new data...");
            $display("CMD sent: %012h", 48'h5800000000FF);
            write_cmd_in = 48'h5800000000FF;
            write_cmd_valid = 1; #10; write_cmd_valid = 0;
            
            @(posedge clk);
            while (!write_response_valid) @(posedge clk);
            $display("Response received: %012h", write_response_out);
            
            $display("Data token: %012h", 48'h0000000000FE);
            write_data_in = 48'hCAFEBABE5678;
            $display("Data block: %012h", write_data_in);
            write_data_valid = 1; #10; write_data_valid = 0;
            
            @(posedge clk);
            while (!write_data_response_valid) @(posedge clk);
            $display("Write response: %012h", write_data_response_out);
            
            $display("................................................................");
            
            #50;
            
            $display("Step 3: Reading data after write...");
            write_data = 48'h5100000000FF;
            start = 1; #10; start = 0;
            wait(done);
            $display("CMD sent: %012h", write_data);
            
            for (int i = 0; i < 10; i++) begin
                write_data = 48'hFFFFFFFFFFFF;
                start = 1; #10; start = 0;
                wait(done);
                resp[i] = read_data;
            end
            $display("R1 response: %012h", resp[2]);
            $display("Token:      %012h", resp[5]);
            $display("Data block: %012h", resp[8]);
            $display("=== WRITE VERIFICATION COMPLETE ===");
            
            
            
        end else begin
            start = 1; #10; start = 0;
            wait(done);
            $display("CMD sent: %012h", write_data);
            
            response = 48'hFFFFFFFFFFFF;
            resp_idx = -1;
            for (int i = 0; i < 4; i++) begin
                write_data = 48'hFFFFFFFFFFFF;
                start = 1; #10; start = 0;
                wait(done);
                if (response == 48'hFFFFFFFFFFFF && read_data != 48'hFFFFFFFFFFFF) begin
                    response = read_data;
                    resp_idx = i+1;
                end
            end
            if (resp_idx != -1) begin
                $display("Response received: %012h", response);
            end else begin
                $display("No valid response received (all dummies were 0xFFFFFFFFFFFF)");
            end
        end

        #100;
        $finish;
    end
endmodule

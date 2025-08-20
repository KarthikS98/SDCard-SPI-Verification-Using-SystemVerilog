`timescale 1ns / 1ps

module spi_master_tb;
    logic clk;
    logic rst;
    logic start;
    logic [47:0] write_data;
    logic [47:0] read_data;
    logic done;
    logic sclk;
    logic mosi;
    logic miso;
    logic cs_n;

    spi_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .write_data(write_data),
        .read_data(read_data),
        .done(done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    logic [47:0] slave_response = 48'h123456789ABC;
    logic [47:0] slave_shift_reg;
    logic [5:0] slave_bit_count;
    logic use_slave_response;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            slave_shift_reg <= slave_response;
            slave_bit_count <= 0;
        end else if (!cs_n && sclk && use_slave_response) begin
            slave_shift_reg <= {slave_shift_reg[46:0], 1'b0};
            slave_bit_count <= slave_bit_count + 1;
        end else if (cs_n) begin
            slave_shift_reg <= slave_response;
            slave_bit_count <= 0;
        end
    end
    
    assign miso = use_slave_response ? ((!cs_n) ? slave_shift_reg[47] : 1'b1) : mosi;

    initial begin
        rst = 1;
        start = 0;
        write_data = 48'h400000000095;
        use_slave_response = 0;
        #20;
        
        rst = 0;
        #20;
        
        $display("=== TEST 1: SPI Loopback ===");
        write_data = 48'h400000000095;
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Transfer complete:");
        $display("  Data sent: %012h", write_data);
        $display("  Data received: %012h", read_data);
        
        if (write_data == read_data) begin
            $display("  SUCCESS: Loopback working correctly!");
        end else begin
            $display("  ERROR: Loopback failed!");
        end
        
        #50;
        
        $display("=== TEST 2: Slave Response ===");
        use_slave_response = 1;
        write_data = 48'h5100000000FF;
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Transfer complete:");
        $display("  Data sent: %012h", write_data);
        $display("  Data received: %012h", read_data);
        $display("  Expected response: %012h", slave_response);
        
        if (read_data == slave_response) begin
            $display("  SUCCESS: Slave response working correctly!");
        end else begin
            $display("  ERROR: Slave response failed!");
        end
        
        $display("SPI Master test completed!");
        $finish;
    end
endmodule

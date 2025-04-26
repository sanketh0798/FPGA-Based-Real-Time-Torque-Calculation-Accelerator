`timescale 1 ns / 1 ps

module TorqCalc_IP_v1_0_S00_AXI #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)(
    input wire  S_AXI_ACLK,
    input wire  S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire  S_AXI_AWVALID,
    output reg  S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire  S_AXI_WVALID,
    output reg  S_AXI_WREADY,
    output reg [1 : 0] S_AXI_BRESP,
    output reg  S_AXI_BVALID,
    input wire  S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire  S_AXI_ARVALID,
    output reg  S_AXI_ARREADY,
    output reg [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output reg [1 : 0] S_AXI_RRESP,
    output reg  S_AXI_RVALID,
    input wire  S_AXI_RREADY
);

    // Internal registers for write address and read address
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;

    // User registers
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    // Write address ready
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            S_AXI_AWREADY <= 1'b0;
        else if (!S_AXI_AWREADY && S_AXI_AWVALID && S_AXI_WVALID)
            S_AXI_AWREADY <= 1'b1;
        else
            S_AXI_AWREADY <= 1'b0;
    end

    // Write address latch
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            axi_awaddr <= 0;
        else if (S_AXI_AWREADY && S_AXI_AWVALID)
            axi_awaddr <= S_AXI_AWADDR;
    end

    // Write data ready
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            S_AXI_WREADY <= 1'b0;
        else if (!S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWVALID)
            S_AXI_WREADY <= 1'b1;
        else
            S_AXI_WREADY <= 1'b0;
    end

    // Write logic
    wire write_enable = S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWREADY && S_AXI_AWVALID;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else if (write_enable) begin
            case (axi_awaddr[3:2])
                2'b00: slv_reg0 <= S_AXI_WDATA;
                2'b01: slv_reg1 <= S_AXI_WDATA;
                2'b10: slv_reg2 <= S_AXI_WDATA;
                2'b11: slv_reg3 <= S_AXI_WDATA;
            endcase
        end
    end

    // Write response logic
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_BVALID <= 0;
            S_AXI_BRESP <= 2'b00;
        end else if (S_AXI_AWREADY && S_AXI_AWVALID && !S_AXI_BVALID && S_AXI_WREADY && S_AXI_WVALID) begin
            S_AXI_BVALID <= 1'b1;
            S_AXI_BRESP <= 2'b00; // OKAY response
        end else if (S_AXI_BREADY && S_AXI_BVALID) begin
            S_AXI_BVALID <= 1'b0;
        end
    end

    // Read address ready
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            S_AXI_ARREADY <= 1'b0;
        else if (!S_AXI_ARREADY && S_AXI_ARVALID)
            S_AXI_ARREADY <= 1'b1;
        else
            S_AXI_ARREADY <= 1'b0;
    end

    // Read address latch
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            axi_araddr <= 0;
        else if (S_AXI_ARREADY && S_AXI_ARVALID)
            axi_araddr <= S_AXI_ARADDR;
    end

    // Read data valid and data
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_RVALID <= 0;
            S_AXI_RRESP <= 2'b00;
            S_AXI_RDATA <= 0;
        end else if (S_AXI_ARREADY && S_AXI_ARVALID && !S_AXI_RVALID) begin
            S_AXI_RVALID <= 1'b1;
            S_AXI_RRESP <= 2'b00; // OKAY response
            case (axi_araddr[3:2])
                2'b00: S_AXI_RDATA <= slv_reg0;
                2'b01: S_AXI_RDATA <= slv_reg1;
                2'b10: S_AXI_RDATA <= slv_reg2;
                2'b11: S_AXI_RDATA <= slv_reg3;
                default: S_AXI_RDATA <= 0;
            endcase
        end else if (S_AXI_RVALID && S_AXI_RREADY) begin
            S_AXI_RVALID <= 1'b0;
        end
    end

endmodule

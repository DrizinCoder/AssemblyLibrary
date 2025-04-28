module AXI_Slave_Interface (
    // Clock e Reset
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,
    
    // AXI4-Lite Write Address Channel
    input wire [31:0] S_AXI_AWADDR,
    input wire S_AXI_AWVALID,
    output wire S_AXI_AWREADY,
    
    // AXI4-Lite Write Data Channel
    input wire [31:0] S_AXI_WDATA,
    input wire [3:0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output wire S_AXI_WREADY,
    
    // AXI4-Lite Write Response Channel
    output wire [1:0] S_AXI_BRESP,
    output wire S_AXI_BVALID,
    input wire S_AXI_BREADY,
    
    // AXI4-Lite Read Address Channel
    input wire [31:0] S_AXI_ARADDR,
    input wire S_AXI_ARVALID,
    output wire S_AXI_ARREADY,
    
    // AXI4-Lite Read Data Channel
    output wire [31:0] S_AXI_RDATA,
    output wire [1:0] S_AXI_RRESP,
    output wire S_AXI_RVALID,
    input wire S_AXI_RREADY,
    
    // Interface com o módulo somador
    output wire [7:0] Num1,
    output wire [7:0] Num2,
    input wire [7:0] res
);

// Registradores internos
reg [7:0] reg_num1;
reg [7:0] reg_num2;
reg [7:0] reg_result;

// Sinais de controle AXI
reg awready;
reg wready;
reg bvalid;
reg arready;
reg rvalid;
reg [31:0] rdata;

// Atribuições de saída
assign Num1 = reg_num1;
assign Num2 = reg_num2;
assign S_AXI_AWREADY = awready;
assign S_AXI_WREADY = wready;
assign S_AXI_BRESP = 2'b00; // OKAY response
assign S_AXI_BVALID = bvalid;
assign S_AXI_ARREADY = arready;
assign S_AXI_RDATA = rdata;
assign S_AXI_RRESP = 2'b00; // OKAY response
assign S_AXI_RVALID = rvalid;

// Lógica de escrita
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        reg_num1 <= 8'b0;
        reg_num2 <= 8'b0;
        awready <= 1'b0;
        wready <= 1'b0;
        bvalid <= 1'b0;
    end else begin
        // Handshake de escrita no canal de endereço
        if (S_AXI_AWVALID && !awready) begin
            awready <= 1'b1;
        end else begin
            awready <= 1'b0;
        end
        
        // Handshake de escrita no canal de dados
        if (S_AXI_WVALID && !wready) begin
            wready <= 1'b1;
        end else begin
            wready <= 1'b0;
        end
        
        // Escrevendo nos registradores
        if (S_AXI_AWVALID && S_AXI_AWREADY && S_AXI_WVALID && S_AXI_WREADY) begin
            case (S_AXI_AWADDR[3:0])
                4'h0: reg_num1 <= S_AXI_WDATA[7:0];
                4'h4: reg_num2 <= S_AXI_WDATA[7:0];
                default: ; // Nada a fazer
            endcase
            bvalid <= 1'b1;
        end else if (S_AXI_BVALID && S_AXI_BREADY) begin
            bvalid <= 1'b0;
        end
    end
end

// Lógica de leitura
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        reg_result <= 8'b0;
        arready <= 1'b0;
        rvalid <= 1'b0;
        rdata <= 32'b0;
    end else begin
        reg_result <= res; // Atualiza o resultado do somador
        // Handshake de leitura no canal de endereço
        if (S_AXI_ARVALID && !arready) begin
            arready <= 1'b1;
        end else begin
            arready <= 1'b0;
        end
        
        // Lendo dos registradores
        if (S_AXI_ARVALID && S_AXI_ARREADY) begin
            case (S_AXI_ARADDR[3:0])
                4'h0: rdata <= {24'b0, reg_num1};
                4'h4: rdata <= {24'b0, reg_num2};
                4'h8: rdata <= {24'b0, reg_result};
                default: rdata <= 32'b0;
            endcase
            rvalid <= 1'b1;
        end else if (S_AXI_RVALID && S_AXI_RREADY) begin
            rvalid <= 1'b0;
        end
    end
end

endmodule
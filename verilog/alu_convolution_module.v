module alu_convolution_module (
  input wire [199:0] A_flat,        
  input wire [199:0] B_flat,        
  output wire signed [7:0] C_flat,  
  output wire overflow_flag       
);
  // --- Estágio 1: Multiplicação ---
  wire signed [15:0] products [0:24];

  // --- Estágio 2: Extração de Elementos e Multiplicação ---
  genvar i;
  generate
    for (i = 0; i < 25; i = i + 1) begin : convolution_elements_inst
      wire signed [7:0] kernel_val;
      wire signed [7:0] image_val;

      // Extrai o i-ésimo elemento do kernel e da região da imagem
      assign kernel_val = A_flat[(i*8) +: 8];
      assign image_val  = B_flat[(i*8) +: 8];

      // Realiza a multiplicação para cada par de elementos
      assign products[i] = kernel_val * image_val;
    end
  endgenerate

  // --- Estágio 3: Soma dos Produtos (Acumulação) ---
  wire signed [20:0] full_sum;

  integer j;
  reg signed [20:0] temp_sum_combinational;
  always @(*) begin
    temp_sum_combinational = 21'sd0; // Inicializa com zero
    for (j = 0; j < 25; j = j + 1) begin
      temp_sum_combinational = temp_sum_combinational + products[j];
    end
  end
  assign full_sum = temp_sum_combinational;

  // --- Detecção de Overflow antes do Clamping ---
  assign overflow_flag = (full_sum < 21'sd0) || (full_sum > 21'sd127);

  // --- Estágio 4: Clamping (Saturação) do Resultado ---
  reg signed [7:0] temp_clamped_result;
  always @(*) begin
    if (full_sum >= 21'sd127) begin // Comparar com o valor de 21 bits
      temp_clamped_result = 8'sd127; // 127 com sinal
    end else if (full_sum <= 21'sd0) begin // Comparar com o valor de 21 bits
      temp_clamped_result = 8'sd0;   // 0 com sinal
    end else begin
      // Para 0 < full_sum < 127, o valor é o próprio full_sum.
      temp_clamped_result = full_sum[7:0]; 
    end
  end
  assign C_flat = temp_clamped_result;

endmodule

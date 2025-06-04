module alu_subtraction_module(
  input [199:0] A_flat,         // Matriz A achatada (25 elementos de 8 bits)
  input [199:0] B_flat,         // Matriz B achatada (25 elementos de 8 bits)
  input clk,                    // Clock para controle sequencial
  input reset,                  // Reset assíncrono
  input start,                  // Sinal para iniciar operação
  output reg [7:0] result,      // Resultado final da convolução (8 bits com saturação)
  output reg overflow_flag,     // Sinal de overflow: ativo se houve saturação
  output reg done               // Sinal indicando fim da operação
);

  // Produtos parciais (cada multiplicação pode gerar até 16 bits)
  wire signed [15:0] products [24:0];
 
  // Soma acumulada (precisa comportar a soma de 25 produtos de 16 bits)
  reg signed [20:0] accumulator; // 21 bits para comportar soma de 25 elementos de 16 bits
 
  // Contador para controle sequencial
  reg [4:0] counter;
 
  // Estados da máquina de estados
  reg [1:0] state;
  parameter IDLE = 2'b00;
  parameter MULTIPLY = 2'b01;
  parameter ACCUMULATE = 2'b10;
  parameter SATURATE = 2'b11;

  // Geração dos produtos usando generate
  genvar i;
  generate
    for (i = 0; i < 25; i = i + 1) begin : gen_products
      // Extrai o i-ésimo elemento da matriz A e B como números com sinal
      wire signed [7:0] a_val = A_flat[(i*8) +: 8];
      wire signed [7:0] b_val = B_flat[(i*8) +: 8];
     
      // Multiplica A[i] * B[i] (resultado em 16 bits)
      assign products[i] = a_val * b_val;
    end
  endgenerate

  // Máquina de estados para controle da operação
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      counter <= 0;
      accumulator <= 0;
      overflow_flag <= 0;
      done <= 0;
    end
    else begin
      case (state)
        IDLE: begin
          if (start) begin
            state <= MULTIPLY;
            counter <= 0;
            accumulator <= 0;
            overflow_flag <= 0;
            done <= 0;
          end
        end
       
        MULTIPLY: begin
          // Transição direta para acumulação (produtos já estão disponíveis)
          state <= ACCUMULATE;
        end
       
        ACCUMULATE: begin
          if (counter < 25) begin
            // Soma produto atual ao acumulador
            accumulator <= accumulator + products[counter];
            counter <= counter + 1;
          end
          else begin
            state <= SATURATE;
          end
        end
       
        SATURATE: begin
          // Aplica saturação ao resultado final
          if (accumulator > 255) begin
            result <= 8'd255;      // Satura em 255
            overflow_flag <= 1;
          end else if (accumulator < 0) begin
result <= 8'd0;
overflow_flag <= 1;
end else begin
            result <= accumulator[7:0]; // Sem saturação
            overflow_flag <= 0;
          end
         
          done <= 1;
          state <= IDLE;
        end
       
        default: state <= IDLE;
      endcase
    end
  end

endmodule
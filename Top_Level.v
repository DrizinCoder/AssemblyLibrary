module Top_Level (
    input clk
);

    wire [7:0] n1;
    wire [7:0] n2;
    wire [7:0] result;

    // Instancia o sistema gerado pelo Qsys
    adders u0 (
        .clk_clk(clk),
        .axi_slave_interface_0_adder_interface_new_signal(n1),
        .axi_slave_interface_0_adder_interface_new_signal_1(n2),
        .axi_slave_interface_0_adder_interface_new_signal_2(result)
    );

    // Instancia o somador
    Sum adder (
        .Num1(n1),
        .Num2(n2),
        .res(result)
    );

endmodule

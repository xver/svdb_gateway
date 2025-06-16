#include "Vtest_registers.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtest_registers* top = new Vtest_registers;

    // Initialize clock
    top->clk_i = 0;

    // Run simulation
    while (!Verilated::gotFinish()) {
        top->clk_i = !top->clk_i;
        top->eval();
    }

    // Cleanup
    delete top;
    return 0;
}
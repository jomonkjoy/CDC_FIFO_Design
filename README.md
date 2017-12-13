# CDC_FIFO_Design
Multi-clock Clock Domain Crossing (CDC) & FIFO Design Techniques using SystemVerilog 

## Closed loop solution - sampling signals with synchronizers
A second potential solution to this problem is to send an enabling control signal, synchronize it into the new clock domain and then pass the synchronized signal back through another synchronizer to the sending clock domain as an acknowledge signal.
#### Advantage: 
synchronizing a feedback signal is a very safe technique to acknowledge that the first control signal was recognized and sampled into the new clock domain.
#### Disadvantage: 
there is potentially considerable delay associated with synchronizing control signals in both directions before allowing the control signal to change.

### Closed-loop - MCP formulation with acknowledge feedback
### Multi-bit CDC signal passing using 1-deep / 2-register FIFO synchronize
FIFO is built using only two registers or a 2-deep dual port RAM, the gray code counters used to detect full and empty are simple toggle flip-flops, which is really nothing more than 1-bit binary counters.

### Reference : http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf

# CIVIC-FIFO

🚀 Ready/Valid FIFO + Round-Robin Merge (SystemVerilog)

Single-clock, synchronous-reset design
A parameterized, single-clock, synchronous-reset design and synthesizable FIFO with ready/valid handshaking, plus a fair round-robin merge fabric that combines multiple input streams into one output.

Designed to look simple, behave correctly, and scale cleanly.


N input streams
      │
      ▼
┌──────────┐
│ FIFO[0]  │
├──────────┤
│ FIFO[1]  │──► Round-Robin Arbiter ──► Output Stream
├──────────┤
│ FIFO[2]  │
├──────────┤
│ FIFO[3]  │
└──────────┘

Each input gets its own FIFO, preventing head-of-line blocking.
A round-robin arbiter guarantees fairness when multiple FIFOs have data.




# Core FIFO (fifo_rv)
Interface (Ready / Valid)

in_valid   ──►  FIFO  ──► out_valid
in_ready   ◄──         ◄── out_ready

Push when in_valid && in_ready

Pop when out_valid && out_ready

Push and pop can happen in the same cycle



# FIFO Internals (Visualized)


DEPTH = 8

mem[]:
+---+---+---+---+---+---+---+---+
| D | E | F | . | . | A | B | C |
+---+---+---+---+---+---+---+---+
          ↑               ↑
        wr_ptr          rd_ptr

count = 6

wr_ptr wraps naturally (circular buffer)

rd_ptr advances only on successful read

count tracks occupancy exactly




⏱ Cycle-by-Cycle Example

Cycle:        0   1   2   3
in_valid:     1   1   0   0
in_ready:     1   1   1   1
out_ready:    0   1   1   1
--------------------------------
Action:     push push pop pop
count:        1   2   1   0

FIFO stays fully decoupled between producer and consumer.



#🎯 Round-Robin Arbiter (rr_arb)

Problem
Multiple FIFOs want to send data at the same time.

Solution
Rotate priority every successful transfer.


🔁 Rotation Visualization
req      = 1011
ptr      = 2

req_dbl  = 10111011
req_rot  = 00101110   (shifted by ptr)
             ↑
         first '1' wins
Grant index:
grant_idx = ptr + rot_idx

Pointer only advances when a grant is accepted:
if (grant_any && grant_accept)
  ptr <= grant_idx + 1'b1;
  
  ✔ Fair
  ✔ Starvation-free
  ✔ O(N) simple logic


         


✅ Design Highlights

✔ Fully synthesizable SystemVerilog

✔ Clean ready/valid semantics

✔ Correct simultaneous push/pop

✔ Fair arbitration

✔ Modular & reusable


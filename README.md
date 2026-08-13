# 4x4 Packet Router in SystemVerilog

A synthesizable **4-input, 4-output packet router** implemented in SystemVerilog and verified using a layered, class-based verification environment.

The router supports variable-length packets, destination-based routing, fixed-priority output arbitration, valid-ready flow control, independent output backpressure, reset recovery, self-checking scoreboarding, and functional coverage.

## Project Highlights

- Four input ports and four output ports
- Destination-based packet routing
- Variable packet lengths from 1 to 15 payload beats
- SOP, EOP, `valid`, and `ready` signaling
- One complete-packet buffer per input port
- Fixed-priority arbitration when multiple inputs target the same output
- Independent output backpressure support
- Reset and post-reset recovery
- Packet-ID-based expected-versus-actual scoreboarding
- Transaction-level functional coverage
- Directed, constrained-random, contention, reset, and backpressure testing

## Packet Format

Each packet consists of one 32-bit header beat followed by one or more 32-bit payload beats.

| Header bits | Field | Description |
| --- | --- | --- |
| `[31:30]` | Destination | Requested output port, 0 through 3 |
| `[29:28]` | Source | Input port, 0 through 3 |
| `[27:24]` | Length | Number of payload beats, 1 through 15 |
| `[23:16]` | Packet ID | Unique packet identifier used by the scoreboard |
| `[15:14]` | Priority | Packet priority, 0 through 3 |
| `[13:0]` | Reserved | Reserved bits, driven to zero |

### Example packet

```text
Header
Payload[0]
Payload[1]
...
Payload[length - 1]
```

- `SOP` is asserted with the header beat.
- `EOP` is asserted with the final payload beat.
- A beat transfers only when both `valid` and `ready` are asserted.

## Router Architecture

Each input port has a packet buffer and an input-side finite-state machine:

- `EMPTY`: ready to accept a new header
- `RECEIVING`: accepting payload beats
- `FULL`: complete packet is buffered and awaiting transmission

Each output port has an output-side finite-state machine:

- `OUT_IDLE`: searching for a buffered packet targeting the output
- `OUT_SEND`: presenting packet beats until the final beat is accepted

When multiple input ports target the same output, the router uses fixed-priority arbitration:

```text
Input 0 > Input 1 > Input 2 > Input 3
```

The selected packet is transmitted completely before another packet is selected for that output.

## Valid-Ready Backpressure

Output data transfers only when:

```text
out_valid && out_ready
```

If `out_valid` is high while `out_ready` is low, the receiver is applying backpressure. During this stall, the router holds the current output beat and packet-boundary signals until the receiver becomes ready.

The verification environment supports these output-ready modes:

- `ALWAYS_READY`
- `RANDOM_READY`
- `BURST_STALL`
- `PER_PORT_PATTERN`

## Verification Architecture

The project uses a layered, non-UVM, class-based SystemVerilog testbench.

```text
Packet Generator
       |
       v
  Input Driver
       |
       v
      DUT
     /   \
    v     v
 Input   Output
Monitor  Monitor
    |      | \
    |      |  +--> Coverage Collector
    |      |
    +------+----> Scoreboard
```

### Verification components

- **`packet_trans`**: packet transaction model, constraints, copy, compare, and summary methods
- **`packet_generator`**: creates directed and constrained-random packet traffic
- **`input_driver`**: drives complete packets onto four independent input ports
- **`output_ready_driver`**: creates normal and backpressured output-ready behavior
- **`input_monitor`**: reconstructs packets accepted by the DUT as expected transactions
- **`output_monitor`**: reconstructs packets transmitted by the DUT as actual transactions
- **`router_scoreboard`**: matches expected and actual packets by packet ID
- **`packet_coverage`**: samples completed routed packets and reports functional coverage
- **`router_env`**: creates and starts the verification components
- **`base_test`**: provides the shared environment for derived tests

## Scoreboard

The scoreboard stores expected packets in an associative array indexed by `packID`.

For each actual output packet, the scoreboard:

1. Finds the expected packet with the same packet ID.
2. Compares the header fields.
3. Compares the payload length and payload contents.
4. Confirms the observed output port matches the packet destination.
5. Updates pass, fail, unexpected, and missing-packet counts.

A passing test requires:

- Zero failed comparisons
- Zero unexpected packets
- Zero unmatched expected packets
- Equal expected and actual packet counts

## Test Suite

### 1. Directed single-packet test

Sends one packet with a known header, source, destination, and payload. Verifies exact end-to-end packet behavior.

### 2. Randomized packet test

Generates multiple constrained-random packets across all input ports with random destinations, lengths, priorities, and payload data.

### 3. All-routes test

Exercises all 16 source-to-destination combinations:

```text
4 input ports x 4 output ports = 16 routes
```

### 4. Contention test

Sends packets from all four input ports to the same output port and verifies that all packets are serialized without loss, corruption, or interleaving.

### 5. Reset-recovery test

1. Sends and verifies a pre-reset packet batch.
2. Asserts reset.
3. Clears verification synchronization state and pending stimulus.
4. Deasserts reset.
5. Sends a new packet batch.
6. Verifies correct post-reset routing.

### 6. Backpressure test

Verifies packet integrity and forward progress with:

- Burst stalls
- Random ready behavior
- Independent per-port ready patterns

## Functional Coverage

The coverage collector samples completed output packets.

Coverage points include:

- Source port
- Destination port
- Packet-length category
- Packet priority
- Source x destination cross

Packet-length bins are grouped as:

- Minimum: length 1
- Normal: lengths 2 through 14
- Maximum: length 15

The all-routes test targets 100% coverage of the 16-bin source x destination cross.

## Representative Results

The completed verification suite has demonstrated:

- Correct directed packet routing
- Correct constrained-random packet routing
- All 16 source-to-destination paths
- Four-input contention to a common output
- Reset and post-reset recovery
- Burst, random, and per-port backpressure
- Zero missing or unexpected packets in passing tests
- Functional coverage collection on completed output packets

Example passing scoreboard report:

```text
========== ROUTER SCOREBOARD REPORT ==========
Expected packets received: 12
Actual packets received:   12
Packets passed:            12
Packets failed:             0
Unexpected packets:         0
Missing packets:            0

TEST PASSED
==============================================
```

Example coverage report:

```text
========== PACKET COVERAGE REPORT ==========
Overall packet coverage:            78.33%
Source coverage:                    100.00%
Destination coverage:                75.00%
Length coverage:                     66.67%
Priority coverage:                  100.00%
Source x destination coverage:       50.00%
============================================
```

Coverage varies by test. Aggregate regression coverage is more meaningful than requiring every individual test to cover every functional bin.

## Repository Structure

```text
systemverilog-packet-router/
├── rtl/
│   └── packet_router.sv
├── tb/
│   ├── router_if.sv
│   ├── packet_trans.sv
│   ├── packet_generator.sv
│   ├── input_driver.sv
│   ├── output_ready_driver.sv
│   ├── input_monitor.sv
│   ├── output_monitor.sv
│   ├── router_scoreboard.sv
│   ├── packet_coverage.sv
│   ├── router_env.sv
│   └── base_test.sv
├── tests/
│   ├── direct_smoke_test.sv
│   ├── random_smoke_test.sv
│   ├── possible_routes_test.sv
│   ├── contention_test.sv
│   ├── reset_test.sv
│   └── backpressure_test.sv
├── sim/
│   ├── design.sv
│   └── testbench.sv
├── README.md
```

## Running the Project

The project was developed and tested with **Synopsys VCS** using **EDA Playground**.

EDA Playground project:

```text
https://www.edaplayground.com/x/YZx9
```

### Test selection

The current `testbench.sv` uses separate test invocations. Enable exactly one test at a time and leave the other test invocations disabled.

Available test classes:

```text
direct_smoke_test
random_smoke_test
possible_routes_test
contention_test
reset_test
backpressure_test
```

For the backpressure test, select the desired ready mode in `backpressure_test.sv`:

```text
ALWAYS_READY
RANDOM_READY
BURST_STALL
PER_PORT_PATTERN
```

### EDA Playground

1. Upload the files or open the shared playground.
2. Select SystemVerilog as the language.
3. Select Synopsys VCS as the simulator.
4. Enable exactly one test invocation in `testbench.sv`.
5. Run the simulation.
6. Review the scoreboard and coverage reports in the output log.

## Design and Verification Notes

- The router buffers one complete packet per input port.
- Output arbitration is fixed priority rather than round robin.
- The scoreboard matches packets by packet ID, allowing packets targeting different outputs to complete in different global orders.
- Coverage is sampled from completed output transactions, proving that covered packet scenarios were successfully routed.
- Output backpressure affects transmission timing but must not affect packet contents.

## Possible Future Enhancements

- Mid-packet reset testing
- SystemVerilog Assertions for valid-ready stability
- Exact fixed-priority arbitration-order checking
- Backpressure stall-cycle coverage
- Larger constrained-random regressions
- Round-robin output arbitration
- Parameterized port count and buffer depth
- UVM migration

## Author

Madhavenshu Dayal

## License

This project is available under the MIT License. See `LICENSE` for details.

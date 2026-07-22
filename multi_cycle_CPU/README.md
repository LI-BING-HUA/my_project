# Multicycle RISC-V CPU (RV32I)

用 Verilog 從零實作的多週期 RISC-V 處理器，支援完整 RV32I 整數指令集。
本專案是繼單週期 CPU 之後的重刻版本，重點在理解「為什麼多週期能用更少的硬體」，
以及為之後的 pipeline 版本鋪路。

---

## 為什麼做多週期（設計動機）

單週期 CPU 一個 cycle 把一條指令從頭做到尾，缺點是：

- 需要**兩個 memory**（instruction memory + data memory），因為 fetch 和 load/store 在同一個 cycle 發生，不能共用。
- 需要**多個加法器**（PC+4 一個、branch target 一個、ALU 運算一個），因為它們在同一個 cycle 同時要算。

多週期的核心思想：**把一條指令拆成多個 cycle，每個 cycle 只做一件事**。
好處是同一個硬體單元在不同 cycle 可以做不同的事（時間多工），因此：

- **一個 memory 就夠**。
- **一個 ALU 就夠**。

---

## 關鍵設計原理

### 1. 一個 ALU 可以身兼多職

多週期把工作拆到不同 cycle，而**ALU 不是每個 cycle 都在忙**。

| Cycle | ALU 在算什麼 |
|-------|-------------|
| Fetch | PC + 4（此時指令還沒 decode，ALU 閒著，剛好拿來算下一條位址） |
| Decode | branch/jal 目標位址（OldPC + imm，先算好備用） |
| Execute | 真正的運算（add/sub/and/slt…） |
| Memory | load/store 的記憶體位址（rs1 + imm） |

靠 **SrcA / SrcB mux** 在每個 cycle 選不同的輸入餵給 ALU，就能一機多用。
單週期做不到，是因為它一個 cycle 要把全部算完，ALU 同時只能做一件事。

### 2. 為什麼需要中間暫存器（IR / MDR / A / B / ALUOut）？

- **IR**：存抓到的指令，接下來幾個 cycle 都要靠它 decode。
- **MDR**：存 memory 讀出的資料，等下個 cycle 寫回暫存器。
- **A / B**：存 rs1 / rs2 的值，從 decode 保留到 execute。
- **ALUOut**：存 ALU 的結果，從 execute 保留到 writeback。

### 3. 為什麼有些暫存器要 enable、有些不用？

- **要 enable（PC、OldPC、IR）**：這些在「一條指令的多個 cycle 內」不該一直變。
  例如 PC 一條指令只該更新一次（Fetch 時變成下一條位址），但一條指令有好幾個 cycle，
  所以需要 `PCWrite` 訊號控制「只有該更新的那個 cycle 才准變，其他 cycle 按兵不動」。
  如果 PC 每個 cycle 都被覆蓋，一條指令跑完 PC 會暴衝好幾條，程式直接亂掉。
- **不用 enable（MDR、A、B、ALUOut）**：這些存的是「這個 cycle 剛算出的東西」，
  本來就該每個 cycle 反映最新計算，即時更新才正確。

---

## 目標指令集：RV32I（37 條）

| 類型 | 指令 | 數量 |
|------|------|:---:|
| R-type | add, sub, sll, slt, sltu, xor, srl, sra, or, and | 10 |
| I-type (ALU) | addi, slti, sltiu, xori, ori, andi, slli, srli, srai | 9 |
| I-type (load) | lb, lh, lw, lbu, lhu | 5 |
| I-type (jump) | jalr | 1 |
| S-type | sb, sh, sw | 3 |
| B-type | beq, bne, blt, bge, bltu, bgeu | 6 |
| U-type | lui, auipc | 2 |
| J-type | jal | 1 |

---

## 開發原則

- 介面與功能照 Harris《Digital Design and Computer Architecture, RISC-V Edition》，
  但每個設計決策都自己想過「為什麼這樣接、有沒有別的做法」，寫進本文件。
- 零件先各自寫好、獨立測試，再組裝。
- 先求功能正確，再考慮面積/時序優化。

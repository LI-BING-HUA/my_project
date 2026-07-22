# Single-Cycle RISC-V CPU (RV32I)

用 Verilog 實作的單週期 RISC-V 處理器，支援完整 RV32I 整數指令集，
並實際燒錄到 **Basys3 FPGA** 上，透過按鈕單步執行、七段顯示器觀察暫存器內容。

> **Demo 影片**：[▶ 點此觀看單週期 CPU 解說](https://youtu.be/9Hdb3MZU1DQ)
>
> [![單週期 CPU 解說](https://img.youtube.com/vi/9Hdb3MZU1DQ/0.jpg)](https://youtu.be/9Hdb3MZU1DQ)

---

## 特色

- **完整 RV32I 指令集**：R-type、I-type（ALU / load）、S-type、B-type、U-type、J-type，共 9 種 opcode。
- **完整的 branch 家族**：beq / bne / blt / bge / bltu / bgeu 六種，用 funct3 分流判斷。
- **完整的 load/store 寬度**：lb / lh / lw / lbu / lhu、sb / sh / sw，含符號延伸與 byte lane 選擇。
- **自己刻的 CLA 加法器**：4-bit carry-lookahead adder（generate / propagate），非直接用 `+`。
- **FPGA 上板驗證**：Basys3，按鈕單步執行（step）、七段顯示器即時顯示指定暫存器的值。

---

## 架構總覽

單週期：**一條指令在一個 clock cycle 內從 fetch 到 writeback 全部完成**。
資料路徑（datapath）與控制單元（control unit）分離。

架構圖:![alt text](image.png)

圖中可見：
- **上半部（粉紅）為 Control Unit**：Main Decoder 依 opcode 產生控制訊號與 `alu_op`，
  ALU Decoder 再依 `alu_op` + funct3 + funct7[5] 產生 `alu_control`；
  `branch_taken` 由 funct3 選擇 `zero` 或 `alu_result[0]`，與 branch/jump/jalr 一起決定 `PCSrc`。
- **下半部（橘）為 Datapath**：PC → Instruction Memory → Register File → ALU → Data Memory → Load Unit → 寫回，
  中間穿插 SrcA / SrcB / Result / PCSrc 各級多工器。

---

## 模組說明

### 頂層

| 模組 | 說明 |
|------|------|
| `top_basys3.v` | FPGA 頂層。接按鈕去彈跳 → 產生單步脈衝 → 驅動 CPU → 把暫存器值轉 BCD 送七段顯示。 |
| `single_cycle_CPU.v` | CPU 本體，把所有 datapath 零件與 control unit 接起來。 |

### Datapath

| 模組 | 功能 | 設計重點 |
|------|------|---------|
| `Point_Counter.v` | 程式計數器 (PC) | `rst` 清零；`step` 為 1 才更新，配合 FPGA 單步執行。 |
| `Instruction_Memory.v` | 指令記憶體 | 組合讀出（`mem[addr>>2]`）；測試程式寫在 `initial` 裡。 |
| `Register_File.v` | 暫存器堆 (32×32) | 2 讀 1 寫；x0 恆 0；另有 debug 讀埠 (`a_dbg`/`rd_dbg`) 供七段顯示查看任一暫存器。 |
| `Extend.v` | 立即數產生器 | 依 `imm_src` 產生 I/S/B/U/J 五種格式，B/J 位元重排、最低位補 0。 |
| `ALU.v` | 算術邏輯單元 | 10 種運算，`alu_control` 4-bit。 |
| `Data_Memory.v` | 資料記憶體 | 同步寫、組合讀；store 依 funct3 支援 sb/sh/sw 的 byte lane 寫入。 |
| `Load_Unit.v` | 載入延伸單元 | 把記憶體讀出的 word 依 funct3 + 位址低 2 位，做符號/零延伸並選對 byte/half。 |
| `PCPlus4.v` | 算 PC+4 | 循序執行的下一條位址。 |
| `PCTarget.v` | 算 branch/jal 目標 | PC + imm_ext。 |
| `mux2.v` / `mux3.v` | 多工器 | datapath 各處的選擇器。 |

### Control Unit

| 模組 | 功能 |
|------|------|
| `Control_Unit.v` | 控制單元頂層，內含主解碼器 + ALU 解碼器，並產生 `PCSrc`（分支/跳躍判斷）。 |
| `Main_Decoder.v` | 主解碼器：依 opcode 產生所有控制訊號（RegWrite / ALUSrc / MemWrite / ResultSrc / ImmSrc / ALUOp 等）。 |
| `ALU_Decoder.v` | ALU 解碼器：依 ALUOp + funct3 + funct7[5] 決定 ALU 要做哪種運算。 |

### 自刻 CLA 加法器

| 模組 | 功能 |
|------|------|
| `CLA4.v` | 4-bit carry-lookahead adder，由 4 個 full adder + 進位產生邏輯組成。 |
| `CLG.v` | Carry-Lookahead Generator：用 generate/propagate 平行算出各級進位。 |
| `FA.v` / `FA_2.v` | Full Adder，同時輸出 sum 與 generate/propagate 訊號。 |

### FPGA 週邊

| 模組 | 功能 |
|------|------|
| `BTN_DEB.v` | 按鈕彈跳消除 (debounce)。 |
| `Pulse_GEN.v` | 邊緣偵測，把持續的按鈕訊號轉成「一次一個 cycle」的單步脈衝。 |
| `BtoBCD.v` / `BCDADD.v` / `ADD6.v` | 二進位轉 BCD（double dabble），供七段顯示十進位。 |
| `seven_seg.v` | 七段顯示器掃描驅動。 |

---

## 關鍵設計決策

### 1. 控制訊號分兩層解碼（Main Decoder + ALU Decoder）

不用一個大 case 硬解全部，而是分成：
- **Main Decoder**：看 opcode，決定資料流向（要不要寫暫存器、ALU 第二輸入選 imm 還是 rs2、
  結果從哪來…）以及一個抽象的 `ALUOp`（2-bit）。
- **ALU Decoder**：看 `ALUOp` + funct3 + funct7[5]，決定 ALU 的實際運算。

`ALUOp` 的意義：`00` = 直接加（load/store 算位址、auipc/lui）、`01` = 減（此設計中預留）、
`10` = 看 funct（R-type / I-arith）、`11` = branch 家族。
好處是 R-type 和 I-arith 可以共用同一段 funct3 解碼邏輯，只差在 R-type 的 sub/sra 要看 funct7[5]、
而 I-arith 沒有 sub（`addi` 不看 funct7）。

### 2. Branch 家族用 funct3 + ALU 結果判斷

MIPS 只有 beq/bne，但這裡實作了完整六種。做法：branch 時 ALU 依 funct3 做對應運算，
control unit 再看結果決定跳不跳：

| 指令 | funct3 | ALU 做 | 判斷 taken 的條件 |
|------|:------:|--------|------------------|
| beq  | 000 | sub | `zero`（相等） |
| bne  | 001 | sub | `~zero` |
| blt  | 100 | slt（有號） | `alu_result[0]` |
| bge  | 101 | slt（有號） | `~alu_result[0]` |
| bltu | 110 | sltu（無號） | `alu_result[0]` |
| bgeu | 111 | sltu（無號） | `~alu_result[0]` |

最後 `PCSrc` 的優先序：jalr（用 ALU 算出的位址）> jump 或 branch taken（用 PCTarget）> PC+4。

### 3. Load / Store 的對齊處理

- **Store（`Data_Memory`）**：sb/sh 依位址低 2 位，只寫入對應的 byte/half lane，
  不動到同一個 word 的其他位元組。
- **Load（`Load_Unit`）**：先讀出整個 word，再依 funct3 + 位址低 2 位選出要的 byte/half，
  並做符號延伸（lb/lh）或零延伸（lbu/lhu）。lw 直接原樣輸出。

### 4. 自己刻 CLA 而非直接用 `+`

加法器用 4-bit carry-lookahead 手刻（generate/propagate 平行算進位），
而不是直接寫 `A + B` 讓合成器自動生。這是為了理解進位傳播的原理與延遲差異
（ripple carry 要一級一級等，CLA 平行算進位）。

### 5. FPGA 單步執行 + 七段 debug

因為 FPGA 的 clock 太快，肉眼無法觀察每條指令的效果，所以：
- 用按鈕（去彈跳 + 邊緣偵測）產生 **step 脈衝**，一次只讓 PC 前進一條指令。
- Register File 開一個 debug 讀埠，用開關 `SW` 選要看哪個暫存器，值轉 BCD 後用七段顯示。
- 這樣可以一步一步按、一格一格檢查每條指令執行後暫存器的變化，方便上板驗證。

---

## 測試程式

`Instruction_Memory.v` 的 `initial` 內建一段測試程式，依序驗證：

1. **R-type 全部**：add / sub / sll / slt / sltu / xor / srl / sra / or / and
2. **I-arith 全部**：addi / slli / slti / sltiu / xori / srli / srai / ori / andi
3. **Store / Load**：sw → lw、不同 offset
4. **Branch**：beq 相等跳 / 不相等不跳兩種情境
5. **Jump**：jal

執行後用 debug 讀埠逐一檢查各暫存器的值是否符合預期。

---

## 如何執行

### 模擬（simulation）
`sim/` 內含各模組的 testbench（ALU、Extend、Register_File、Load_Unit、
PCPlus4、PC、Instruction_Memory、以及整合的 `single_cycle_CPU_tb`）。
用 Vivado 或 iverilog 跑對應的 testbench 即可。

### 上板（Basys3）
1. 在 Vivado 建立專案，加入 `source/` 所有檔案，頂層設為 `top_basys3`。
2. 加入 Basys3 的 XDC 約束檔（時脈、按鈕、開關、七段顯示腳位）。
3. 合成 → 實作 → 產生 bitstream → 燒錄。
4. 用按鈕單步執行，用開關選暫存器編號，七段顯示器讀值。

---

## 目標指令集：RV32I

| 類型 | 指令 |
|------|------|
| R-type | add, sub, sll, slt, sltu, xor, srl, sra, or, and |
| I-type (ALU) | addi, slti, sltiu, xori, ori, andi, slli, srli, srai |
| I-type (load) | lb, lh, lw, lbu, lhu |
| I-type (jump) | jalr |
| S-type | sb, sh, sw |
| B-type | beq, bne, blt, bge, bltu, bgeu |
| U-type | lui, auipc |
| J-type | jal |

---

## 後續

此單週期版本之後會延伸為 **多週期 (multicycle)** 與 **管線化 (pipeline)** 版本，
探討資源共享（單一 memory / ALU 分 cycle 複用）與 hazard 處理。
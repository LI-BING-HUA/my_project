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

### 4. SLT 用減法器推導，不直接用 `$signed` 比較

直接寫 `$signed(a) < $signed(b)` 會另生一個比較器，跟已有的減法器重複、浪費面積。
真實硬體**重用減法器**：`a < b` 等價於 `a - b < 0`，看減法結果的符號位即可。

但只看符號位會在**溢位時被騙**。例（8-bit）：`-128 - 1`，正確答案 `-128 < 1` 應為 1，
但硬體算出 `1000_0000 - 0000_0001 = 0111_1111`，符號位變 0（看似正）→ 誤判。
原因是 `-129` 超出範圍溢位、符號位翻掉。所以修正為：

```
slt = diff[31] ^ overflow          // 沒溢位信符號位，溢位就翻回來
overflow = (a[31] != b[31]) && (diff[31] != a[31])
```

**SLTU 不需要這套**：無號沒有符號位概念，看減法借位即可，直接比。
有號無號判斷機制不同，這是 RISC-V 把 SLT / SLTU 分成兩條指令的原因。

> 關鍵測資：`SLT(0x80000000, 1)=1` 而 `SLTU(0x80000000, 1)=0`。
> 漏掉 XOR overflow 時 SLT 會算成 0，這組能抓出來。

### 5. Register File：x0 兩邊都擋

寫入時跳過 `A3==0`，讀出時 `A1/A2==0` 強制回 0。
只擋寫的話，未初始化的 `mem[0]` 讀出來會是 x，所以讀也要擋。
讀做組合（同一 cycle 內完成「給位址→拿資料→存進 A/B」）、寫做同步（值整個 cycle 穩定、避免組合迴路）。

### 6. Datapath：ALU 輸出分兩條路

ALU 的輸出同時接 **ALUResult**（直接輸出）與 **ALUOut**（過暫存器），用 Result mux 選：

- **ALUResult**：當場要用，如 Fetch 算 PC+4 要「這個 cycle 就寫回 PC」。
- **ALUOut**：下個 cycle 才用，如 branch 目標先算好存著。

PC 的輸入接 `Result`（與 register writeback 共用同一個 mux 輸出）：
Fetch 時 Result 選 ALUResult（PC+4），branch/jal 時選 ALUOut（目標位址）。
單一 memory 的位址接 AdrSrc mux，fetch 選 PC、load/store 選算好的位址，達成兩用。

---

## 開發進度

- [x] 零件：ALU、Register File、Extend、Memory、中間暫存器
- [x] Datapath 接線 + 手動逐 cycle 驗證（addi 走完 Fetch→Decode→Execute→WriteBack，x1 正確寫回 10）
- [ ] Control FSM（進行中）
- [ ] Load/Store 延伸單元、整合測試

**mux 編碼**：SrcA `00`=PC `01`=OldPC `10`=A｜SrcB `00`=B `01`=Imm `10`=4｜Result `00`=ALUOut `01`=MDR `10`=ALUResult｜Adr `0`=PC `1`=Result

**已知待處理的坑**：jalr 目標要 `& ~1`；auipc 用 OldPC 不是 PC+4；B/J 立即數位元重排；load 延伸單元未接（目前只有 lw 對）。

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

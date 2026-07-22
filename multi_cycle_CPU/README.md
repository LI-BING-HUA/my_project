# Multicycle RISC-V CPU (RV32I)

用 Verilog 從零實作的多週期 RISC-V 處理器，支援完整 RV32I 整數指令集。
本專案是繼單週期 CPU 之後的重刻版本，重點在理解「為什麼多週期能用更少的硬體」，
以及為之後的 pipeline 版本鋪路。

---

## 為什麼做多週期（設計動機）

單週期 CPU 一個 cycle 把一條指令從頭做到尾，缺點是：

- 需要**兩個 memory**（instruction memory + data memory），因為 fetch 和 load/store 在同一個 cycle 發生，不能共用。
- 需要**多個加法器**（PC+4 一個、branch target 一個、ALU 運算一個），因為它們在同一個 cycle 同時要算。
- clock period 被最慢的那條指令（如 `lw`，要走完 fetch→decode→讀暫存器→算位址→讀記憶體→寫回）綁死，所有指令都得等它。

多週期的核心思想：**把一條指令拆成多個 cycle，每個 cycle 只做一件事**。
好處是同一個硬體單元在不同 cycle 可以做不同的事（時間多工），因此：

- **一個 memory 就夠**：fetch 在某個 cycle、load/store 在另一個 cycle，不會撞。
- **一個 ALU 就夠**：不同 cycle 分別算 PC+4、branch target、實際運算、記憶體位址。
- 每條指令用「剛好夠」的 cycle 數（R-type 少、lw 多），不必所有指令都等最慢的。

---

## 關鍵設計原理（面試重點）

### 1. 為什麼一個 ALU 可以身兼多職？

因為多週期把工作拆到不同 cycle，**ALU 不是每個 cycle 都在忙**。
在一條指令的執行過程中，同一個 ALU 被借用來做不同的事：

| Cycle | ALU 在算什麼 |
|-------|-------------|
| Fetch | PC + 4（此時指令還沒 decode，ALU 閒著，剛好拿來算下一條位址） |
| Decode | branch/jal 目標位址（OldPC + imm，先算好備用） |
| Execute | 真正的運算（add/sub/and/slt…） |
| Memory | load/store 的記憶體位址（rs1 + imm） |

靠 **SrcA / SrcB mux** 在每個 cycle 選不同的輸入餵給 ALU，就能一機多用。
單週期做不到，是因為它一個 cycle 要把全部算完，ALU 同時只能做一件事，
所以 PC+4 得另外配一個獨立加法器。

### 2. 為什麼需要中間暫存器（IR / MDR / A / B / ALUOut）？

多週期一條指令拆成多個 cycle，而 **cycle 之間的中間結果會消失**。
例如 Fetch 從 memory 抓出指令，下個 cycle memory 要拿去給 load/store 用，
指令就被沖掉了 —— 所以要用 **IR** 把它留住。其餘同理：

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
  本來就該每個 cycle 反映最新計算，無條件更新反而正確。

### 4. 多週期 vs pipeline 的差別（釐清觀念）

- **多週期**：同一時間**只有一條指令**在機器裡，走完全部 cycle 才換下一條。
  所以不會有「不同指令互相干擾」的問題。
- **pipeline**：多條指令**同時**在不同階段跑（像生產線），
  因此會遇到 hazard（後一條要讀的暫存器前一條還沒寫回）。
  多週期是 pipeline 的前身，FSM 的各狀態之後會「攤平成同時執行」。

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

（不含 M extension 的乘除法；那是獨立模組，之後有餘力再加。）

---

## 已完成的零件

### ALU (`ALU.v`)
- 支援 10 種運算，`alu_control` 為 4-bit。
- SUB 和 SLT **共用同一個減法器**（`diff = SrcA - SrcB`），節省面積。
- 已用 golden model + 10000 組亂數測資驗證通過（含邊界值 0 / -1 / 0x80000000 / 0x7FFFFFFF）。

#### SLT 的設計決策：用減法器推導，不直接用 `$signed` 比較

**做法**：
```
diff     = SrcA - SrcB;
overflow = (SrcA[31] != SrcB[31]) && (diff[31] != SrcA[31]);
slt      = diff[31] ^ overflow;      // 有號小於
sltu     = (SrcA < SrcB);            // 無號小於，直接比
```

**為什麼不直接用 `$signed(SrcA) < $signed(SrcB)`**

直接寫比較運算子雖然功能正確，但有兩個缺點：
1. 合成器會另外生一個比較器電路，**跟已經存在的減法器重複**，浪費面積。
2. 看不出硬體實際怎麼做——這是「照著寫」而非「知道原理」。

真實硬體不會另做比較器，而是**重用減法器**：
`a < b` 等價於 `a - b < 0`，也就是看 `a - b` 的結果是不是負的（看符號位 `diff[31]`）。

**為什麼要 XOR overflow（這是關鍵）**

只看 `diff[31]` 會在**溢位時被騙**。以 8-bit 為例（32-bit 同理）：
```
a = 1000_0000 = -128
b = 0000_0001 = +1
真值：-128 < 1 → 應該是 1

硬體算 a - b：
  1000_0000 - 0000_0001 = 0111_1111 = +127
  符號位 = 0（看起來是正的）→ 若直接信符號位，會誤判「a 不小於 b」→ 錯
```
原因：`-128 - 1 = -129`，超出 8-bit 有號範圍（下界 -128），**溢位**，
符號位從最負繞回最正而翻掉了。修正方式：溢位時符號位是反的，所以
`slt = diff[31] ^ overflow`——沒溢位就信符號位，溢位就翻回來。
驗證上例：`diff[31]=0`、`overflow=1` → `0 ^ 1 = 1` ✓

**overflow 判斷式的由來**

減法 `a - b = a + (-b)`。加法溢位條件是「兩運算元同號、但結果異號」，
換到減法：「a、b 異號」等價於「a 和 -b 同號」，所以
`overflow = (a[31] != b[31]) && (diff[31] != a[31])`。

**為什麼 SLT 和 SLTU 要分成兩條指令**

SLTU（無號）**沒有溢位問題**——無號數沒有符號位的概念，
硬體上是看減法的 borrow（借位）：借位了就代表 `a < b`，直接比即可。
因為有號無號的判斷機制不同，RISC-V 才把它們分成兩條指令。

**關鍵測資**（同一組輸入、有號無號答案相反）：
- `SLT (0x80000000, 0x00000001)` 必須 = 1（-2³¹ < 1）
- `SLTU(0x80000000, 0x00000001)` 必須 = 0（無號時 0x80000000 更大）

這組測資能抓出「忘了 XOR overflow」的 bug：漏掉的話 SLT 會算成 0。
（值得注意：`$signed` 版本反而可能通過這個 case，因為合成器內部
自己處理了溢位——所以只測 `$signed` 版看不出這個坑，手刻減法版才需要這組測資把關。）

### Register File (`Register_File.v`)
- 32 × 32-bit，2 讀 1 寫。
- **x0 兩邊都擋**：寫入時跳過 `A3==0`，讀出時 `A1/A2==0` 強制回 0
  （只擋寫的話，未初始化的 `mem[0]` 讀出來會是 x）。
- **讀組合、寫同步**：讀做組合是為了在同一個 cycle 內完成「給位址→拿資料→存進 A/B」，
  省一個 cycle；寫做同步是為了讓值在整個 cycle 保持穩定，避免組合迴路。

### Immediate Generator (`Extend.v`)
- 支援 5 種格式（I / S / B / U / J），`ImmSrc` 為 3-bit。
- **B-type 和 J-type 的立即數位元是打散重排的**（最容易接錯），
  且最低位補 0（分支/跳躍目標必為 2 的倍數）。
- **U-type 不做符號延伸**，直接把 20 位放高位、低 12 位補 0。
- 注意 default 分支要給明確值，避免產生 latch。

### Memory (`Memory.v`)
- 單一 memory（fetch 與 load/store 共用），byte-addressable。
- 用 `mem[A>>2]` 做 byte address → word index 的換算。
- 讀組合、寫同步。目前為 word-aligned 版本，
  byte/half 的延伸單元（lb/lh/lbu/lhu）之後補。

### 中間暫存器 (`register_en.v` / `register_nen.v`)
- `register_en`：帶 enable，給 PC / OldPC / IR（需要「按兵不動」的能力）。
- `register_nen`：不帶 enable，給 MDR / A / B / ALUOut（每 cycle 無條件更新）。
- 皆為 `posedge clk`、`rst` 優先清零、用非阻塞賦值 `<=`。

---

## 待完成

- [ ] Datapath 接線（四個關鍵 mux：SrcA / SrcB / ResultSrc / AdrSrc）
- [ ] Control FSM（約 14 個狀態，多週期的主菜）
- [ ] Load/Store 的延伸單元與 byte enable
- [ ] 整合測試（跑一段測試程式驗證各類指令）

### 四個關鍵 mux（datapath 的靈魂）

- **SrcA mux**：ALU 第一輸入 → PC / OldPC / A(rs1)
- **SrcB mux**：ALU 第二輸入 → B(rs2) / ImmExt / 4
- **ResultSrc mux**：寫回的值 → ALUOut / MDR(延伸後) / PC / ImmExt(lui)
- **AdrSrc mux**：memory 位址 → PC(fetch) / ALUOut(load/store)

### 已知待處理的坑

- `jalr` 目標位址要清掉最低位：`(rs1 + imm) & ~1`
- `auipc` 用的是 **OldPC**（這條指令自己的位址），不是 PC+4
- B-type / J-type 立即數位元重排，接錯時波形看起來對但會跳錯地方

---

## 開發原則

- 介面與功能照 Harris《Digital Design and Computer Architecture, RISC-V Edition》，
  但每個設計決策都自己想過「為什麼這樣接、有沒有別的做法」，寫進本文件。
- 零件先各自寫好、獨立測試，再組裝。
- 先求功能正確，再考慮面積/時序優化。

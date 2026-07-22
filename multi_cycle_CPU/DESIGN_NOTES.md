# 設計筆記（DESIGN NOTES）

給自己看的技術細節與「為什麼這樣設計」的記錄。README 講大方向，這裡講原理。

---

## 一、多週期的核心

### 為什麼比單週期省硬體

單週期一個 cycle 做完整條指令，所以：
- 需要**兩個 memory**（fetch 和 load/store 同 cycle 發生，不能共用）
- 需要**多個加法器**（PC+4、branch target、ALU 運算同時要算）

多週期把一條指令拆成多個 cycle，同一單元在不同 cycle 做不同事（時間多工），因此一個 memory、一個 ALU 就夠。

### ALU 一機多用

| Cycle | ALU 在算什麼 |
|-------|-------------|
| Fetch | PC + 4（指令還沒 decode，ALU 閒著） |
| Decode | branch/jal 目標（OldPC + imm，先算好備用） |
| Execute | 真正的運算 |
| Memory | load/store 位址（rs1 + imm） |

靠 SrcA / SrcB mux 每個 cycle 選不同輸入餵給 ALU。

### 中間暫存器的必要性

cycle 之間中間結果會消失，所以要暫存器留住：
- **IR**：存指令，之後幾個 cycle 都要靠它 decode。
- **MDR**：存 memory 讀出的資料，等下 cycle 寫回。
- **A / B**：存 rs1 / rs2，從 decode 保留到 execute。
- **ALUOut**：存 ALU 結果，從 execute 保留到 writeback。

### enable vs 無 enable

- **要 enable（PC / OldPC / IR）**：一條指令的多個 cycle 內不該一直變。
  PC 一條指令只更新一次（Fetch），但一條指令有好幾個 cycle，所以要 PCWrite 控制
  「只有該更新的 cycle 才變」。否則 PC 每 cycle 被覆蓋，一條指令跑完 PC 會暴衝。
- **無 enable（A / B / MDR / ALUOut）**：存的是「這 cycle 剛算的東西」，
  本來就該每 cycle 反映最新計算。

---

## 二、ALU 的 SLT 設計

直接寫 `$signed(a) < $signed(b)` 會另生比較器，跟已有的減法器重複、浪費面積。
真實硬體**重用減法器**：`a < b` 等價於 `a - b < 0`，看符號位即可。

但只看符號位會在**溢位時被騙**。例（8-bit）：
```
a = 1000_0000 = -128, b = 0000_0001 = +1
真值：-128 < 1 → 應為 1
硬體算 a - b = 0111_1111，符號位 = 0（看似正）→ 誤判為「不小於」
```
原因：`-129` 超出範圍溢位，符號位翻掉。修正：
```
slt      = diff[31] ^ overflow            // 沒溢位信符號位，溢位翻回來
overflow = (a[31] != b[31]) && (diff[31] != a[31])
```
overflow 由來：`a - b = a + (-b)`，加法溢位是「兩運算元同號、結果異號」，
換到減法「a、b 異號」等價於「a 和 -b 同號」。

**SLTU 不需要這套**：無號沒有符號位概念，看減法借位即可，直接比。
機制不同是 RISC-V 把 SLT / SLTU 分兩條指令的原因。

> 關鍵測資：`SLT(0x80000000, 1)=1`、`SLTU(0x80000000, 1)=0`。
> 漏掉 XOR overflow 時 SLT 會算成 0，這組能抓出來。
> （`$signed` 版反而可能通過，因為合成器內部處理了溢位——手刻減法版才需要這組把關。）

---

## 三、Register File

- **x0 兩邊都擋**：寫入跳過 `A3==0`，讀出 `A1/A2==0` 強制回 0。
  只擋寫的話未初始化的 `mem[0]` 讀出來是 x。
- **讀組合、寫同步**：讀組合是為了同 cycle 內完成「給位址→拿資料→存進 A/B」，省一個 cycle；
  寫同步是讓值整個 cycle 穩定、避免組合迴路。

---

## 四、Datapath 接線決策

### ALU 輸出分兩條路

ALU 輸出同時接 **ALUResult**（直接）與 **ALUOut**（過暫存器），用 Result mux 選：
- **ALUResult**：當場要用，如 Fetch 算 PC+4 要「這 cycle 就寫回 PC」。
- **ALUOut**：下 cycle 才用，如 branch 目標先算好存著。

### PC 的輸入接 Result

PC 與 register writeback 共用同一個 Result mux 輸出：
Fetch 時 Result 選 ALUResult（PC+4），branch/jal 時選 ALUOut（目標位址）。

### 單一 memory 兩用

memory 位址接 AdrSrc mux：fetch 選 PC、load/store 選算好的位址（Result）。

### mux 編碼約定（datapath 與 controller 必須一致）

| mux | 訊號 | 00 | 01 | 10 |
|-----|------|----|----|----|
| SrcA | ALUSrcA | PC | OldPC | A (rs1) |
| SrcB | ALUSrcB | B (rs2) | ImmExt | 4 |
| Result | ResultSrc | ALUOut | Data (MDR) | ALUResult |
| Adr | AdrSrc | PC | Result | — |

---

## 五、已驗證：Datapath 手動逐 cycle 測試

以手動餵控制訊號（自己扮演 FSM）走完 `addi x1, x0, 10`：

| Cycle | 動作 | 控制訊號 | 驗證 |
|-------|------|---------|------|
| Fetch | 抓指令、算 PC+4 | AdrSrc=0, IRWrite=1, ALUSrcA=00, ALUSrcB=10, ALUControl=0000, ResultSrc=10, PCWrite=1 | Instr 對、PC=4、OldPC=0 |
| Decode | 讀 rs1/rs2 進 A/B | ALUSrcA=01, ALUSrcB=01, ImmSrc=I | A、ImmExt 對 |
| Execute | A + ImmExt | ALUSrcA=10, ALUSrcB=01, ALUControl=0000 | ALUOut=10 |
| WriteBack | 寫回 rd | ResultSrc=00, RegWrite=1 | x1=10 |

先手動把 datapath 這個變數釘死，之後 FSM 出錯就能確定是 FSM 的問題——這是 datapath/control 分離的好處。

---

## 六、已知待處理的坑

- `jalr` 目標位址要清掉最低位：`(rs1 + imm) & ~1`
- `auipc` 用 **OldPC**（這條指令自己的位址），不是 PC+4
- B / J 立即數位元重排，接錯時波形看似對但跳錯地方
- load 資料（MDR）尚未接延伸單元，故 `lb/lh/lbu/lhu` 還不對（只有 `lw` 對）

---

## 七、Control 架構（Harris 標準：FSM + 兩個 decoder）

多週期的控制訊號要**依當前 cycle（state）而變**（例如 RegWrite 只在 WriteBack=1），
所以核心是一個 FSM，而不是單週期那種純組合的 main decoder。整體分三塊：

- **主 FSM**：狀態機，每個狀態輸出對應的時序控制訊號（PCWrite / IRWrite / RegWrite /
  MemWrite / AdrSrc / ALUSrcA / ALUSrcB / ResultSrc / ALUOp），並決定狀態轉移。
- **ALU Decoder**：把 `ALUOp + funct3 + funct7b5 + op` 翻譯成 `ALUControl`（跟時序無關）。
- **Instr Decoder**：看 `op` 決定 `ImmSrc`（立即數格式，整條指令期間固定，跟時序無關）。

ImmSrc 之所以獨立出來、不放進 FSM，是因為它只跟「指令類型」有關、跟「走到第幾個 cycle」無關。

### ALU Decoder 的兩個陷阱

- **funct3=000（add/sub）**：只有 R-type 看 funct7b5（1=sub）；
  I-type 的 addi 永遠是 add，**不能看 funct7**——addi 的 `instr[30]` 是立即數的一部分，
  拿來判斷會誤判成 sub。所以要用 `op` 區分 R-type / I-type。
- **funct3=101（srl/sra）**：R-type 和 I-type **都看 funct7b5**——
  srli/srai 的移位量只用低 5 位，funct7 位置正好拿來區分邏輯/算術右移。

### Branch 走 ALUOp=01，依 funct3 細分

beq/bne→sub、blt/bge→slt、bltu/bgeu→sltu。
（起初誤把 branch 放進 ALUOp=10 的 op=99，會導致 blt 等走到固定 sub 而算錯；
 正確做法是 branch 自成 ALUOp=01 並在其中依 funct3 分流。）

---

## 八、Result mux 的兩條路：ALUResult vs ALUOut

Result mux 同時接 **ALUResult**（ALU 直接輸出）與 **ALUOut**（過暫存器一拍），
這兩條路**不是二選一的設計，而是服務不同目的**，由 FSM 依當前狀態選：

| 狀態 | ResultSrc | 選什麼 | 為什麼 |
|------|-----------|--------|--------|
| Fetch | 10 | ALUResult | PC+4 要「當場」寫回 PC，不能等下個 cycle |
| ALU_WB | 00 | ALUOut | Execute 算好存進 ALUOut，下個 cycle 才寫回暫存器 |
| Mem_WB (load) | 01 | MDR | 寫回 memory 讀出的資料 |

所以：**PC 更新走 ALUResult 直接路**（非當場寫不可），
**暫存器寫回走 ALUOut 暫存器路**（下個 cycle 才寫）。兩條都保留，各有專職。

### 為什麼 R-type 不在 Execute 直接寫回（省一個 cycle）？

技術上可行：Execute 時 ResultSrc 選 ALUResult(10)，同 cycle 算完直接寫回暫存器，R-type 只要 3 個 cycle。
但 Harris 選擇**拆成 Execute（算，存 ALUOut）→ ALU_WB（從 ALUOut 寫回）兩個 cycle**，原因是：

多週期的核心哲學是**每個 cycle 只做一件事、工作量小、critical path 短**，
藉此把 clock frequency 拉高。若在一個 cycle 塞「ALU 運算 + 過 mux + 寫暫存器」，
那個 cycle 的關鍵路徑會變長，成為瓶頸，違背多週期的初衷。
而且均勻的 cycle 之後**比較好 pipeline 化**。所以寧可多一個 cycle 換取每個 cycle 短而均勻。

---

## 九、狀態圖（推導中）

前兩個狀態所有指令共用：
- **Fetch**：抓指令進 IR/OldPC、算 PC+4 寫回 PC
- **Decode**：讀 rs1/rs2 進 A/B、算 branch/jal 目標（OldPC+imm）備用

Decode 之後**依 op 分岔**到不同狀態序列：

- **R-type**：Execute（A op B，存 ALUOut）→ ALU_WB（ResultSrc=00 寫回）→ Fetch
- （其餘指令的狀態序列推導中）

（做到再補）

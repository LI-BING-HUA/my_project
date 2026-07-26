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

| mux | 訊號 | 00 | 01 | 10 | 11 |
|-----|------|----|----|----|----|
| SrcA | ALUSrcA | PC | OldPC | A (rs1) | const 0（lui 用）|
| SrcB | ALUSrcB | B (rs2) | ImmExt | 4 | — |
| Result | ResultSrc | ALUOut | Data (MDR) | ALUResult | — |
| Adr | AdrSrc | PC | Result | — | — |

（SrcA 是 4-to-1：lui 要算 `0 + imm`，需要一個恆為 0 的來源，故加第 4 個輸入 `32'd0`。）

---

## 五、已驗證：Datapath 手動逐 cycle 測試

以手動餵控制訊號（自己扮演 FSM）走完 `addi x1, x0, 10`，
再用同樣方式走完 `add x3, x1, x2`（驗證 SrcB 選 B(rs2) 那條路）：

| Cycle | 動作 | 控制訊號 | 驗證 |
|-------|------|---------|------|
| Fetch | 抓指令、算 PC+4 | AdrSrc=0, IRWrite=1, ALUSrcA=00, ALUSrcB=10, ALUControl=0000, ResultSrc=10, PCWrite=1 | Instr 對、PC=4、OldPC=0 |
| Decode | 讀 rs1/rs2 進 A/B | ALUSrcA=01, ALUSrcB=01, ImmSrc=I | A、ImmExt 對 |
| Execute | A + ImmExt（或 A+B） | ALUSrcA=10, ALUSrcB=01(或00), ALUControl=0000 | ALUOut 對 |
| WriteBack | 寫回 rd | ResultSrc=00, RegWrite=1 | rd 值對 |

先手動把 datapath 這個變數釘死，之後 FSM 出錯就能確定是 FSM 的問題——這是 datapath/control 分離的好處。

**驗證時踩到的坑**：
- 多週期是時序電路，每個 cycle 之間 testbench 一定要 `@(posedge clk); #1;`，暫存器才會更新；
  少了它，訊號設了但時鐘沒走，暫存器全停在原地（讀出來全 0）。
- 讀內部訊號要讀 `.out` 不是 `.in`（in 是還沒進暫存器的線）；
  讀暫存器內容要讀 `rf.mem[N]` 不是 `rf.WD3`（WD3 是「正在送」的資料線，mem[N] 才是「已存」的值）。
- 要測哪條指令，就把那條的機器碼放進 mem[0]；機器碼用 **hex** 寫比二進位安全（二進位長、易藏隱形字元、易數錯位數）。

---

## 六、已解決的坑（實作過程記錄）

- `jalr` 目標位址要清掉最低位：`(rs1 + imm) & ~1`。因為所有合法 PC 都是 4 的倍數，
  bit0 本來就是 0，可以在 PC 輸入前無條件清掉 bit0，不需額外控制訊號。
- `auipc` 用 **OldPC**（這條指令自己的位址），不是 PC+4。Decode 已經算好 `OldPC+imm`，直接接 ALU_WB 寫回。
- B / J 立即數位元重排，接錯時波形看似對但跳錯地方。
- **load 的延伸單元**：memory 讀出整個 word，`lb/lh/lbu/lhu` 要依 funct3 + 位址低 2 位挑 byte/half
  再做符號/零延伸。Load Unit 接在 memory 輸出到 MDR 之間（見第十節時序陷阱）。
- **store 的 write mask**：`sb/sh` 只寫入對應的 byte/half lane，不動 word 的其他位元組。
  funct3 傳進 memory，內部依 A[1:0] + funct3 做 sub-word 寫入。

---

## 七、Control 架構（Harris 標準：FSM + 兩個 decoder）

多週期的控制訊號要**依當前 cycle（state）而變**（例如 RegWrite 只在 WriteBack=1），
所以核心是一個 FSM，而不是單週期那種純組合的 main decoder。整體分三塊：

- **主 FSM**：狀態機，每個狀態輸出對應的時序控制訊號（PCUpdate / IRWrite / RegWrite /
  MemWrite / AdrSrc / Branch / ALUSrcA / ALUSrcB / ResultSrc / ALUOp），並決定狀態轉移。
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

### Branch 與 branch_taken 分工

- **Branch**（FSM 輸出）：純粹是「現在是不是在 BEQ 狀態」，FSM 走到 BEQ 就設 1，其他狀態 0。
- **branch_taken**（頂層組合）：依 funct3 選 `zero` 或 `alu_result0` 判斷條件成不成立。
- **PCWrite = PCUpdate | (Branch & branch_taken)**：
  branch_taken 隨時都在算（不管哪個狀態），所以要 Branch 當「閘門」——
  只有 BEQ 狀態時 branch_taken 才准影響 PC，否則 R-type 的 Execute 剛好 zero=1 也會誤跳。

| 指令 | funct3 | ALU 做 | taken 條件 |
|------|:------:|--------|-----------|
| beq  | 000 | sub | `zero` |
| bne  | 001 | sub | `~zero` |
| blt  | 100 | slt | `alu_result0` |
| bge  | 101 | slt | `~alu_result0` |
| bltu | 110 | sltu | `alu_result0` |
| bgeu | 111 | sltu | `~alu_result0` |

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

## 九、狀態圖（完整）

前兩個狀態所有指令共用：
- **FETCH**：抓指令進 IR/OldPC、算 PC+4 寫回 PC（ALUResult 直接路）
- **DECODE**：讀 rs1/rs2 進 A/B、算 branch/jal 目標（OldPC+imm）存 ALUOut 備用

DECODE 之後**依 op 分岔**：

```
FETCH → DECODE → ┬ EXECUTER → ALUWB          (R-type,  op=51)
                 ├ EXECUTEI → ALUWB          (I-type,  op=19)
                 ├ MEMADR ─┬ MEMREAD → MEMWB  (load,    op=3)
                 │         └ MEMWRITE         (store,   op=35)
                 ├ BEQ                        (branch,  op=99，含 6 種 funct3)
                 ├ ALUWB                      (auipc,   op=23，DECODE 已算完 OldPC+imm)
                 ├ LUI → ALUWB                (lui,     op=55)
                 ├ JAL → ALUWB                (jal,     op=111)
                 └ JALR → JAL → ALUWB         (jalr,    op=103)
```

各指令 cycle 數：R/I-type 4、load 5、store 4、branch 3、auipc 3、lui 4、jal 4、jalr 5。

### 各狀態輸出（速查）

| 狀態 | 主要控制訊號 | 下一狀態 |
|------|-------------|---------|
| FETCH | IRWrite=1, ALUSrcA=PC, ALUSrcB=4, ResultSrc=ALUResult, PCUpdate=1 | DECODE |
| DECODE | ALUSrcA=OldPC, ALUSrcB=Imm（先算 target） | 依 op 分岔 |
| EXECUTER | ALUSrcA=A, ALUSrcB=B, ALUOp=R/I | ALUWB |
| EXECUTEI | ALUSrcA=A, ALUSrcB=Imm, ALUOp=R/I | ALUWB |
| ALUWB | ResultSrc=ALUOut, RegWrite=1 | FETCH |
| MEMADR | ALUSrcA=A, ALUSrcB=Imm, ALUOp=add（算位址） | MEMREAD/MEMWRITE |
| MEMREAD | AdrSrc=Result（讀 mem 進 MDR，經 Load Unit） | MEMWB |
| MEMWB | ResultSrc=MDR, RegWrite=1 | FETCH |
| MEMWRITE | AdrSrc=Result, MemWrite=1 | FETCH |
| BEQ | ALUSrcA=A, ALUSrcB=B, ALUOp=branch, Branch=1 | FETCH |
| LUI | ALUSrcA=const0, ALUSrcB=Imm, ALUOp=add | ALUWB |
| JAL | ALUSrcA=OldPC, ALUSrcB=4, PCUpdate=1（PC=target，順便算 PC+4） | ALUWB |
| JALR | ALUSrcA=A, ALUSrcB=Imm（算 rs1+imm 當 target） | JAL |

### 幾個關鍵設計理由

- **jal 走 JAL → ALUWB**：寫回 rd（return address）統一走 ALUWB，
  跟 R/I-type 共用同一個寫回狀態，不必為 jal 另寫一套寫回邏輯。
- **jalr 需要獨立狀態（不能在 DECODE 分路算）**：
  DECODE 這個 cycle，A 暫存器**還沒載入 rs1**（cycle 結尾才存進 A），
  所以 DECODE 時算 `rs1+imm` 會用到舊的 A 值，算出錯的目標。
  必須等 A 載入後，用獨立的 JALR 狀態才算得對。（曾試 DECODE 分路，jalr 跳到 0，就是這個原因。）
- **auipc 不需要獨立狀態**：它要的 `OldPC+imm` 正好是 DECODE 已經算好存在 ALUOut 的值，
  直接接 ALUWB 即可。DECODE 那個「先算 target 備用」的動作，同時服務了 branch、jal、auipc 三種指令。
- **BEQ 的時序巧思**：BEQ 這個 cycle ALU 在算 A−B（比較），但 ALUOut 存的是**上一個 cycle（DECODE）**
  算的 branch target，還沒被覆蓋。所以同一 cycle：ALUOut=target（可拿去更新 PC）、zero=比較結果（判斷 taken），兩個同時有效。

---

## 十、Load / Store 的 sub-word 處理與時序陷阱

### 資料層 vs 控制層

byte/half 的差異**只在資料層，不在控制層**：
- FSM 完全不用改——load 不管 byte/half/word 都走 `MEMADR→MEMREAD→MEMWB`，
  store 都走 `MEMADR→MEMWRITE`，算位址都是加法。
- 差異只在「memory 讀出的 word 怎麼挑 byte + 延伸」（load）
  和「怎麼只寫一個 byte 不動其他」（store），這些是資料處理，不是狀態轉移。

### Load Unit 的位置（易埋雷）

**Load Unit 必須接在 memory 輸出到 MDR 之間，不能接在 MDR 之後。**

原因是時序：
- Load Unit 挑 byte 要用**位址的低兩位 `Adr[1:0]`**（= ALUOut[1:0]）。
- ALUOut 是無 enable 暫存器，每個 cycle 都更新。**只有 MEMREAD 那個 cycle，ALUOut 才是正確的 load 位址**。
- 到了 MEMWB，ALU 已經在算別的（ALUSrcA/B default 回 0），ALUOut 不再是位址。
- 所以要**趁 MEMREAD 這個 cycle、Adr[1:0] 還有效時**，立刻用組合邏輯挑 byte + 延伸，
  把處理好的值存進 MDR。時序上：
  ```
  Memory.RD → Load Unit（用 Adr[1:0] + funct3 挑 byte + 延伸）→ 存進 MDR
  ```

### memory 輸出要分兩路（IR 不經 Load Unit）

memory 的原始輸出要分兩條：
- **指令路**：Fetch 時，memory 讀出的是**完整 32-bit 指令**，直接進 IR，**不能經過 Load Unit**
  （否則指令會被當成 load 資料挑 byte，變成錯的）。
- **資料路**：load 時，memory 讀出的資料經 Load Unit 挑 byte + 延伸，再進 MDR。

```
memory.RD ─┬─────────────────→ IR         （指令，完整 word，直接接）
           └─ Load Unit → MDR → Result mux （load 資料，挑 byte + 延伸）
```

> 曾把 Load Unit 串在 memory 輸出主幹上，導致 IR 也讀到被 Load Unit 處理過的資料——
> 症狀是 IR 拿到的指令不完整。修法：IR 的輸入改回直接接 memory.RD，Load Unit 只在資料路上。

### store 的位址時序沒問題

MEMWRITE 這個 cycle，ALUOut 剛好是**上一個 cycle（MEMADR）**算好、還沒被覆蓋的位址，
同 cycle 用就對。memory 內部用 `A[1:0] + funct3` 做寫入 mask 即可，不需額外處理。

---

## 十一、Debug 記錄：值得記住的坑

### FSM latch：預設值放錯位置，訊號永遠是 1

FSM 輸出邏輯 `always @(*)`，一開始把「全部歸零」的預設值放在 `default:` 分支裡。
但 11 個狀態全部列舉了，`default` **永遠輪不到**，那段歸零形同不存在。
結果沒被某狀態明確賦值的訊號（如 PCUpdate、IRWrite）產生 **latch**，一直保持 1，
PC 每個 cycle 都 +4、IR 每個 cycle 被覆蓋，看起來像整台壞掉。

**修法**：預設值一定要放在 `case` **之前**，先全部歸零，再由各狀態覆寫需要的。
（症狀很像「訊號永遠是 1」，其實是 latch 殘留——pipeline 的 control 也用同樣的「先歸零再覆寫」模式。）

### 未實作的 opcode 掉進 default，把自己的程式碼寫壞

最難抓的一個。當時 jalr（op=103）還沒實作，DECODE 的 op 分岔沒有它，
掉到 `default: next_state = MEMADR`。然後 MEMADR→MEMWRITE，`MemWrite=1`，
把 rs2 的值（jalr 的 rs2 欄位=x0=0）寫進「rs1+imm 算出來的位址」，
那個位址剛好是某條指令所在的記憶體位置——**程式把自己的 code 覆蓋成 0 了**。

症狀完全誤導：看起來像某條 lui 的機器碼有問題（lui 讀出來是 0），
花很久才靠「在 `t=1` 印一次 mem[41]」定位到——t=1 時 mem[41] 是對的，
執行中才被寫壞，證明是 run-time 的 store 覆蓋，不是 initial 載入問題。

**教訓**：FSM 的 `default` 分支不能導向有副作用的狀態（MEMADR→MEMWRITE 會寫記憶體）。
未實作的 opcode 應該導向安全的狀態（如 FETCH），或明確處理，不能讓它亂寫記憶體。

---

## 十二、驗證結果

用 `Memory.v` 內建測試程式（mem[0]~mem[76]）跑完整流程，以 `$display` 監控狀態序列 +
在特定 PC 檢查暫存器值，對照每條指令註解的預期值。

已驗證通過：
- R-type 十條（add/sub/sll/slt/sltu/xor/srl/sra/or/and）
- I-type 九條（addi/slli/slti/sltiu/xori/srli/srai/ori/andi）
- load/store word（sw→lw）
- branch 六種（beq/bne/blt/bge/bltu/bgeu，taken / not-taken 都測）
  - 關鍵：`blt(-1, 5)` taken 但 `bltu(-1, 5)` not-taken（-1 無號時超大），驗證有號/無號分流正確
- jal、jalr（跳過中間指令、return address 正確）
- auipc（用 OldPC 不是 PC+4）、lui（0+imm）
- byte/half load-store（lb/lh/lbu/lhu/sb/sh）

程式用 `beq x0, x0, 0`（跳到自己的無限迴圈）當 HALT 標記程式結束。

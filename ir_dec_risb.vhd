library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
library work;
use work.constants.all;

entity ir_dec_risb is
    generic ( dataWidth : integer:=32; aluOpWidth : integer:=5 );
    port ( 
        instr        : in  std_logic_vector (dataWidth - 1 downto 0);
        aluOp        : out std_logic_vector (aluOpWidth - 1 downto 0);
        insType      : out std_logic_vector(2 downto 0);
        
        RI_sel       : out std_logic; 
        rdWrite      : out std_logic;
        wrMem        : out std_logic;
        
        loadAccJump  : out std_logic_vector(1 downto 0); -- Selecteur WB (3 choix)
        
        pc_load      : out std_logic; 
        
        -- NOUVEAU : bsel sur 2 bits
        bsel         : out std_logic_vector(1 downto 0); -- 00=Rs1, 01=PC, 10=Zero
        
        bres         : in  std_logic;
        btype        : out std_logic_vector(2 downto 0);
        memType, loadType : out std_logic_vector(2 downto 0)
    );
end entity ir_dec_risb;

architecture behav of ir_dec_risb is
    alias opcode : std_logic_vector(6 downto 0) is instr(6 downto 0);
    alias funct3 : std_logic_vector(2 downto 0) is instr(14 downto 12);
    alias funct7_b5 : std_logic is instr(30);
    signal instType_local : std_logic_vector(2 downto 0);
begin

    -- 1. Décodage Type
    process (opcode) begin
        case opcode is
            when R_TYPE_OPCODE => instType_local <= R_TYPE;
            when I_TYPE_OPCODE => instType_local <= I_TYPE;
            when L_TYPE_OPCODE => instType_local <= L_TYPE;
            when S_TYPE_OPCODE => instType_local <= S_TYPE;
            when B_TYPE_OPCODE => instType_local <= B_TYPE;
            when J_TYP1_OPCODE => instType_local <= J_TYPE; -- JAL
            when J_TYP2_OPCODE => instType_local <= I_TYPE; -- JALR
            when U_TYP1_OPCODE => instType_local <= U_TYPE; -- LUI
            when U_TYP2_OPCODE => instType_local <= U_TYPE; -- AUIPC
            when others        => instType_local <= UNKTYP;
        end case;
    end process;
    insType <= instType_local;

    -- 2. ALU Op
    process (instType_local, funct3, funct7_b5, opcode) begin
        aluOp <= (others => '0'); -- Default ADD
        if instType_local = R_TYPE then
            aluOp <= '0' & funct7_b5 & funct3;
        elsif instType_local = I_TYPE and opcode /= J_TYP2_OPCODE then
            if funct3 = "101" then aluOp <= '0' & funct7_b5 & funct3;
            else aluOp <= "00" & funct3; end if;
        end if;
    end process;

    -- 3. Contrôle
    process (instType_local, opcode, bres, funct3) begin
        rdWrite <= '0'; RI_sel <= '0'; wrMem <= '0'; 
        loadAccJump <= "00"; -- Default WB=ALU
        pc_load <= '0'; 
        bsel <= "00"; -- Default OpA=Rs1
        loadType <= "010"; memType <= "010";

        case instType_local is
            when R_TYPE => rdWrite <= '1';
            
            when I_TYPE => 
                rdWrite <= '1'; RI_sel <= '1';
                if opcode = J_TYP2_OPCODE then -- JALR
                    pc_load <= '1'; 
                    bsel    <= "00";   -- OpA = Rs1
                    loadAccJump <= "10"; -- WB = PC+4
                end if;
                
            when L_TYPE => 
                rdWrite <= '1'; RI_sel <= '1'; loadAccJump <= "01"; loadType <= funct3;
                
            when S_TYPE => 
                RI_sel <= '1'; wrMem <= '1'; memType <= funct3;
                
            when B_TYPE => 
                bsel <= "01"; -- OpA = PC
                RI_sel <= '1'; 
                pc_load <= bres;
                
            when J_TYPE => -- JAL
                rdWrite <= '1'; RI_sel <= '1'; 
                bsel <= "01"; -- OpA = PC (pour calculer cible saut)
                pc_load <= '1'; 
                loadAccJump <= "10"; -- WB = PC+4
                
            when U_TYPE =>
                rdWrite <= '1';
                RI_sel  <= '1'; -- OpB = Imm
                
                if opcode = U_TYP1_OPCODE then -- LUI
                    bsel <= "10";   -- OpA = ZERO.  ALU = 0 + Imm
                    loadAccJump <= "00"; -- WB = ALU
                else -- AUIPC
                    bsel <= "01";   -- OpA = PC.    ALU = PC + Imm
                    loadAccJump <= "00"; -- WB = ALU
                end if;

            when others => null;
        end case;
    end process;
    btype <= funct3;
end behav;
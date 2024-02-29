----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2023 12:20:31 PM
-- Design Name: 
-- Module Name: test_new - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_new is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_new;


architecture Behavioral of test_new is

component Instr_Fetch is
 Port (jump : in STD_LOGIC;
       pcsrc : in STD_LOGIC;
       clk : in STD_LOGIC;
       ba : in STD_LOGIC_VECTOR(15 downto 0);
       ja : in STD_LOGIC_VECTOR(15 downto 0);
       en: in STD_LOGIC;
       reset:in STD_LOGIC;
       pcPlusUnu: out STD_LOGIC_VECTOR(15 downto 0);
       instruction: out STD_LOGIC_VECTOR(15 downto 0));
end component Instr_Fetch;
--MPG
component MPG_debouncer is
    Port ( en : out STD_LOGIC;
         btn : in STD_LOGIC;
         clk : in STD_LOGIC);
end component MPG_debouncer;

--SEVEN SEGM
component P7segment is
 Port (  digit0 : STD_LOGIC_VECTOR(3 downto 0);
         digit1 : STD_LOGIC_VECTOR(3 downto 0);
         digit2 : STD_LOGIC_VECTOR(3 downto 0);
         digit3 : STD_LOGIC_VECTOR(3 downto 0);
         clk : in STD_LOGIC;
         cat :out STD_LOGIC_VECTOR(6 downto 0);
         an : out STD_LOGIC_VECTOR (3 downto 0));
end component P7segment;

--ID
component ID is
 Port (clk: in std_logic;
        enable: in std_logic;
        RegWrite: in std_logic;
        instruction: in std_logic_vector(15 downto 0);
        RegDst: in std_logic;
        WD: in std_logic_vector(15 downto 0);
        ExtOp: in std_logic;
        RD1:out std_logic_vector(15 downto 0);
        RD2:out std_logic_vector(15 downto 0);
        Ext_Imm:out std_logic_vector(15 downto 0);
        sa:out std_logic;
        func:out std_logic_vector(2 downto 0) );
end component ID;

--UC
 component UC is
    Port ( opCode : in STD_LOGIC_VECTOR (2 downto 0);
           regDst : out STD_LOGIC;
           regWr : out STD_LOGIC;
           aluSrc : out STD_LOGIC;
           extOp : out STD_LOGIC;
           aluOp : out STD_LOGIC_VECTOR (1 downto 0);
           memWrite : out STD_LOGIC;
           memReg : out STD_LOGIC;
           branch : out STD_LOGIC;
           jump : out STD_LOGIC;
           bgt : out STD_LOGIC);
end component UC;

--UE
component UE is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           ALUsrc : in STD_LOGIC;
           Ext_Imm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUop : in STD_LOGIC_VECTOR (1 downto 0);
           PCNext : in STD_LOGIC_VECTOR (15 downto 0);
           BranchAddr : out STD_LOGIC_VECTOR (15 downto 0);
           ALUres : out STD_LOGIC_VECTOR (15 downto 0);
           Zero : out STD_LOGIC;
           greater : out STD_LOGIC);
end component UE;

--memorie
component Memorie is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           memWrite : in STD_LOGIC;
           aluResIn : in STD_LOGIC_VECTOR (15 downto 0);
           rd2 : in STD_LOGIC_VECTOR (15 downto 0);
           memData : out STD_LOGIC_VECTOR (15 downto 0);
           aluResOut : out STD_LOGIC_VECTOR (15 downto 0));
end component Memorie;

-------declarare semnale----------------------------------------------------------------------------------------------
signal en : STD_LOGIC:='0';
signal reset : STD_LOGIC:='0';
signal sa: STD_LOGIC:='0';
signal regWrite : STD_LOGIC:='0';
signal regDst : STD_LOGIC:='0';
signal extOp : STD_LOGIC:='0';
signal aluSrc : STD_LOGIC:='0';
signal branch : STD_LOGIC:='0';
signal bgt : STD_LOGIC:='0';
signal jump : STD_LOGIC:='0';
signal memWrite : STD_LOGIC:='0';
signal memReg : STD_LOGIC:='0';
signal zero : STD_LOGIC:='0';
signal zeroBranchBgt : STD_LOGIC:='0';
signal zeroBranchBgz : STD_LOGIC:='0';
signal PcSrc : STD_LOGIC:='0';
--
signal SSD_in:STD_LOGIC_VECTOR(15 downto 0):=X"0000";
signal instruction:STD_LOGIC_VECTOR(15 downto 0):=X"0000";
signal pcplusunu:STD_LOGIC_VECTOR(15 downto 0):=X"0000";
--
signal rdata1:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal rdata2:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal wdata:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal memdata:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal func:STD_LOGIC_VECTOR(2 downto 0):=(others=>'0');
signal alures:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal alures1:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal extImm:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal jumpAdress:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal branchAdress:STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal aluOp:STD_LOGIC_VECTOR(1 downto 0):="00";


begin
--avem 2 mpg-uri
mpg1 : MPG_debouncer port map(en,btn(0),clk);
mpg2 : MPG_debouncer port map(reset,btn(2),clk);
--SSD_in<=instruction when sw(3)='0' else pcplusunu;
SSDa : P7segment port map(SSD_in(3 downto 0),SSD_in(7 downto 4),SSD_in(11 downto 8),SSD_in(15 downto 12),clk,cat,an);
Instr : Instr_Fetch port map(jump,pcsrc,clk,branchAdress,jumpAdress,en,reset,pcplusunu,instruction);
--wdata=rdata1+rdata2;
instr_d :ID port map(clk,en,regWrite,instruction,regDst,wdata,extOp,rdata1,rdata2,extImm,sa,func);
Uc_comp : UC port map(instruction(15 downto 13),regDst,regWrite,aluSrc,extOp,aluOp,memWrite,memReg,branch,jump,bgt);
ue_comp : UE port map(rdata1,rdata2,alusrc,extImm,sa,func,aluop,pcplusunu,branchAdress,alures,zero,zeroBranchBgt);

mem_comp : Memorie port map(clk,en,memwrite,alures,rdata2,memdata,alures);

PcSrc<=(Branch and Zero) or (bgt and zeroBranchBgt);
jumpAdress<="000"&instruction(12 downto 0);
wdata<=aluRes when memreg='0' else memdata;

process(sw,instruction,pcplusunu,rdata1,rdata2,extImm,memdata,wdata,alures)
begin
if sw(7 downto 5)="000" then
     ssd_in<=instruction;
elsif sw(7 downto 5)="001" then
     ssd_in<=pcplusunu; 
elsif sw(7 downto 5)="010" then
     ssd_in<=rdata1; 
elsif sw(7 downto 5)="011" then
     ssd_in<=rdata2; 
elsif sw(7 downto 5)="100" then
      ssd_in<=extImm; 
elsif sw(7 downto 5)="101" then
      ssd_in<=alures; 
elsif sw(7 downto 5)="110" then
      ssd_in<=memdata;
else
    ssd_in<=wdata;  
end if;
end process;
-- conectare la leduri 
--led<=instruction(15 downto 13) & RegDst & RegWrite & ExtOp & AluSrc & AluOp & MemWrite & MemReg & Jump &Branch &bgez &bgt & pcsrc;
led(2 downto 0) <= instruction(15 downto 13);
led(3)<=regDst;
led(4)<=regWrite;
led(5)<=extOp;
led(6)<=aluSrc;
led(8 downto 7)<=aluOp;
led(9)<=memwrite;
led(10)<=memReg;
led(11)<=jump;
led(12)<=branch;
led(13)<=bgt;
led(14)<=PcSrc;
led(15)<=zeroBranchBgt;
end Behavioral;

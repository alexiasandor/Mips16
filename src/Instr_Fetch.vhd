----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2023 07:18:14 PM
-- Design Name: 
-- Module Name: Instr_Fetch - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Instr_Fetch is
  Port (jump : in STD_LOGIC;
        pcsrc : in STD_LOGIC;
        clk : in STD_LOGIC;
        ba : in STD_LOGIC_VECTOR(15 downto 0); --adresa de branch
        ja : in STD_LOGIC_VECTOR(15 downto 0); -- adresa de jump
        en: in STD_LOGIC;
        reset:in STD_LOGIC;
        pcPlusUnu: out STD_LOGIC_VECTOR(15 downto 0); -- adresa urmatoarei instructiuni
        instruction: out STD_LOGIC_VECTOR(15 downto 0));-- instructiunea de executat
end Instr_Fetch;

architecture Behavioral of Instr_Fetch is
signal pc_out : STD_LOGIC_VECTOR(15 downto 0):=X"0000";
signal sum : STD_LOGIC_VECTOR(15 downto 0):=X"0000";
signal mux1 : STD_LOGIC_VECTOR(15 downto 0):=X"0000";
signal mux2 : STD_LOGIC_VECTOR(15 downto 0):=X"0000";

-- rom
type ROM is array (0 to 31) of STD_LOGIC_VECTOR (15 downto 0);
signal memorieROM: ROM:=( --minimul unui sir la patrat
b"001_000_001_0000001", -- 0010 0 #i=0, contorul buclei
b"001_000_100_0001001", --220A,1 # se salveaza numarul maxim de iteratii
b"000_000_000_010_0_000", --0020 2# se initializeaza indexul locatiei de memorie
b"010_010_101_0000000", --4A80 3# min = arr[0]
b"100_001_100_0000101", --8606 4#s-au facut 10 iteratii ? Daca da, sari la...
b"001_010_010_0000001", --2901 5# creste indexul
b"010_010_110_0000000", --4B00 6# salveaza in $6 urmatorul element
b"101_110_101_0000001", --BA81 7# arr[i]>min ? Daca da, dari la...
b"010_010_101_0000000", --1850 8# daca nu, salveaza in $5 arr[i]
b"001_001_001_0000001", --2481 9# creste contorul
b"111_0000100",   --E004 10#jump
b"000_000_000_111_0_000",--0070 11# pune in $7 0
b"000_000_000_011_0_000",--0030 12# pune in $valoarea 0
b"100_111_101_0000011", --9E83 13# este $7=$5? daca da, sari la...
b"000_011_101_011_0_000", --0EB0 14 #daca nu adauga in $3 valoarea lui $5
b"001_111_111_0000001",   --1FC0 15# creste contorul
b"111_0001010", --E00C 16#jump
b"011_010_011_0000000", -- 6980 17# salveaza minimul la patrat
others=>x"1111");
begin
sum<= pc_out+1;
pcPlusUnu<=sum;

C_PROCESS :process(clk)
begin
 if rising_edge(clk)then
    if reset='1' then 
     pc_out<=X"0000";
    elsif en='1' then 
     pc_out<=mux2;
    end if;
 end if;
end process;

-- mux1
mux1<=sum when pcsrc='0' else ba;
mux2<=mux1 when jump='0' else ja;

instruction<=memorieROM(conv_integer(pc_out));     
end Behavioral;

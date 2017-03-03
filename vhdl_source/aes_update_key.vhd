----------------------------------------------------------------------------------
-- Engineer: Pedro Maat C. Massolino
-- Engineer: Tom Sandmann (s4330048) & Abdullah Rasool (s4350693)
-- Cryptographic Engineering, TRU/e Nijmegen University
-- 
-- Create Date:    28/11/2016
-- Design Name:    AES_KeyUpdate
-- Module Name:    AES_KeyUpdate
-- Project Name:   AES128_Demo
-- Target Devices: Any
--
-- Description: 
--
-- Performs the AES Key update from previous key. 
--
--
-- Dependencies:
-- VHDL-93
--
--
-- Revision: 
-- Revision 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aes_update_key is
    Port(
        key : in STD_LOGIC_VECTOR(127 downto 0);
        round_constant : in STD_LOGIC_VECTOR(7 downto 0);
		enc_dec : in STD_LOGIC;
        new_key : out STD_LOGIC_VECTOR(127 downto 0)
    );
end aes_update_key;
 
 architecture behavioral of aes_update_key is

component aes_sbox is
    Port (
        a : in STD_LOGIC_VECTOR(7 downto 0);
        enc_dec : in STD_LOGIC;
        o : out STD_LOGIC_VECTOR(7 downto 0)
    );
end component;
 
signal key0 : STD_LOGIC_VECTOR(31 downto 0);
signal key1 : STD_LOGIC_VECTOR(31 downto 0);
signal key2 : STD_LOGIC_VECTOR(31 downto 0);
signal key3 : STD_LOGIC_VECTOR(31 downto 0);

signal subword_key3 : STD_LOGIC_VECTOR(31 downto 0);
signal rcon_key3 : STD_LOGIC_VECTOR(31 downto 0);

signal subword_sbox_enc_dec : STD_LOGIC;
--signal enc_dec : STD_LOGIC;
signal rconkey : STD_LOGIC_VECTOR(31 downto 0);

signal e0 : STD_LOGIC_VECTOR(31 downto 0);
signal e1 : STD_LOGIC_VECTOR(31 downto 0);
signal e2 : STD_LOGIC_VECTOR(31 downto 0);
signal e3 : STD_LOGIC_VECTOR(31 downto 0);

signal d0 : STD_LOGIC_VECTOR(31 downto 0);
signal d1 : STD_LOGIC_VECTOR(31 downto 0);
signal d2 : STD_LOGIC_VECTOR(31 downto 0);
signal d3 : STD_LOGIC_VECTOR(31 downto 0);

signal new_key_dec : STD_LOGIC_VECTOR(127 downto 0);
signal new_key_enc : STD_LOGIC_VECTOR(127 downto 0);

begin

key0 <= key(31 downto 0);
key1 <= key(63 downto 32); 
key2 <= key(95 downto 64);
key3 <= key(127 downto 96);



--rcon input 
rconkey <= 	key3 when enc_dec = '1' else
			key2 xor key3;


-- SubWord operation
aes_sbox0 : aes_sbox
    Port Map(
        a => rconkey(15 downto 8),
        enc_dec => subword_sbox_enc_dec,
        o => subword_key3(7 downto 0)
    );

aes_sbox1 : aes_sbox
    Port Map(
        a => rconkey(23 downto 16),
        enc_dec => subword_sbox_enc_dec,
        o => subword_key3(15 downto 8)
    );

aes_sbox2 : aes_sbox
    Port Map(
        a => rconkey(31 downto 24),
        enc_dec => subword_sbox_enc_dec,
        o => subword_key3(23 downto 16)
    );

aes_sbox3 : aes_sbox
    Port Map(
        a => rconkey(7 downto 0),
        enc_dec => subword_sbox_enc_dec,
        o => subword_key3(31 downto 24)
    );

subword_sbox_enc_dec <= '1';  

-- Rcon operation
    
rcon_key3(31 downto 8) <= subword_key3(31 downto 8);
rcon_key3(7 downto 0) <= subword_key3(7 downto 0) xor round_constant;

-- Key update

-- Decryption key update

d0 <= rcon_key3 xor key0;
d1 <= key1 xor key0;
d2 <= key1 xor key2;
d3 <= key2 xor key3;

new_key_dec <= d3 & d2 & d1 & d0;

-- Encryption key update

e0 <= rcon_key3 xor key0;
e1 <= e0 xor key1;
e2 <= e1 xor key2;
e3 <= e2 xor key3;

new_key_enc <= e3 & e2 & e1 & e0;


new_key <= 	new_key_enc when enc_dec = '1' else
			new_key_dec;

end behavioral;
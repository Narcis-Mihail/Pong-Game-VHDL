library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity pONG is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           btnL : in STD_LOGIC;
           btnR : in STD_LOGIC;
           btnC : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp : out STD_LOGIC);
end pONG;


architecture Behavioral of pONG is

type states is(idle,idle_serva,increment1,a_ajuns1,increment2,a_ajuns2,minge_prinsa1,minge_prinsa2,mareste_viteza,sw_pl,score_up1, score_up2);
signal current_state, next_state : states;

signal clk_div : std_logic;
signal n: integer:= 625*10**5;
signal score : std_logic_vector (15 downto 0);
signal player: std_logic :='0';
signal counter: integer :=0;
signal inc1sec, en_cnt : std_logic;

component driver7seg is
		port (
			clk : in STD_LOGIC; --100MHz board clock input
			Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
			an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
			seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
			dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
			dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
			rst : in STD_LOGIC); --global reset
	end component driver7seg;

begin

u1: driver7seg port map( clk=>clk,
                         Din=>score,
                         an=>an,
                         seg=>seg,
                         dp_in => "0000",
                         dp_out => dp,
                         rst=>rst);
                         

-- timer
process(clk, rst)
variable q : integer := 0;
begin
  if rst = '1' then
    q := 0;
    inc1sec <= '0';
  elsif rising_edge(clk) then
    if en_cnt = '1' then  
      if q = 10**8 - 1 then
        q := 1;
        inc1sec <= '1';
      else
        q := q + 1;
        inc1sec <= '0';
      end if;
    end if;        
  end if;  
end process;

process(clk, rst)
begin
    if rst = '1' then
        current_state <= idle;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;    
end process;

Divizor : process (rst, clk)
variable q : integer := 0;
begin
    if rst = '1' then
        q := 0;
        clk_div <= '0';
    elsif rising_edge(clk) then
        if q = n - 1 then
            q := 0;
            clk_div <= '1';
        else
            q := q + 1;
            clk_div <= '0';
        end if;
    end if;
end process;


StatesMap: process(current_state, btnC, btnR, btnL, counter, player,inc1sec)
begin

case current_state is
    when idle=> if btnC='1' then
                    next_state<=idle_serva;
                else 
                    next_state<=idle;
                end if;

    when idle_serva=> if btnR='1' then
                        next_state<=increment1;
                      else
                        next_state<=idle_serva;
                      end if;

    when increment1=> if counter=15 then
                         next_state<=a_ajuns1;
                    else
                        next_state<=increment1;
                    end if;
   
    
    when a_ajuns1=>if btnL='1' and inc1sec='0' then
                                                 next_state<=minge_prinsa1;
                       
                                             elsif inc1sec='0' then
                                             next_state<=a_ajuns1;
                                             else
                                                next_state<=score_up1;
                                             end if;

                       

    when minge_prinsa1=> 
                            next_state<=mareste_viteza;
                        

    when mareste_viteza=>next_state<=sw_pl;
    
    when sw_pl=> if player='0' then
                    next_state<=increment1;
                 else
                    next_state<=increment2;
                 end if;

    when increment2=>if counter=0 then
                         next_state<=a_ajuns2;
                    else
                        next_state<=increment2;
                    end if;
    when a_ajuns2=> if btnR='1' and inc1sec='0' then
                              next_state<=minge_prinsa2;
                     elsif inc1sec='0' then
                           next_state<=a_ajuns2;
                     else
                           next_state<=score_up2;
                    end if;
when minge_prinsa2=>
                            next_state<=mareste_viteza;
                        
    when score_up1=>next_state<=idle_serva;
    when score_up2=>next_state<=idle_serva;
    when others=> next_state<=idle;
end case;
end process;

Switch_player: process(clk,rst)
begin
if rst='1' then
    player<='0';
elsif rising_edge(clk) then
    if current_state=sw_pl then
        player<= not player;
    elsif current_state=idle_serva then
        player<='0';
        end if;
end if;
end process;

Increment_proc: process(clk_div,rst)
begin
if rst = '1' then
        counter <= 0;
    elsif rising_edge(clk_div) then
        if current_state = increment1 then
                counter<=counter+1;  
        elsif current_state=increment2 then
                counter<=counter-1;
        elsif current_state=idle_serva then
            counter<=0;
        end if;
end if;
end process;

  led_process:process(counter)
begin
case counter is 
 when 15=> led <=      "1000000000000000"; 
 when 14=> led <=      "0100000000000000";
 when 13=> led <=      "0010000000000000"; 
 when 12=> led <=      "0001000000000000"; 
 when 11=> led <=      "0000100000000000";
 when 10=> led <=      "0000010000000000";
 when 9=> led <=      "0000001000000000";
 when 8=> led <=      "0000000100000000";
 when 7=> led <=      "0000000010000000";
 when 6=> led <=      "0000000001000000";
 when 5=> led <=      "0000000000100000";
 when 4=> led <=      "0000000000010000";
 when 3=> led <=      "0000000000001000"; 
 when 2=> led <=      "0000000000000100";
 when 1=> led <=      "0000000000000010"; 
 when 0=> led <=      "0000000000000001";
 when others=> led <= "1111111111111111";		
 end case;
end process;

MaresteViteza : process (clk,rst)
begin
    if rst = '1' then
        n <= 625*10**5;
    elsif rising_edge(clk)  then
        if current_state = mareste_viteza then
            n <= n - 10000;
        end if;
    end if;
end process;

MingePrinsa: process(rst, clk)
begin
if rst = '1' then
    en_cnt <= '0';
  elsif rising_edge(clk) then
    if(current_state=a_ajuns1 or current_state=a_ajuns2) then
        en_cnt <= '1';
    else
        en_cnt <= '0';
    end if;  
    end if;   
end process;

ScoreUP : process (clk, rst)
variable unit1, zeci1, unit2, zeci2 : integer range 0 to 9 := 0;
begin
    if rst = '1' then
        score <= (others => '0');
        unit1 := 0;
        unit2 := 0;
        zeci1 := 0;
        zeci2 := 0;
    elsif rising_edge(clk)  then
        if  current_state = score_up1 then
                if unit1 = 9 then
                    unit1 := 0;
                    if zeci1 = 9 then
                        zeci1 := 0;
                    else
                        zeci1 := zeci1 + 1;
                    end if;
                else
                    unit1 := unit1 + 1;
                end if;
              
        elsif current_state = score_up2 then
            if unit2 = 9 then
                unit2 := 0;
                if zeci2 = 9 then
                    zeci2 := 0;
                else
                    zeci2 := zeci2 + 1;
                end if;
            else
                unit2 := unit2 + 1;
        end if;
        end if;
        
score <= std_logic_vector(to_unsigned(zeci2, 4)) & 
        std_logic_vector(to_unsigned(unit2, 4)) & 
        std_logic_vector(to_unsigned(zeci1, 4)) & 
        std_logic_vector(to_unsigned(unit1, 4));
        
end if;
end process;

end Behavioral;
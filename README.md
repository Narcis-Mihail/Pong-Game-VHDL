# This is a Pong Game created using VHDL. I used Basys 3 Artix-7 FPGA Trainer Board to test the code. It works as follows: Initially, LED15 is ON. User 1 uses btnL to start the game. Pressing btnL("serve") turns ON the LEDs  in  the  order  LED15->  LED0.  User  2  must  press btnR when  LED0 is ON.  If  LED0  is “caught”, then the LED sequence is reversed, i.e.the LEDs will turn on in the LED0 -> LED15 order. User 1 must "catch" LED15and so on.When one of the users "misses" the ball, then all LEDslight upfor one second andthe score isincremented, LED15lights up again, and the circuit is waiting for a new "serve".The two most significant digits show the score foruser 1, the next two digits the scorefor user 2. After a ball exchange, if the users do not lose the ball, the speedof the playincreasesgradually.

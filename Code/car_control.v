module car_control(clk, rst, mode, pwm, pwm2, in0, in1, in2, red, green, forward, back, trigger, dur, seg0, seg1, seg2, seg3,seg4, seg5);
input clk, rst;
input in0, in1, in2;
input mode;
input dur;
output trigger;
output [7:0] seg0, seg1, seg2, seg3,seg4, seg5;
output reg pwm, pwm2;
output reg red, green;
output forward, back;

reg [2:0] state;
reg [21:0] cnt;

reg forward_en;
reg rev_en;

wire [2:0] data;
wire [2:0] data_drive;
reg  [21:0] duty_num;
wire [21:0] duty_num_low;
wire [21:0] duty_num_high;
wire lt;
wire in0_sync;
wire in1_sync;
wire in2_sync;
wire mode_sync;
wire [19:0] data_cm;
wire [19:0] data_cm_stop;

wire [3:0] unit; 
wire [3:0] ten;
wire [3:0] hun;
wire [3:0] thou;
wire [3:0] ten_thou;
wire [3:0] hun_thou;

reg [21:0] cnt_inc;
reg [9:0]  cnt_mode;
reg [31:0] cnt_turn;
reg [31:0] cnt_led;
reg [2:0] speed;
reg [2:0] cnt_second;
reg turn_en; 
reg  ld;
reg  hd;

assign lt = (cnt < duty_num);
assign duty_num_low = 22'd0;
assign duty_num_high = 22'd800_000;

assign data = {in2, in1, in0};
assign data_drive = data;
assign data_cm_stop = data_cm;

parameter CNT_MAX = 22'd999_999;
parameter cnt_turn_max = 32'd49_999_999;
parameter CNT_LED_MAX = 32'd49_999_999;
parameter [2:0] zero = 3'd0,
                acc  = 3'd1,
					 dec  = 3'd2,
					 left = 3'd3,
					 right = 3'd4,
					 move_forward = 3'd5,
					 move_back = 3'd6,
					 stop = 3'd7;
					 
parameter [2:0] turn_max_second = 3'd5;
parameter stop_cm = 20'd25;
					 
assign forward = forward_en;
assign back = rev_en;
					 
//declaer the driving mode - forward or reverse
always@(posedge clk or posedge rst)
if (rst)
forward_en <= 1'b0;
else if (mode_sync == 1'b0)
forward_en <= 1'b0;
else if (mode_sync == 1'b1)
forward_en <= 1'b1;
else 
forward_en <= forward_en;


//rev_en
always@(posedge clk or posedge rst)
if (rst)
rev_en <= 1'b0;
else if (mode_sync == 1'b1)
rev_en <= 1'b0;
else if (mode_sync == 1'b0)
rev_en <= 1'b1;
else 
rev_en <= rev_en;


//state decleration
always@(posedge clk or posedge rst)
if (rst)
state <= zero;
else 
case (state)
zero: if (data == 3'd0)
      state <= zero;
		else if (data == 3'd1)
      state <= acc;
		else if (data == 3'd2)
		state <= dec;
		else if (data == 3'd3)
		state <= left;
		else if (data == 3'd4)
		state <= right;
		else if (data == 3'd5)
		state <= move_forward;
		else if (data == 3'd6)
		state <= move_back;
		else if (data == 3'd7)
		state <= stop;
		
acc:  if (data == 3'd0)
      state <= zero;
		else if (data == 3'd1)
      state <= acc;
		else if (data == 3'd2)
		state <= dec;
		else if (data == 3'd3)
		state <= left;
		else if (data == 3'd4)
		state <= right;
		else if (data == 3'd5)
		state <= move_forward;
		else if (data == 3'd6)
		state <= move_back;
		else if (data == 3'd7)
		state <= stop;

dec:  if (data == 3'd0)
      state <= zero;
		else if (data == 3'd1)
      state <= acc;
		else if (data == 3'd2)
		state <= dec;
		else if (data == 3'd3)
		state <= left;
		else if (data == 3'd4)
		state <= right;
		else if (data == 3'd5)
		state <= move_forward;
		else if (data == 3'd6)
		state <= move_back;
		else if (data == 3'd7)
		state <= stop;
		
left: if (data == 3'd0)
      state <= zero;
		else if (data == 3'd1)
      state <= acc;
		else if (data == 3'd2)
		state <= dec;
		else if (data == 3'd3)
		state <= left;
		else if (data == 3'd4)
		state <= right;
		else if (data == 3'd5)
		state <= move_forward;
		else if (data == 3'd6)
		state <= move_back;
		else if (data == 3'd7)
		state <= stop;
		
right: if (data == 3'd0)
      state <= zero;
		else if (data == 3'd1)
      state <= acc;
		else if (data == 3'd2)
		state <= dec;
		else if (data == 3'd3)
		state <= left;
		else if (data == 3'd4)
		state <= right;
		else if (data == 3'd5)
		state <= move_forward;
		else if (data == 3'd6)
		state <= move_back;
		else if (data == 3'd7)
		state <= stop;
		 
move_forward: if (data == 3'd0)
              state <= zero;
		      else if (data == 3'd1)
              state <= acc;
		      else if (data == 3'd2)
		      state <= dec;
		      else if (data == 3'd3)
		      state <= left;
		      else if (data == 3'd4)
		      state <= right;
		      else if (data == 3'd5)
		      state <= move_forward;
		      else if (data == 3'd6)
		      state <= move_back;
		      else if (data == 3'd7)
		      state <= stop;

move_back: if (data == 3'd0)
            state <= zero;
		    else if (data == 3'd1)
            state <= acc;
		    else if (data == 3'd2)
		    state <= dec;
		    else if (data == 3'd3)
		    state <= left;
		    else if (data == 3'd4)
		    state <= right;
		    else if (data == 3'd5)
		    state <= move_forward;
		    else if (data == 3'd6)
		    state <= move_back;
		    else if (data == 3'd7)
		    state <= stop;
			  
stop: if (data == 3'd0)
      state <= zero;
	  else if (data == 3'd1)
      state <= acc;
	  else if (data == 3'd2)
	  state <= dec;
	  else if (data == 3'd3)
	  state <= left;
	  else if (data == 3'd4)
	  state <= right;
	  else if (data == 3'd5)
	  state <= move_forward;
	  else if (data == 3'd6)
	  state <= move_back;
	  else if (data == 3'd7)
	  state <= stop;
		
endcase


//declare when the cnt start
always@(posedge clk or posedge rst)
if (rst)
cnt <= 22'd0;
else if ((state == acc || state == dec || state == left || state == right) && cnt == CNT_MAX)
cnt <= 22'd0;
else if ((state == acc || state == dec || state == left || state == right) && cnt == CNT_MAX)
cnt <= 22'd0;
else if ((state == acc || state == dec || state == left || state == right))
cnt <= cnt + 1'b1;
else if ((state == acc || state == dec || state == left || state == right))
cnt <= cnt + 1'b1;
else 
cnt <= 22'd0;


//calaulate the speed
always@(posedge clk or posedge rst)
if (rst)
cnt_inc <= 22'd0;
else if (cnt_inc == 22'd500 && (state == acc || state == dec))
cnt_inc <= cnt_inc;
else if (state == acc || state == dec)
cnt_inc <= cnt_inc + 1'b1;
else 
cnt_inc <= 22'd0;

always@(posedge clk or posedge rst)
if (rst)
speed <= 3'd0;
else if (state == left || state == right)
speed <= 3'd0;
else if (state == move_forward || state == move_back)
speed <= 3'd0;
else if (speed == 3'd6 && state == acc)
speed <= speed;
else if (speed == 3'd0 && state == dec)
speed <= speed;
else if (cnt_inc == 22'd499 && state == acc)
speed <= speed + 1'b1;
else if (cnt_inc == 22'd499 && state == dec)
speed <= speed - 1'b1;
else 
speed <= speed;

always@(posedge clk or posedge rst)
if(rst)
duty_num <= 22'd0;
else if (data_cm_stop <= stop_cm && forward == 1'b1)
duty_num <= 22'd0;
else if (data_cm_stop <= stop_cm && forward == 1'b0)
duty_num <= speed*22'd100_000;
else if (data_cm_stop > stop_cm)
duty_num <= speed*22'd100_000;

//turnig right or left pwm
always@(posedge clk or posedge rst)
if (rst) 
pwm <= 1'b0;
else 
case (state)
zero: pwm <= 1'b0;
      

acc: pwm  <= lt;

		
dec: pwm  <= lt;


left: pwm <= hd;

right: pwm <= ld;

		 
move_forward: pwm  <= lt;


move_back: pwm  <= lt;

	   
stop: pwm <= 1'b0;
			
endcase

//turnig right or left pwm2
always@(posedge clk or posedge rst)
if (rst)
pwm2 <= 1'b0;
else 
case (state)
zero: pwm2 <= 1'b0;

acc: pwm2 <= lt;

		
dec: pwm2 <= lt;


left: pwm2 <= ld;

right: pwm2 <= hd;

move_forward:pwm2 <= lt;


move_back: pwm2 <= lt;

	   
stop: pwm2 <= 1'b0;
			
endcase


//cnt_turn
always@(posedge clk or posedge rst)
if (rst)
cnt_turn <= 32'd0;
else
case (state)
zero: cnt_turn <= 32'd0;

acc: cnt_turn <= 32'd0;

dec: cnt_turn <= 32'd0;

left: if (cnt_turn == cnt_turn_max)
      cnt_turn <= 32'd0;
		else 
		cnt_turn <= cnt_turn + 1'b1;

right: if (cnt_turn == cnt_turn_max)
       cnt_turn <= 32'd0;
		 else 
		 cnt_turn <= cnt_turn + 1'b1;
		 
move_forward: cnt_turn <= 32'd0;

move_back: cnt_turn <= 32'd0;
		 
stop: cnt_turn <= 32'd0;
		 
endcase 


//cnt_second
always@(posedge clk or posedge rst)
if (rst)
cnt_second <= 3'd0;
else
case (state)
zero: cnt_second <= 3'd0;

acc: cnt_second <= 3'd0;

dec: cnt_second <= 3'd0;

left: if (cnt_second == turn_max_second)
      cnt_second <= cnt_second;
		else if (cnt_turn == cnt_turn_max)
		cnt_second <= cnt_second + 1'b1;

right: if (cnt_second == turn_max_second)
       cnt_second <= cnt_second;
		 else if (cnt_turn == cnt_turn_max)
		 cnt_second <= cnt_second + 1'b1;
		 
move_forward: cnt_second <= 3'd0;

move_back: cnt_second <= 3'd0;
		 
stop: cnt_second <= 3'd0;
		 
endcase 


//turn_en
always@(posedge clk or posedge rst)
if (rst)
turn_en <= 1'b0;
else if ((state == left || state == right) && (cnt_second < turn_max_second))
turn_en <= 1'b1;
else 
turn_en <= 1'b0;


//ld
always@(posedge clk or posedge rst)
if (rst)
ld <= 1'b0;
else if ((state == left || state == right) && turn_en == 1'b1)
ld <= (cnt < duty_num_low);
else
ld <= 1'b0;


//hd
always@(posedge clk or posedge rst)
if (rst)
hd <= 1'b0;
else if ((state == left || state == right) && turn_en == 1'b1)
hd <= (cnt < duty_num_high);
else 
hd <= 1'b0;


//cnt_led
always@(posedge clk or posedge rst)
if (rst)
cnt_led <= 32'd0;
else if ((forward_en == 1'b1 || rev_en == 1'b1) && cnt_led == CNT_LED_MAX)
cnt_led <= 32'd0;
else if (forward_en == 1'b1 || rev_en == 1'b1)
cnt_led <= cnt_led + 1'b1;
else 
cnt_led <= 32'd0;

//green led light
always@(posedge clk or posedge rst)
if (rst)
green <= 1'b0;
else if (forward_en == 1'b0)
green <= 1'b0;
else if (forward_en == 1'b1 && cnt_led == CNT_LED_MAX)
green <= ~green;


//red led light
always@(posedge clk or posedge rst)
if (rst)
red <= 1'b0;
else if (rev_en == 1'b0)
red <= 1'b0;
else if (rev_en == 1'b1 && cnt_led == CNT_LED_MAX)
red <= ~red;

//ultra sonic module for the breaking of car when the distance is smaller then 10cm

sync sync0(
.in(in0), 
.rst(rst), 
.clk(clk), 
.out(in0_sync)
);

sync sync1(
.in(in1), 
.rst(rst), 
.clk(clk), 
.out(in1_sync)
);

sync sync2(
.in(in2), 
.rst(rst), 
.clk(clk), 
.out(in2_sync)
);

sync sync3(
.in(mode), 
.rst(rst), 
.clk(clk), 
.out(mode_sync)
);

sync sync4(
.in(dur), 
.rst(rst), 
.clk(clk), 
.out(dur_sync));

ultra_sonic ultra_sonic_inst
(
.clk(clk),
.rst(rst),
.trigger(trigger),
.dur(dur_sync),
.cm(data_cm)
);
 
bcd_8421 bcd_8421_inst
(
.clk(clk), 
.rst(rst), 
.data(data_cm), 
.unit(unit), 
.ten(ten), 
.hun(hun),
.thou(thou), 
.ten_thou(ten_thou), 
.hun_thou(hun_thou)
);

seven_seg s0(
.en(1'b1),
.in(unit), 
.seg(seg0));
				 
				 
seven_seg s1(
.en(1'b1),
.in(ten), 
.seg(seg1));

seven_seg s2(
.en(1'b1),
.in(hun), 
.seg(seg2));

seven_seg s3(
.en(1'b1),
.in(thou), 
.seg(seg3));

seven_seg s4(
.en(1'b1),
.in(ten_thou), 
.seg(seg4));

seven_seg s5(
.en(1'b1),
.in(hun_thou), 
.seg(seg5));

endmodule
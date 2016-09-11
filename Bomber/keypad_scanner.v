// Read out the four most recently pressed keys and record them in a buffer

module keypad_scanner (clk, col, row, up, down, left, right, action);
  input clk;
  input [0:3] col;
  output reg [0:3] row;
  output reg up, down, left, right, action;

  reg [3:0] key;
  
  reg [1:0] sel, sel_next;
  reg [1:0] state = s_init, state_next;
  reg [0:15] keys_pressed, keys_pressed_next;
  reg up_next, down_next, left_next, right_next, action_next;
  wire scanned_to_3rd_row;
  integer i;

// state encoding
parameter s_init = 2'b00,
          s_scan = 2'b01,
          s_update = 2'b10;
  
// define the key code
parameter key_0 = 4'd0;
parameter key_1 = 4'd1;
parameter key_2 = 4'd2;
parameter key_3 = 4'd3;
parameter key_4 = 4'd4;
parameter key_5 = 4'd5;
parameter key_6 = 4'd6;
parameter key_7 = 4'd7;
parameter key_8 = 4'd8;
parameter key_9 = 4'd9;
parameter key_A = 4'd10;
parameter key_B = 4'd11;
parameter key_C = 4'd12;
parameter key_D = 4'd13;
parameter key_E = 4'd14;
parameter key_F = 4'd15;

// update the sequential signals
always @(posedge clk) begin
    if (state == s_init) begin
      keys_pressed <= 16'h0;
    end
    else keys_pressed <= keys_pressed_next;
    up <= up_next;
    down <= down_next;
    left <= left_next;
    right <= right_next;
    action <= action_next;
    sel <= sel_next;
    state <= state_next;
end

assign scanned_to_3rd_row = (sel == 2'b11) ? 1'b1 : 1'b0;

// define the state transitions and outputs of the finite state machine
always @(*) begin
  // default values
  state_next = s_init;
  up_next = up;
  down_next = down;
  left_next = left;
  right_next = right;
  action_next = action;
  sel_next = 2'b00;
  case(state)
    s_init: begin
      state_next = s_scan;
      up_next = 1'b0;
      down_next = 1'b0;
      left_next = 1'b0;
      right_next = 1'b0;
      action_next = 1'b0;
    end
    s_scan: begin
      if (scanned_to_3rd_row) state_next = s_update;
      else state_next = s_scan;
      sel_next = sel + 1'b1;
    end
    s_update: begin
      state_next = s_scan;
      up_next = 1'b0;
      down_next = 1'b0;
      left_next = 1'b0;
      right_next = 1'b0;
      action_next = 1'b0;
      for (i = 0; i < 16; i = i + 1) begin
        if (keys_pressed[i]) begin
          case (i)
            4'd0:  key = key_F;
            4'd1:  key = key_E;
            4'd2:  key = key_D;
            4'd3:  key = key_C;
            4'd4:  key = key_B;
            4'd5:  key = key_3;
            4'd6:  key = key_6;
            4'd7:  key = key_9;
            4'd8:  key = key_A;
            4'd9:  key = key_2;
            4'd10: key = key_5;
            4'd11: key = key_8;
            4'd12: key = key_0;
            4'd13: key = key_1;
            4'd14: key = key_4;
            4'd15: key = key_7;
            default: key = key_0;
          endcase
          if(key == key_6) up_next = 1'b1;
          if(key == key_5) down_next = 1'b1;
          if(key == key_2) left_next = 1'b1;
          if(key == key_8) right_next = 1'b1;
          if(key == key_0) action_next = 1'b1;
        end
      end
    end
  endcase
end

// to scan rows alternately
always @(*) begin
  row = 4'b1111;
  keys_pressed_next = keys_pressed;
  case (sel)
    2'd0: begin
      row = 4'b0zzz;
      keys_pressed_next[0:3] = ~col;
    end
    2'd1: begin
      row = 4'bz0zz;
      keys_pressed_next[4:7] = ~col;
    end
    2'd2: begin
      row = 4'bzz0z;
      keys_pressed_next[8:11] = ~col;
    end
    2'd3: begin
      row = 4'bzzz0;
      keys_pressed_next[12:15] = ~col;
    end
  endcase
end
endmodule

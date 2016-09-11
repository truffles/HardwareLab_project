
module top(
    input  SYS_CLK,
    input  RECV_PORT1,
    input  RECV_PORT2,
    output TR_PORT1,
    output TR_PORT2,
    output LINK_CLK,
    output [7:0] LCD_DATA,
	output LCD_ENABLE,
	output LCD_RW,
	output LCD_RSTN,
	output LCD_CS1,
	output LCD_CS2,
	output LCD_DI,
    input  [0:3] KEY4X4_col,
    output [0:3] KEY4X4_row
    );
    
    wire [0:15] DATA_BUS;
    wire [0:15] RECV_DATA;
    reg [0:4] KEY_DATA, KEY_DATA_NEXT;
    reg DATA_READY_DELAYED;
    
    assign up2 = KEY_DATA[0];
    assign down2 = KEY_DATA[1];
    assign left2 = KEY_DATA[2];
    assign right2 = KEY_DATA[3];
    assign action2 = KEY_DATA[4];
    
    clk_div c_div (.clock_40MHz (SYS_CLK),
                   .clock_1MHz  (LINK_CLK),
                   .clock_100KHz(LCD_CLK),
                   .clock_1KHz  (KEY_CLK));
    
    keypad_scanner key_scn (KEY_CLK, KEY4X4_col, KEY4X4_row, up, down, left, right, action);
    
    Bomber_Contrl game_logic (SYS_CLK, LINK_CLK, TR_READY,
                              up, down, left, right, action,
                              up2, down2, left2, right2, action2,
                              DATA_BUS, DATA_READY);
    
    lcd_control lcd_ctrl (LCD_CLK, DATA_READY_DELAYED, DATA_BUS,
                          LCD_DATA, LCD_ENABLE, LCD_RW, LCD_RSTN, LCD_CS1, LCD_CS2, LCD_DI);
    
    /*assign LED = {6'b0, KEY_DATA, up, down, left, right, action};*/
    
    transmitter tr (LINK_CLK, 1'b1, DATA_READY, TR_READY, TR_PORT1, TR_PORT2, {DATA_BUS, ~DATA_BUS, DATA_BUS, ~^DATA_BUS});
    
    receiver rc (LINK_CLK, 1'b1, RECV_PORT1, RECV_PORT2, RECV_DATA, RECV_OK);
    
    always @(posedge LINK_CLK) begin
        KEY_DATA <= KEY_DATA_NEXT;
        DATA_READY_DELAYED <= DATA_READY;
    end
    
    always @(*) begin
        KEY_DATA_NEXT = KEY_DATA;
        
        if (RECV_OK) begin
            if (RECV_DATA[0:4] == ~RECV_DATA[5:9] && RECV_DATA[0:4] == RECV_DATA[10:14])
                KEY_DATA_NEXT = RECV_DATA[0:4];
            else if (RECV_DATA[0:4] == ~RECV_DATA[5:9] && (~^RECV_DATA[0:4]) == RECV_DATA[15]) begin
                KEY_DATA_NEXT = RECV_DATA[0:4];
            end
            else if (RECV_DATA[0:4] == RECV_DATA[10:14] && (~^RECV_DATA[0:4]) == RECV_DATA[15]) begin
                KEY_DATA_NEXT = RECV_DATA[0:4];
            end
            else if (~RECV_DATA[5:9] == RECV_DATA[10:14] && (~^RECV_DATA[10:14]) == RECV_DATA[15]) begin
                KEY_DATA_NEXT = RECV_DATA[10:14];
            end
        end
    end
    
endmodule

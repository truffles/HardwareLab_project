
module Bomber_Contrl( 
    input CLK,
    input LINK_CLK,
    input TR_READY,
    input P1_UP,
    input P1_DOWN,
    input P1_LEFT,
    input P1_RIGHT,
    input P1_ACTION,
    input P2_UP,
    input P2_DOWN,
    input P2_LEFT,
    input P2_RIGHT,
    input P2_ACTION,
    output reg [0:15] DATA_BIT,
    output DATA_READY
    );
	
    reg [1:0] GAME_STATE = G_INIT, GAME_STATE_NEXT;
    
	reg [3:0] MATERIAL;
	reg [5:0] P1_X, P1_X_NEXT;
	reg [5:0] P1_SUBX, P1_SUBX_NEXT;
	reg [5:0] P1_Y, P1_Y_NEXT;
	reg [5:0] P1_SUBY, P1_SUBY_NEXT;
	reg [3:0] P1_DIR, P1_DIR_NEXT; // 0:up 1:down 2:left 3:right
	reg [1:0] P1_STATUS, P1_STATUS_NEXT;  // 0: die  1: live
	
    reg [0:159] MAP;
    reg [0:159] MAP_NEXT;
    reg [1:0] INDEX, INDEX_NEXT;
    reg [24:0] PAUSE = 0, PAUSE_NEXT;
    reg [2:0] SCAN_PAUSE, SCAN_PAUSE_NEXT;
	
	reg [1:0] SCAN_DIR, SCAN_DIR_NEXT;
	reg [2:0] OFFSET, OFFSET_NEXT;
	reg [5:0] MAP_POS, MAP_POS_NEXT;
	
    reg [1:0] P1_GO_UP, P1_GO_DOWN, P1_GO_LEFT, P1_GO_RIGHT;
    reg [1:0] P1_GO_UP_NEXT, P1_GO_DOWN_NEXT, P1_GO_LEFT_NEXT, P1_GO_RIGHT_NEXT;
	 
	 reg BUTTON_DETECT, BUTTON_DETECT_NEXT;
	 reg UP_DETECT, UP_DETECT_NEXT;
	 reg DOWN_DETECT, DOWN_DETECT_NEXT;
	 reg LEFT_DETECT, LEFT_DETECT_NEXT;
     reg RIGHT_DETECT, RIGHT_DETECT_NEXT;
     reg PLAYER_STATE, PLAYER_STATE_NEXT; /* 0:P1  1:P2 */
	 
    reg START, START_NEXT;
    reg CLEAR_EXPLODE, CLEAR_EXPLODE_NEXT;
    reg BOMB_COUNT, BOMB_COUNT_NEXT;
    reg EXPLODE, EXPLODE_NEXT;
    reg [0:39] BOMB_MAP, BOMB_MAP_NEXT;
    
    parameter WIDTH = 8,
              HRIGHT = 5;
    parameter S_INIT = 3'd0, S_COUNTDOWN = 3'd1, S_SCAN = 3'd2, S_PHYS = 3'd3, S_PAUSE = 3'd4, S_GAMEOVER = 3'd5;
    parameter G_INIT = 2'b00, G_COUNTDOWN = 2'b01, G_PLAY = 2'b10, G_GAMEOVER = 2'b11;
    parameter AIR = 4'b0000,
              WALL = 4'b0001,
              STONE = 4'b0010,
              BOMB = 4'b1111,
              BOMB_EXPLODE = 4'b1000;
    
    reg [2:0] STATE = S_INIT, STATE_NEXT;
    
    always @(posedge CLK) begin
        if (TR_STATE != T_INTERRUPT) begin
            GAME_STATE <= GAME_STATE_NEXT;
            STATE <= STATE_NEXT;
            MAP <= MAP_NEXT;
            INDEX <= INDEX_NEXT;
            PAUSE <= PAUSE_NEXT;
            SCAN_PAUSE <= SCAN_PAUSE_NEXT;
            SCAN_DIR <= SCAN_DIR_NEXT;
            OFFSET <= OFFSET_NEXT;
            MAP_POS <= MAP_POS_NEXT;
            
            START <= START_NEXT;
            CLEAR_EXPLODE <= CLEAR_EXPLODE_NEXT;
            BOMB_COUNT <= BOMB_COUNT_NEXT;
            EXPLODE <= EXPLODE_NEXT;
            BOMB_MAP <= BOMB_MAP_NEXT;
            
            BUTTON_DETECT <= BUTTON_DETECT_NEXT;
            UP_DETECT <= UP_DETECT_NEXT;
            DOWN_DETECT <= DOWN_DETECT_NEXT;
            LEFT_DETECT <= LEFT_DETECT_NEXT;
            RIGHT_DETECT <= RIGHT_DETECT_NEXT;
            PLAYER_STATE <= PLAYER_STATE_NEXT;
				
            P1_GO_UP <= P1_GO_UP_NEXT;
            P1_GO_DOWN <= P1_GO_DOWN_NEXT;
            P1_GO_LEFT <= P1_GO_LEFT_NEXT;
            P1_GO_RIGHT <= P1_GO_RIGHT_NEXT;
			            
            P1_X <= P1_X_NEXT;
            P1_SUBX <= P1_SUBX_NEXT;
            P1_Y <= P1_Y_NEXT;
            P1_SUBY <= P1_SUBY_NEXT;
            P1_DIR <= P1_DIR_NEXT;
			P1_STATUS <= P1_STATUS_NEXT;
        end
    end
    
    integer i, j;
    
    always @(*) begin
        GAME_STATE_NEXT = GAME_STATE;
        STATE_NEXT = STATE;
        MAP_NEXT = MAP;
        INDEX_NEXT = INDEX;
        PAUSE_NEXT = PAUSE;
        SCAN_PAUSE_NEXT = SCAN_PAUSE;
        SCAN_DIR_NEXT = SCAN_DIR;
        OFFSET_NEXT = OFFSET;
        MAP_POS_NEXT = MAP_POS;
        
        START_NEXT = 1'b0;
        CLEAR_EXPLODE_NEXT = 1'b0;
        BOMB_COUNT_NEXT = 1'b0;
        EXPLODE_NEXT = 1'b0;
        BOMB_MAP_NEXT = BOMB_MAP;
		  
        BUTTON_DETECT_NEXT = 1'b0;
        UP_DETECT_NEXT = 1'b0;
        DOWN_DETECT_NEXT = 1'b0;
        LEFT_DETECT_NEXT = 1'b0;
        RIGHT_DETECT_NEXT = 1'b0;
        PLAYER_STATE_NEXT = PLAYER_STATE;
        
        P1_GO_UP_NEXT = P1_GO_UP;
        P1_GO_DOWN_NEXT = P1_GO_DOWN;
        P1_GO_LEFT_NEXT = P1_GO_LEFT;
        P1_GO_RIGHT_NEXT = P1_GO_RIGHT;
        P1_X_NEXT = P1_X;
        P1_SUBX_NEXT = P1_SUBX;
        P1_Y_NEXT = P1_Y;
        P1_SUBY_NEXT = P1_SUBY;
        P1_DIR_NEXT = P1_DIR;
		P1_STATUS_NEXT = P1_STATUS;
        
        case (STATE)
            S_INIT: begin
                MAP_NEXT[0:31] = {WALL, WALL, STONE, WALL, WALL, STONE, AIR, AIR};
                MAP_NEXT[32:63] = {WALL, WALL, WALL, WALL, WALL, WALL, WALL, AIR};
                MAP_NEXT[64:95] = {STONE, WALL, STONE, WALL, WALL, STONE, WALL, STONE};
                MAP_NEXT[96:127] = {AIR, WALL, WALL, WALL, WALL, WALL, WALL, WALL};
                MAP_NEXT[128:159] = {AIR, AIR, STONE, WALL, WALL, STONE, WALL, WALL};
                
                if (PAUSE != 0) 
                    PAUSE_NEXT = PAUSE - 1;
                else if (P1_ACTION || P2_ACTION) begin
                    STATE_NEXT = S_COUNTDOWN;
                    GAME_STATE_NEXT = G_COUNTDOWN;
                end
                
                SCAN_PAUSE_NEXT = 0;
                INDEX_NEXT = 2'b11;
                SCAN_DIR_NEXT = 2'b00;
                OFFSET_NEXT = 1;
                MAP_POS_NEXT = 0;
                
                P1_X_NEXT = 6'b100000;
                P1_SUBX_NEXT = 6'b000000;
                P1_Y_NEXT = 6'b000111;
                P1_SUBY_NEXT = 6'b000000;
                P1_DIR_NEXT = 4'b0101;
				P1_STATUS_NEXT = 2'b11;
                
                PLAYER_STATE_NEXT = 1'b0;
            end
            
            S_COUNTDOWN: begin
                if (PAUSE == 25'b1_11111111_11111111_11111111) begin
                    INDEX_NEXT = INDEX - 1;
                    if (INDEX == 2'b00) begin
                        STATE_NEXT = S_PHYS;
                        GAME_STATE_NEXT = G_PLAY;
                    end
                end
                PAUSE_NEXT = PAUSE + 1;
            end
            
            S_SCAN: begin
                
                if (START) begin
                    if (SCAN_PAUSE[1:0] == 0) begin
                        CLEAR_EXPLODE_NEXT = 1'b1;
                        MAP_POS_NEXT = 0;
                    end
                    SCAN_PAUSE_NEXT = SCAN_PAUSE + 1;
                end
                else if (CLEAR_EXPLODE) begin
                    if (MAP_POS < 40) begin
                        if (MAP[(MAP_POS * 4) +: 4] == BOMB_EXPLODE)
                            MAP_NEXT[(MAP_POS * 4) +: 4] = AIR;
                        MAP_POS_NEXT = MAP_POS + 1;
                        CLEAR_EXPLODE_NEXT = 1'b1;
                    end
                    else begin
                        BOMB_COUNT_NEXT = 1'b1;
                        MAP_POS_NEXT = 0;
                        BOMB_MAP_NEXT = 0;
                    end
                end
                else if (BOMB_COUNT) begin
                    if (MAP_POS < 40) begin
                        if (SCAN_PAUSE[2] == 1'b1 && MAP[(MAP_POS * 4)] == 1'b1 && MAP[(MAP_POS * 4) +: 4] != BOMB_EXPLODE) begin
                            MAP_NEXT[(MAP_POS * 4) +: 4] = MAP[(MAP_POS * 4) +: 4] - 1;
                            if(MAP_NEXT[(MAP_POS * 4) +: 4] == BOMB_EXPLODE)
                                BOMB_MAP_NEXT[MAP_POS] = 1'b1;
                        end
                        if (SCAN_PAUSE[2] == 1'b0 && MAP[(MAP_POS * 4) +: 4] == 4'b1001) begin
                            MAP_NEXT[(MAP_POS * 4) +: 4] = BOMB_EXPLODE;
                            BOMB_MAP_NEXT[MAP_POS] = 1'b1;
                        end
                            
                        MAP_POS_NEXT = MAP_POS + 1;
                        BOMB_COUNT_NEXT = 1'b1;
                    end
                    else begin
                        EXPLODE_NEXT = 1'b1;
                        MAP_POS_NEXT = 0;
                        OFFSET_NEXT = 1;
                        SCAN_DIR_NEXT = 0;
                    end
                end
                else if (EXPLODE) begin
                    if (MAP_POS < 40) begin
                        
                        EXPLODE_NEXT = 1'b1;
                        
                        if (BOMB_MAP[MAP_POS]) begin
                        
                            if (P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS) begin
                                P1_STATUS_NEXT[0] = 1'b0;
                            end
                            if (P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS) begin
                                P1_STATUS_NEXT[1] = 1'b0;
                            end
                            
                            case (SCAN_DIR)
                                2'b00: begin
                                    if (MAP_POS < (OFFSET * 8)) begin
                                            SCAN_DIR_NEXT = 2'b01;
                                            OFFSET_NEXT = 1;
                                    end
                                    else begin
                                        MATERIAL = MAP[((MAP_POS - (OFFSET * 8)) * 4) +: 4];
                                        if (MATERIAL == AIR || MATERIAL == WALL) begin
                                            MAP_NEXT[((MAP_POS - (OFFSET * 8)) * 4) +: 4] = BOMB_EXPLODE;
                                            
                                            if ((P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS - (OFFSET * 8)) || ((P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS - (OFFSET * 8) - 1) && P1_SUBY[2:0] != 0)) begin
                                                P1_STATUS_NEXT[0] = 1'b0;
                                            end
                                            if (P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS - (OFFSET * 8) || ((P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS - (OFFSET * 8) - 1) && P1_SUBY[5:3] != 0)) begin
                                                P1_STATUS_NEXT[1] = 1'b0;
                                            end
                                        end
                                        else if (MATERIAL[3] && MATERIAL[2:1] != 0) 
                                            MAP_NEXT[((MAP_POS - (OFFSET * 8)) * 4) +: 4] = 4'b1001; // about to explode
                                        if (MATERIAL != AIR) begin
                                            SCAN_DIR_NEXT = 2'b01;
                                            OFFSET_NEXT = 1;
                                        end else OFFSET_NEXT = OFFSET + 1;
                                    end
                                end
                                
                                2'b01: begin
                                    if (MAP_POS + (OFFSET * 8) > 39) begin
                                        SCAN_DIR_NEXT = 2'b10;
                                        OFFSET_NEXT = 1;
                                    end
                                    else begin
                                        MATERIAL = MAP[((MAP_POS + (OFFSET * 8)) * 4) +: 4];
                                        if (MATERIAL == AIR || MATERIAL == WALL) begin
                                            MAP_NEXT[((MAP_POS + (OFFSET * 8)) * 4) +: 4] = BOMB_EXPLODE;
                                            
                                            if (P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS + (OFFSET * 8) || ((P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS + (OFFSET * 8) - 1) && P1_SUBY[2:0] != 0)) begin
                                                P1_STATUS_NEXT[0] = 1'b0;
                                            end
                                            if (P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS + (OFFSET * 8) || ((P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS + (OFFSET * 8) - 1) && P1_SUBY[5:3] != 0)) begin
                                                P1_STATUS_NEXT[1] = 1'b0;
                                            end
                                        end
                                        else if (MATERIAL[3] && MATERIAL[2:1] != 0) 
                                            MAP_NEXT[((MAP_POS + (OFFSET * 8)) * 4) +: 4] = 4'b1001; // about to explode
                                        
                                        if(MATERIAL != AIR) begin
                                            SCAN_DIR_NEXT = 2'b10;
                                            OFFSET_NEXT = 1;
                                        end else OFFSET_NEXT = OFFSET + 1;
                                    end
                                end
                                
                                2'b10: begin
                                    if ((MAP_POS % 8) < OFFSET) begin
                                        SCAN_DIR_NEXT = 2'b11;
                                        OFFSET_NEXT = 1;
                                    end
                                    else begin
                                        MATERIAL = MAP[((MAP_POS - OFFSET) * 4) +: 4];
                                        if (MATERIAL == AIR || MATERIAL == WALL) begin
                                            MAP_NEXT[((MAP_POS - OFFSET) * 4) +: 4] = BOMB_EXPLODE;
                                            
                                            if (P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS - OFFSET || ((P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS - OFFSET - 8) && P1_SUBX[2:0] != 0)) begin
                                                P1_STATUS_NEXT[0] = 1'b0;
                                            end
                                            if (P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS - OFFSET || ((P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS - OFFSET - 8) && P1_SUBX[5:3] != 0)) begin
                                                P1_STATUS_NEXT[1] = 1'b0;
                                            end
                                        end
                                        else if (MATERIAL[3] && MATERIAL[2:1] != 0) 
                                            MAP_NEXT[((MAP_POS - OFFSET) * 4) +: 4] = 4'b1001; // about to explode
                                        
                                        if(MATERIAL != AIR) begin
                                            SCAN_DIR_NEXT = 2'b11;
                                            OFFSET_NEXT = 1;
                                        end else OFFSET_NEXT = OFFSET + 1;
                                    end
                                end
                                
                                2'b11: begin
                                    if ((MAP_POS % 8) + OFFSET > 7) begin
                                        SCAN_DIR_NEXT = 2'b00;
                                        OFFSET_NEXT = 1;
                                        MAP_POS_NEXT = MAP_POS + 1;
                                    end
                                    else begin
                                        MATERIAL = MAP[((MAP_POS + OFFSET) * 4) +: 4];
                                        if (MATERIAL == AIR || MATERIAL == WALL) begin
                                            MAP_NEXT[((MAP_POS + OFFSET) * 4) +: 4] = BOMB_EXPLODE;
                                            
                                            if (P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS + OFFSET || ((P1_X[2:0]*8 + P1_Y[2:0] == MAP_POS + OFFSET - 8) && P1_SUBX[2:0] != 0)) begin
                                                P1_STATUS_NEXT[0] = 1'b0;
                                            end
                                            if (P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS + OFFSET || ((P1_X[5:3]*8 + P1_Y[5:3] == MAP_POS - OFFSET - 8) && P1_SUBX[5:3] != 0)) begin
                                                P1_STATUS_NEXT[1] = 1'b0;
                                            end
                                        end
                                        else if (MATERIAL[3] && MATERIAL[2:1] != 0) 
                                            MAP_NEXT[((MAP_POS + OFFSET) * 4) +: 4] = 4'b1001; // about to explode
                                        
                                        if(MATERIAL != AIR) begin
                                            SCAN_DIR_NEXT = 2'b00;
                                            MAP_POS_NEXT = MAP_POS + 1;
                                            OFFSET_NEXT = 1;
                                        end else OFFSET_NEXT = OFFSET + 1;
                                    end
                                end
                                
                            endcase
                        end
                        else MAP_POS_NEXT = MAP_POS + 1;
                        
                    end
                end
                else begin
                    STATE_NEXT = S_PAUSE;
                end
                
                
            end
				
            S_PHYS: begin
                
                if (BUTTON_DETECT) begin
                    if(PLAYER_STATE == 1'b0) begin 
                        if (P1_UP & ~P1_DOWN) begin
                              P1_GO_UP_NEXT[0] = 1'b1;
                              P1_GO_DOWN_NEXT[0] = 1'b0;
                        end else if (~P1_UP & P1_DOWN) begin
                              P1_GO_DOWN_NEXT[0] = 1'b1;
                              P1_GO_UP_NEXT[0] = 1'b0;
                        end
                        if (P1_LEFT & ~P1_RIGHT) begin
                              P1_GO_LEFT_NEXT[0] = 1'b1;
                              P1_GO_RIGHT_NEXT[0] = 1'b0;
                        end else if (~P1_LEFT & P1_RIGHT) begin
                              P1_GO_RIGHT_NEXT[0] = 1'b1;
                              P1_GO_LEFT_NEXT[0] = 1'b0;
                        end
                    end
                    else begin
                        if (P2_UP & ~P2_DOWN) begin
                              P1_GO_UP_NEXT[1] = 1'b1;
                              P1_GO_DOWN_NEXT[1] = 1'b0;
                        end else if (~P2_UP & P2_DOWN) begin
                              P1_GO_DOWN_NEXT[1] = 1'b1;
                              P1_GO_UP_NEXT[1] = 1'b0;
                        end
                        if (P2_LEFT & ~P2_RIGHT) begin
                              P1_GO_LEFT_NEXT[1] = 1'b1;
                              P1_GO_RIGHT_NEXT[1] = 1'b0;
                        end else if (~P2_LEFT & P2_RIGHT) begin
                              P1_GO_RIGHT_NEXT[1] = 1'b1;
                              P1_GO_LEFT_NEXT[1] = 1'b0;
                        end
                    end
                    
                    UP_DETECT_NEXT = 1'b1;
                end
                else if (UP_DETECT) begin
                    DOWN_DETECT_NEXT = 1'b1;
                    if (P1_GO_UP[PLAYER_STATE]) begin
                        P1_DIR_NEXT[PLAYER_STATE * 2 +: 2] = 2'b00;
                        
                        if(P1_X[PLAYER_STATE * 3 +: 3] != 0 || P1_SUBX[PLAYER_STATE * 3 +: 3] != 0) begin
                            if (P1_SUBX[PLAYER_STATE * 3 +: 3] != 0) begin
                                P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBX[PLAYER_STATE * 3 +: 3] - 1;
                                if (P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] == 0) P1_GO_UP_NEXT[PLAYER_STATE] = 1'b0;
                            end
                            else begin
                                     
                                if (P1_SUBY[PLAYER_STATE * 3 +: 3] == 0) begin
                                    if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 32) +: 4] == AIR || 
                                        MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 32) +: 4] == BOMB_EXPLODE)) begin
                                        P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = 5;
                                        P1_X_NEXT[PLAYER_STATE * 3 +: 3] = P1_X[PLAYER_STATE * 3 +: 3] - 1;
                                    end else P1_GO_UP_NEXT[PLAYER_STATE] = 1'b0;
                                end
                                else if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 32) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 32) +: 4] == BOMB_EXPLODE)
                                         && (MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4 + 4) - 32) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4 + 4) - 32) +: 4] == BOMB_EXPLODE)) begin
                                        P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = 5;
                                        P1_X_NEXT[PLAYER_STATE * 3 +: 3] = P1_X[PLAYER_STATE * 3 +: 3] - 1;
                                end else P1_GO_UP_NEXT[PLAYER_STATE] = 1'b0;
                            end
                        end else P1_GO_UP_NEXT[PLAYER_STATE] = 1'b0;
                    end
                end
                else if (DOWN_DETECT) begin
                    LEFT_DETECT_NEXT = 1'b1;
                    
                    if (P1_GO_DOWN[PLAYER_STATE]) begin
                        P1_DIR_NEXT[PLAYER_STATE * 2 +: 2] = 2'b01;
                    
                        if(P1_X[PLAYER_STATE * 3 +: 3] < 4) begin
                        if(P1_SUBX[PLAYER_STATE * 3 +: 3] != 0) begin
                            if(P1_SUBX[PLAYER_STATE * 3 +: 3] == 5) begin
                                P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = 0;
                                P1_X_NEXT[PLAYER_STATE * 3 +: 3] = P1_X[PLAYER_STATE * 3 +: 3] + 1;
                                P1_GO_DOWN_NEXT[PLAYER_STATE] = 1'b0;
                            end
                            else P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBX[PLAYER_STATE * 3 +: 3] + 1;
                        end
                        else begin
                            
                            if (P1_SUBY[PLAYER_STATE * 3 +: 3] == 0) begin
                                if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 32) +: 4] == AIR || 
                                    MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 32) +: 4] == BOMB_EXPLODE)) begin
                                    P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBX[PLAYER_STATE * 3 +: 3] + 1;
                                end else P1_GO_DOWN_NEXT[PLAYER_STATE] = 1'b0;
                            end
                            else if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 32) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 32) +: 4] == BOMB_EXPLODE)
                                  && (MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4 + 4) + 32) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4 + 4) + 32) +: 4] == BOMB_EXPLODE)) begin
                                    P1_SUBX_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBX[PLAYER_STATE * 3 +: 3] + 1;
                            end else P1_GO_DOWN_NEXT[PLAYER_STATE] = 1'b0;
                        end
                    end else P1_GO_DOWN_NEXT[PLAYER_STATE] = 1'b0;
                end
                end
                else if (LEFT_DETECT) begin
                    RIGHT_DETECT_NEXT = 1'b1;
                    
                    if (P1_GO_LEFT[PLAYER_STATE]) begin
                        P1_DIR_NEXT[PLAYER_STATE * 2 +: 2] = 2'b10;
                    
                        if( P1_Y[PLAYER_STATE * 3 +: 3] != 0 || P1_SUBY[PLAYER_STATE * 3 +: 3] != 0) begin 
                            if(P1_SUBY[PLAYER_STATE * 3 +: 3] != 0) begin
                                P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBY[PLAYER_STATE * 3 +: 3] - 1;
                                if (P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3]== 0) P1_GO_LEFT_NEXT[PLAYER_STATE] = 1'b0;
                            end
                            else begin
                                
                                if (P1_SUBX[PLAYER_STATE * 3 +: 3] == 0) begin
                                    if(MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 4) +: 4] == AIR ||
                                       MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 4) +: 4] == BOMB_EXPLODE) begin
                                       P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = 5;
                                       P1_Y_NEXT[PLAYER_STATE * 3 +: 3] = P1_Y[PLAYER_STATE * 3 +: 3] - 1;
                                    end else P1_GO_LEFT_NEXT[PLAYER_STATE] = 1'b0;
                                end
                                else if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 4) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 4) +: 4] == BOMB_EXPLODE)
                                      && (MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32 + 32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 4) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32 + 32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) - 4) +: 4] == BOMB_EXPLODE)) begin
                                        P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = 5;
                                        P1_Y_NEXT[PLAYER_STATE * 3 +: 3] = P1_Y[PLAYER_STATE * 3 +: 3] - 1;
                                end else P1_GO_LEFT_NEXT[PLAYER_STATE] = 1'b0;
                            end
                        end else P1_GO_LEFT_NEXT[PLAYER_STATE] = 1'b0;
                    end
                end
                else if (RIGHT_DETECT) begin
                    if (P1_GO_RIGHT[PLAYER_STATE]) begin
                        P1_DIR_NEXT[PLAYER_STATE * 2 +: 2] = 2'b11;
                        
                        if(P1_Y[PLAYER_STATE * 3 +: 3] < 7) begin
                            if(P1_SUBY[PLAYER_STATE * 3 +: 3] != 0) begin
                                if(P1_SUBY[PLAYER_STATE * 3 +: 3] == 5) begin
                                    P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = 0;
                                    P1_Y_NEXT[PLAYER_STATE * 3 +: 3] = P1_Y[PLAYER_STATE * 3 +: 3] + 1;
                                    P1_GO_RIGHT_NEXT[PLAYER_STATE] = 1'b0;
                                end
                                else P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBY[PLAYER_STATE * 3 +: 3] + 1;
                            end
                            else begin
                                
                                if (P1_SUBX[PLAYER_STATE * 3 +: 3] == 0) begin
                                    if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 4) +: 4] == AIR || 
                                        MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 4) +: 4] == BOMB_EXPLODE)) begin
                                        P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBY[PLAYER_STATE * 3 +: 3] + 1;
                                    end else P1_GO_RIGHT_NEXT[PLAYER_STATE] = 1'b0;
                                end
                                else if ((MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 4) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 4) +: 4] == BOMB_EXPLODE)
                                      && (MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32 + 32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 4) +: 4] == AIR || MAP[((P1_X[PLAYER_STATE * 3 +: 3]*32 + 32) + (P1_Y[PLAYER_STATE * 3 +: 3]*4) + 4) +: 4] == BOMB_EXPLODE)) begin
                                        P1_SUBY_NEXT[PLAYER_STATE * 3 +: 3] = P1_SUBY[PLAYER_STATE * 3 +: 3] + 1;
                                end else P1_GO_RIGHT_NEXT[PLAYER_STATE] = 1'b0;
                            end
                        end else P1_GO_RIGHT_NEXT[PLAYER_STATE] = 1'b0;
                    end
                end
				else begin
                    if (PLAYER_STATE == 1'b0) begin
                        if(P1_ACTION && MAP[((P1_X[2:0]+(P1_SUBX[2:0] > 3 ? 1 : 0))*32) + ((P1_Y[2:0]+(P1_SUBY[2:0] > 3 ? 1 : 0))*4) +: 4] == AIR)
                            MAP_NEXT[((P1_X[2:0]+(P1_SUBX[2:0] > 3 ? 1 : 0))*32) + ((P1_Y[2:0]+(P1_SUBY[2:0] > 3 ? 1 : 0))*4) +: 4] = BOMB;
                        PLAYER_STATE_NEXT = 1'b1;
                        BUTTON_DETECT_NEXT = 1'b1;
                    end
                    else begin
                        if(P2_ACTION && MAP[((P1_X[5:3]+(P1_SUBX[5:3] > 3 ? 1 : 0))*32) + ((P1_Y[5:3]+(P1_SUBY[5:3] > 3 ? 1 : 0))*4) +: 4] == AIR)
                            MAP_NEXT[((P1_X[5:3]+(P1_SUBX[5:3] > 3 ? 1 : 0))*32) + ((P1_Y[5:3]+(P1_SUBY[5:3] > 3 ? 1 : 0))*4) +: 4] = BOMB;
                        PLAYER_STATE_NEXT = 1'b0;
                        STATE_NEXT = S_SCAN;
                        START_NEXT = 1'b1;
                    end
                    
                end
                
            end
            
            S_PAUSE: begin
                
                if (P1_STATUS != 2'b11) begin
                    STATE_NEXT = S_GAMEOVER;
                    GAME_STATE_NEXT = G_GAMEOVER;
                end
                else begin
                    PAUSE_NEXT = PAUSE + 1;
                    
                    if (PAUSE == 25'b0_00011111_11111111_11111111) begin
                        PAUSE_NEXT = 0;
                        STATE_NEXT = S_PHYS;
                        BUTTON_DETECT_NEXT = 1'b1;
                    end
               end
            end
            
            S_GAMEOVER: begin
                if (P1_ACTION || P2_ACTION) begin
                    PAUSE_NEXT = 26'b01_11111111_11111111_11111111;
                    STATE_NEXT = S_INIT;
                    GAME_STATE_NEXT = G_INIT;
                end
            end
        endcase
    end
    
    reg [1:0] TR_STATE = T_IDLE, TR_STATE_NEXT;
    reg [5:0] TR_COUNTER, TR_COUNTER_NEXT;
    reg [0:15] DATA_BIT_NEXT;
    
    assign DATA_READY = (TR_STATE == T_TRANSMIT);
    
    parameter T_IDLE = 2'd0,
              T_INTERRUPT = 2'd1,
              T_PAUSE = 2'd2,
              T_TRANSMIT = 2'd3;
    
    always @(posedge LINK_CLK) begin
        TR_STATE <= TR_STATE_NEXT;
        TR_COUNTER <= TR_COUNTER_NEXT;
        DATA_BIT <= DATA_BIT_NEXT;
    end
    
    always @(*) begin
        TR_STATE_NEXT = TR_STATE;
        TR_COUNTER_NEXT = TR_COUNTER;
        DATA_BIT_NEXT = DATA_BIT;
        
        case (TR_STATE)
            T_IDLE: begin
                if (TR_READY) TR_STATE_NEXT = T_INTERRUPT;
            end
            
            T_INTERRUPT: begin // Game logic will 'pause' while in this state
                TR_STATE_NEXT = T_PAUSE;
                
                // First 40 for block state
                if (TR_COUNTER < 40) begin
                    DATA_BIT_NEXT = {3'b100, TR_COUNTER, MAP[TR_COUNTER * 4 +: 4], 3'b0};
                end
                else if (TR_COUNTER == 40) begin
                    DATA_BIT_NEXT = {1'b0, P1_X[2:0], P1_SUBX[2:0], P1_Y[2:0], P1_SUBY[2:0], 1'b0, P1_DIR[1:0]};
                end
                else if (TR_COUNTER == 41) begin
                    DATA_BIT_NEXT = {1'b0, P1_X[5:3], P1_SUBX[5:3], P1_Y[5:3], P1_SUBY[5:3], 1'b1, P1_DIR[3:2]};
                end
                else if (TR_COUNTER == 42) begin
                    DATA_BIT_NEXT = {1'b1, 2'b10, GAME_STATE, INDEX, P1_STATUS[0], P1_STATUS[1], 7'b0};
                end
                
                if (TR_COUNTER == 6'd42) TR_COUNTER_NEXT = 0;
                else TR_COUNTER_NEXT = TR_COUNTER + 1;
            end
            
            T_PAUSE: begin
                TR_STATE_NEXT = T_TRANSMIT;
            end
            
            T_TRANSMIT: begin
                if (~TR_READY) TR_STATE_NEXT = T_IDLE;
            end
            
        endcase
    end
endmodule

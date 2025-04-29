module MainControl( //????? ???????????
    input left_button,right_button,clk,
    output [15:0] row, //Dot Matrix Row
    output [15:0] col, //Dot Matrix Col
    output [7:0] LCD_DATA, //LCD?????
    output LCD_RW,LCD_EW,LCD_EN,LCD_RS,LCD_RST
); 
    wire reverse;//????
    wire loading;//?????
    wire left,right;//???
    wire [1:0] obstacle_type; //?????
    wire [4:0] obstacle_location_x; //?????
    wire [2:0] Fruit_type; //????
    wire [3:0] Fruit_location; //????
    wire [1:0] heat; //??
    wire hit_obstacle; //?????????
    wire hit_fruit,enlarge,zoomout,addheat,subheat,done;
    InputHandler I0(clk,left_button,right_button,reverse,left,right); //??????(????)
    DisplayControl D0(clk,left,right,obstacle_type,obstacle_location_x,Fruit_type,Fruit_location,zoomout,done,row,col,loading,hit_obstacle,hit_fruit);//????
    LCDDisplay L0(clk,heat,enlarge,zoomout,reverse,addheat,subheat,LCD_DATA,LCD_RW,LCD_EW,LCD_EN,LCD_RS,LCD_RST);//??LCDM??
    ObstacleFruitGen O0(clk,loading,Fruit_type,Fruit_location,obstacle_type,obstacle_location_x);//??????????
    FruitEffectHandler F0(clk,hit_fruit,Fruit_type,enlarge,zoomout,addheat,subheat,reverse);//??????
    Heatcontroller H0(clk,hit_obstacle,enlarge,addheat,subheat,heat,done);//????
endmodule

module InputHandler(//??????(????)
    input clk,
    input left_button,right_button,reverse,
    output reg left,right
);
    always @(posedge clk) begin 
        if(reverse) begin//????
            if(left_button) {right,left} <= 2'b10; //turn right
            else if (right_button) {right,left} <= 2'b01; //turn left
            else {right,left} <= 2'b00; //keep going
        end
        else begin 
            if(left_button) {right,left} <= 2'b01; //turn right
            else if (right_button) {right,left} <= 2'b10; //turn left
            else {right,left} <= 2'b00; //keep going            
        end
    end
endmodule

module DisplayControl( //?????? ??????LCDM???
    input clk,
    input left,right, //??????
    input [1:0] obstacle_type, //?????
    input [4:0] obstacle_location_x, //?????
    input [2:0] Fruit_type, //????
    input [3:0] Fruit_location, //????
    input zoomout,
    input done,
    output reg [15:0] row,
    output reg [15:0] col,
    output reg loading,
    output reg hit_obstacle,
    output reg hit_fruit
); 
    reg [3:0] next_state,state;
    reg [4:0] obstacle_row;//?????????????
    reg [3:0] Fruit_row;
    reg [9:0] clk_div; //???1000Hz?clk???
    wire game_tick;
    wire car_tick;
    reg update; //????????
    reg can_left,can_right; //???????
    reg [3:0] x12[1:0],x13[1:0],x14[1:0],x15[1:0]; //????
    initial begin //???
        x12[0] = 4'd7;
        x12[1] = 4'd8;
        x13[0] = 4'd6;
        x13[1] = 4'd9;
        x14[0] = 4'd7;
        x14[1] = 4'd8;
        x15[0] = 4'd6;
        x15[1] = 4'd9;
        {update,obstacle_row,Fruit_row,clk_div} = 4'd0;
    end
    always @(posedge clk) begin //???
        if(clk_div == 10'd512) clk_div <= 10'd1;
        else clk_div <= clk_div + 1;
    end
    assign game_tick = (clk_div==10'd512);//????512? Game_tick??
    assign car_tick = (clk_div==10'd512||clk_div==10'd384||clk_div==10'd256||clk_div==10'd128); //???512 or 256 ? car_tick??
    always @(*) begin  //????????
        if(x12[0]==4'd1||x13[0]==4'd1||x14[0]==4'd1||x15[0]==4'd1) can_left = 1'b0;
        else can_left = 1'b1;
        if(x12[1]==4'd14||x13[1]==4'd14||x14[0]==4'd1||x15[1]==4'd14) can_right =1'b0;
        else can_right = 1'b1;
    end
    always @(posedge car_tick) begin //car tick Positive??????????????
        if(right&&can_right) begin //??
            x12[0] <= x12[0] + 1'b1;
            x12[1] <= x12[1] + 1'b1;
            x13[0] <= x13[0] + 1'b1;
            x13[1] <= x13[1] + 1'b1;
            x14[0] <= x14[0] + 1'b1;
            x14[1] <= x14[1] + 1'b1;
            x15[0] <= x15[0] + 1'b1;
            x15[1] <= x15[1] + 1'b1;
        end
        else if(left&&can_left) begin //??
            x12[0] <= x12[0] - 1'b1;
            x12[1] <= x12[1] - 1'b1;
            x13[0] <= x13[0] - 1'b1;
            x13[1] <= x13[1] - 1'b1;
            x14[0] <= x14[0] - 1'b1;
            x14[1] <= x14[1] - 1'b1;
            x15[0] <= x15[0] - 1'b1;
            x15[1] <= x15[1] - 1'b1;            
        end
        else;
    end
    always @(posedge clk) begin //State Transiton for row scanning
        state <= next_state; 
        loading <= 1'b1;//??????????,???????????
        if(game_tick) begin //??
            if(Fruit_type!=3'd0&&Fruit_row < 4'd15) Fruit_row <= Fruit_row + 4'd1;
            if(obstacle_row < 4'd15) obstacle_row <= obstacle_row + 4'd1; //???????
            else begin
                loading <= 1'd0;
                Fruit_row <= 4'd0;
                obstacle_row <= 4'd0;
            end
            update <= ~update; //????
        end
    end
    integer i;
    always @(*) begin
        col <= 16'd0;
        if(game_tick) {hit_obstacle,hit_fruit} <= 2'd0;
        case(state) 
            16'd0:begin
                row <= 16'd1;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd0) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd0||(obstacle_row>=4'd0&&obstacle_row<=4'd3)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd0||(obstacle_row>=4'd0&&obstacle_row<=4'd3)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd0||(obstacle_row>=4'd0&&obstacle_row<=4'd4)) //?????or?????????
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd0||(Fruit_row>=4'd0&&Fruit_row<=4'd1)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd0||Fruit_row==4'd1)
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd0) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd1) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd2)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd0) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd1) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd2) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd0) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd1;
            end
            16'd1:begin
                row <= 16'd2;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd1) //?????1????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd1||(obstacle_row>=4'd1&&obstacle_row<=4'd4)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd1||(obstacle_row>=4'd1&&obstacle_row<=4'd4)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd1||(obstacle_row>=4'd1&&obstacle_row<=4'd5)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd1||(Fruit_row>=4'd1&&Fruit_row<=4'd2)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd1||(Fruit_row>=4'd1&&Fruit_row<=4'd2))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd1) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd2) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd3)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd1) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd2) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd3) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd1) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd2;                                
            end
            16'd2:begin
                row <= 16'd4;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd2) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd2||(obstacle_row>=4'd2&&obstacle_row<=4'd5)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd2||(obstacle_row>=4'd2&&obstacle_row<=4'd5)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd2||(obstacle_row>=4'd2&&obstacle_row<=4'd6)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd2||(Fruit_row>=4'd2&&Fruit_row<=4'd3)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd2||(Fruit_row>=4'd2&&Fruit_row<=4'd3))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd2) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd3) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd4)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd2) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd3) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd4) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd2) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd3;                                
            end
            16'd3:begin
                row <= 16'd8;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd3) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd3||(obstacle_row>=4'd3&&obstacle_row<=4'd6)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd3||(obstacle_row>=4'd3&&obstacle_row<=4'd6)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd3||(obstacle_row>=4'd3&&obstacle_row<=4'd7)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd3||(Fruit_row>=4'd3&&Fruit_row<=4'd4)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd3||Fruit_row==4'd4)
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd3) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd4) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd5)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd3) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd4) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd5) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd3) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd4;                                
            end
            16'd4:begin
                row <= 16'd16;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd4) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd4||(obstacle_row>=4'd4&&obstacle_row<=4'd7)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd4||(obstacle_row>=4'd4&&obstacle_row<=4'd7)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd4||(obstacle_row>=4'd4&&obstacle_row<=4'd8)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd4||(Fruit_row>=4'd4&&Fruit_row<=4'd5)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd4||(Fruit_row>=4'd4&&Fruit_row<=4'd5))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd4) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd5) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd6)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd4) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd5) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd6) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd4) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd5;                                
            end
            16'd5:begin
                row <= 16'd32;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd5) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd5||(obstacle_row>=4'd5&&obstacle_row<=4'd8)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd5||(obstacle_row>=4'd5&&obstacle_row<=4'd8)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd5||(obstacle_row>=4'd5&&obstacle_row<=4'd9)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd5||(Fruit_row>=4'd5&&Fruit_row<=4'd6)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd5||(Fruit_row>=4'd5&&Fruit_row<=4'd6))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd5) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd6) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd7)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd5) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd6) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd7) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd5) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd6;                           
            end
            16'd6:begin
                row <= 16'd64;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd6) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd6||(obstacle_row>=4'd6&&obstacle_row<=4'd9)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd6||(obstacle_row>=4'd6&&obstacle_row<=4'd9)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd6||(obstacle_row>=4'd6&&obstacle_row<=4'd10)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd6||(Fruit_row>=4'd6&&Fruit_row<=4'd7)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd6||(Fruit_row>=4'd6&&Fruit_row<=4'd7))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd6) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd7) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd8)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd6) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd7) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd8) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd6) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd7;                                
            end
            16'd7:begin
                row <= 16'd128;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd7) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd7||(obstacle_row>=4'd7&&obstacle_row<=4'd10)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd7||(obstacle_row>=4'd7&&obstacle_row<=4'd10)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd7||(obstacle_row>=4'd7&&obstacle_row<=4'd11)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd7||(Fruit_row>=4'd7&&Fruit_row<=4'd10)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd7||Fruit_row==4'd8)
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd7) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd8) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd9)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd7) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd8) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd9) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd7) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end    
                next_state <= 16'd8;                            
            end
            16'd8:begin
                row <= 16'd256;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd8) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd8||(obstacle_row>=4'd8&obstacle_row<=4'd11)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd8||(obstacle_row>=4'd8&&obstacle_row<=4'd11)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd8||(obstacle_row>=4'd8&&obstacle_row<=4'd12)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd8||(Fruit_row>=4'd8&&Fruit_row<=4'd9)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd8||(Fruit_row>=4'd8&&Fruit_row<=4'd9))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd8) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd9) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd10)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd8) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd9) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd10) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd8) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end 
                next_state <= 16'd9;                               
            end
            16'd9:begin
                row <= 16'd512;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd9) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd9||(obstacle_row>=4'd9&&obstacle_row<=4'd12)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd9||(obstacle_row>=4'd9&&obstacle_row<=4'd12)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd9||(obstacle_row>=4'd9&&obstacle_row<=4'd13)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd9||(Fruit_row>=4'd9&&Fruit_row<=4'd10)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd9||(Fruit_row>=4'd9&&Fruit_row<=4'd10))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd9) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd10) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd11)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd9) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd10) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd11) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd9) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd10;                                
            end
            16'd10:begin
                row <= 16'd1024;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd10) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd10||(obstacle_row>=4'd10&&obstacle_row<=4'd13)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd10||(obstacle_row>=4'd10&&obstacle_row<=4'd13)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd10||(obstacle_row>=4'd10&&obstacle_row<=4'd14)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd10||(Fruit_row>=4'd10&&Fruit_row<=4'd11)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd10||(Fruit_row>=4'd10&&Fruit_row<=4'd11))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd10) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd11) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd12)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd10) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd11) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd12) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd10) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd11;                                
            end
            16'd11:begin
                row <= 16'd2048;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd11) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd11||(obstacle_row>=4'd11&&obstacle_row<=4'd14)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd11||(obstacle_row>=4'd11&&obstacle_row<=4'd14)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd11||(obstacle_row>=4'd11&&obstacle_row<=4'd15)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd11||(Fruit_row>=4'd11&&Fruit_row<=4'd12)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd11||(Fruit_row>=4'd11&&Fruit_row==4'd12))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd11) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd12) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd13)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd11) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd12) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd13) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd11) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                next_state <= 16'd12;                                
            end
            16'd12:begin
                row <= 16'd4096;
                col[x12[0]] <= 1'b1; //print car location 
                col[x12[1]] <= 1'b1; //print car loction
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd12) //?????0????
                        for(i=0;i<4;i=i+1) begin
                            col[obstacle_location_x+i] <= 1'b1;
                            if(obstacle_row==4'd12&&(x12[0]==obstacle_location_x+i||x12[1]==obstacle_location_x+i||x13[0]==obstacle_location_x+i||x13[1]==obstacle_location_x+i)) hit_obstacle <= 1'b1;
                        end
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd12||(obstacle_row>=4'd12&&obstacle_row<=4'd15)) //?????or?????????
                        for(i=0;i<4;i=i+1) begin
                            col[obstacle_location_x+i] <= 1'b1;
                            if(obstacle_row==4'd12&&(x12[0]==obstacle_location_x+i||x12[1]==obstacle_location_x+i||x13[0]==obstacle_location_x+i||x13[1]==obstacle_location_x+i)) hit_obstacle <= 1'b1;                          
                        end
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd12||(obstacle_row>=4'd12&&obstacle_row<=4'd15)) begin //?????or?????????
                        col[obstacle_location_x] <= 1'b1;
                        if(obstacle_row==4'd12&&(x12[0]==obstacle_location_x||x12[1]==obstacle_location_x||x13[0]==obstacle_location_x||x13[1]==obstacle_location_x)) hit_obstacle <= 1'b1;
                    end
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd12||(obstacle_row>=4'd12&&obstacle_row-4'd1<=4'd15)) //?????or???????1?
                        for(i=0;i<3;i=i+1) begin
                            col[obstacle_location_x+i] <= 1'b1;
                            if(obstacle_row==4'd12&&(x12[0]==obstacle_location_x+i||x12[1]==obstacle_location_x+i||x13[0]==obstacle_location_x+i||x13[1]==obstacle_location_x+i)) hit_obstacle <= 1'b1;                            
                        end
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd12||(Fruit_row>=4'd12&&Fruit_row<=4'd13)) //?????or?????????
                            for(i=0;i<2;i=i+1) begin
                                col[Fruit_location+i] <= 1'b1;
                                if(Fruit_row==4'd12&&(x12[0]==Fruit_location+i||x12[1]==Fruit_location+i||x13[0]==Fruit_location+i||x13[0]==Fruit_location+i)) hit_fruit <= 1'b1;
                            end
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd12||(Fruit_row>=4'd12&&Fruit_row<=4'd13)) begin
                            col[Fruit_location] <= 1'b1;
                            if(Fruit_row==4'd12&&(x12[0]==Fruit_location||x12[1]==Fruit_location||x13[0]==Fruit_location||x13[1]==Fruit_location)) hit_fruit <= 1'b1;
                        end
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd12) begin
                            col[Fruit_location+1] <= 1'b1;
                            if(Fruit_row==4'd12&&(x12[0]==Fruit_location+1||x12[1]==Fruit_location+1||x13[0]==Fruit_location+1||x13[1]==Fruit_location+1)) hit_fruit <= 1'b1;
                        end
                        else if(Fruit_row==4'd13) begin
                            col[Fruit_location+1] <= 1'b1;
                            //if(Fruit_row==4'd12&&(x12[0]==Fruit_location+1||x12[1]==Fruit_location+1||x13[0]==Fruit_location+1||x13[1]==Fruit_location+1)) hit_fruit <= 1'b1;                        
                        end
                        else if(Fruit_row==4'd14)
                            for(i=0;i<3;i=i+1) begin
                                col[Fruit_location+i] <= 1'b1;
                                //if(Fruit_row==4'd12&&(x12[0]==Fruit_location+i||x12[1]==Fruit_location+i||x13[0]==Fruit_location+i||x13[1]==Fruit_location+i)) hit_fruit <= 1'b1;
                            end
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd12) begin
                            col[Fruit_location+1] <= 1'b1;
                            if(Fruit_row==4'd12&&(x12[0]==Fruit_location+1||x12[1]==Fruit_location+1||x13[0]==Fruit_location+1||x13[1]==Fruit_location+1)) hit_fruit <= 1'b1;                      
                        end
                        else if(Fruit_row==4'd13) 
                            for(i=0;i<3;i=i+1) begin
                                col[Fruit_location+i] <= 1'b1;
                                //if(x12[0]==Fruit_location+i||x12[1]==Fruit_location+i||x13[0]==Fruit_location+i||x13[1]==Fruit_location+i) hit_fruit <= 1'b1;
                            end
                        else if(Fruit_row==4'd14) begin 
                            col[Fruit_location+1] <= 1'b1;
                            //if(x12[0]==Fruit_location+1||x12[1]==Fruit_location+1||x13[0]==Fruit_location+1||x13[1]==Fruit_location+1) hit_fruit <= 1'b1;
                        end
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd12) 
                            for(i=0;i<2;i=i+1) begin
                                col[Fruit_location+i] <= 1'b1;
                                if(x12[0]==Fruit_location+i||x12[1]==Fruit_location+i||x13[0]==Fruit_location+i||x13[0]==Fruit_location+i) hit_fruit <= 1'b1;
                            end
                    end
                end
                else;
                next_state <= 16'd13;                               
            end
            16'd13:begin
                row <= 16'd8192;
                if(update) {col[0],col[15]} <= 2'b11;//??????
                else {col[0],col[15]} <= 2'b00; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd13) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd13||(obstacle_row>=4'd13&&obstacle_row<=4'd15)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd13||(obstacle_row>=4'd13&&obstacle_row<=4'd15)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd13||(obstacle_row>=4'd13&&obstacle_row<=4'd15)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd13||(Fruit_row>=4'd13&&Fruit_row<=4'd14)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd13||(Fruit_row>=4'd13&&Fruit_row==4'd14))
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd13) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd14) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd15)
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd13) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd14) 
                            for(i=0;i<3;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else if(Fruit_row==4'd15) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd13) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                if(zoomout==1'b1) begin
                    col[x13[0]-1] <= 1'b1; //print car location
                    col[x13[1]-1] <= 1'b1; //print car location
                end
                else begin
                    col[x13[0]] <= 1'b1; //print car location
                    col[x13[1]] <= 1'b1; //print car location
                end                 
                next_state <= 16'd14;                                
            end
            16'd14:begin
                row <= 16'd16384;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd14) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd14||(obstacle_row>=4'd14&&obstacle_row<=4'd15)) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd14||(obstacle_row>=4'd14&&obstacle_row<=4'd15)) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd14||(obstacle_row>=4'd14&&obstacle_row<=4'd15)) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd14||(Fruit_row>=4'd14&&Fruit_row<=4'd15)) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd14)
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd14) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd15) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd14) col[Fruit_location+1] <= 1'b1;
                        else if(Fruit_row==4'd15) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd14) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                col[x14[0]] <= 1'b1; //print car location
                col[x14[1]] <= 1'b1; //print car location                        
                next_state <= 16'd15;                        
            end
            16'd15:begin
                row <= 16'd32768;
                if(update) {col[0],col[15]} <= 2'b00;//??????
                else {col[0],col[15]} <= 2'b11; //??????
                if(obstacle_type==2'b00) begin //4??????
                    if(obstacle_row==4'd15) //?????0????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b01) begin //4x4????
                    if(obstacle_row==4'd15) //?????or?????????
                        for(i=0;i<4;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else if(obstacle_type==2'b10) begin //4??????
                    if(obstacle_row==4'd15) //?????or?????????
                        col[obstacle_location_x] <= 1'b1; 
                    else;
                end
                else if(obstacle_type==2'b11) begin //3x5????
                    if(obstacle_row==4'd15) //?????or???????1?
                        for(i=0;i<3;i=i+1) col[obstacle_location_x+i] <= 1'b1;
                    else;
                end
                else;
                if(Fruit_type!=3'd0) begin //????
                    if(Fruit_type==3'd1) begin //???? ???2*2????
                        if(Fruit_row==4'd15) //?????or?????????
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd2) begin //???? ???1*2????
                        if(Fruit_row==4'd15)
                            col[Fruit_location] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd3) begin //???? ???T
                        if(Fruit_row==4'd15) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd4) begin //???? ???+
                        if(Fruit_row==4'd15) col[Fruit_location+1] <= 1'b1;
                        else;
                    end
                    else if(Fruit_type==3'd5) begin //?0?? ???4*1?-?
                        if(Fruit_row==4'd15) 
                            for(i=0;i<2;i=i+1) col[Fruit_location+i] <= 1'b1;
                        else;
                    end
                end
                if(zoomout==1'b1) begin
                    col[x15[0]-1] <= 1'b1; //print car location
                    col[x15[1]-1] <= 1'b1; //print car location                    
                end
                else begin
                    col[x15[0]] <= 1'b1; //print car location
                    col[x15[1]] <= 1'b1; //print car location
                end    
                next_state <= 16'd0;                             
            end
            default : next_state <= 16'd0;
        endcase
    end   
endmodule

module LCDDisplay( //???????? ??LCDM??
    input clk,
    input [1:0] heat,
    input enlarge,zoomout,reverse,addheat,subheat,   
    output reg [7:0] LCD_DATA, //LCD?????
    output reg LCD_RW,LCD_EW,LCD_EN,LCD_RS,LCD_RST
);
    reg [127:0] row1,row2; //?????
    reg [127:0] row1_temp,row2_temp;
    reg [3:0] state;
    reg [17:0] counter;
    reg [5:0] DATA_INDEX;
    wire [7:0] DATA;
    initial {state,counter,DATA_INDEX} = 3'd0;
    always @(*) begin
        if(heat==2'b00) row1 <= {"Heat:"-{5{8'h20}},8'h0a,8'h0a,8'h0a,{8{8'h5f}}};
        else if(heat==2'b01) row1 <= {"Heat:"-{5{8'h20}},8'h0a,8'h0a,{9{8'h5f}}};
        else if(heat==2'b10) row1 <= {"Heat:"-{5{8'h20}},8'h0a,{10{8'h5f}}};
        else if(heat==2'b11) row1 <= "Game over       " - {16{8'h20}};
        if(heat!=2'b11) begin
            if(enlarge) row2 <= {"State: Strong   "} - {16{8'h20}};  
            else if(zoomout) row2 <= {"State: Zoomout  "} - {16{8'h20}};
            else if(reverse) row2 <= {"State: Reverse  "} - {16{8'h20}};
            else if(addheat) row2 <= {"State: Addheat  "} - {16{8'h20}};
            else if(subheat) row2 <= {"State: Subheat  "} - {16{8'h20}};
            else row2 <= {"State: None     "} - {16{8'h20}};
        end
        else row2 <= {16{8'h5f}};
    end
    LCDM_table M1(row1_temp,row2_temp,DATA_INDEX,DATA); //??LCD_table
    always @(posedge clk) begin
        case(state) //select state
            4'd0:begin //IDLE Reset LCDM ????
                row1_temp <= row1; //?row1??temp
                row2_temp <= row2; //?row2??temp
                LCD_RST <= 1'b1; //Reset
                state <= 4'd1;
            end
            4'd1:begin
                if(DATA_INDEX == 6'd32) state <= 4'd5;
                else state	<= 4'd2;
                LCD_RST		<= 1'b0;
            end
            4'd2:begin // set RS,EN,RW,DATA
                LCD_EN	<= 1'b1;
                LCD_RS	<= 1'b1;
                LCD_RW	<= 1'b0;
                LCD_RST	<= 1'b0;
                LCD_DATA <= DATA[7:0]; //?DATA??LCD?
                state <= 4'd3;
            end
            4'd3:begin // Delay
                if(counter< 18'd1)
                    counter	<= counter+18'd1;
                else
                    state <= 4'd4;
            end
            4'd4:begin
                LCD_EN	<= 1'b0;
                counter	<= 18'd0;	
                DATA_INDEX	<= DATA_INDEX+6'd1;
                state <= 4'd1;
            end
            4'd5:begin
                DATA_INDEX <= 6'd0;
                //??????LCD???????? 
                if(row1_temp!=row1||row2_temp!=row2) state <= 4'd0;
                else state <= 4'd5; //???????????
            end
            default: state <= 4'd0; //????
        endcase
    end
endmodule

module	LCDM_table(
    input [127:0] row1,row2, //?????
    input [5:0]table_index,
    output reg [7:0]data_out
);
    always@(table_index)begin
        case(table_index) //Display 1st page
            6'd0: data_out  = row1[127:120];
            6'd1: data_out  = row1[119:112]; 
            6'd2: data_out  = row1[111:104];
            6'd3: data_out  = row1[103:96];
            6'd4: data_out  = row1[95:88];
            6'd5: data_out  = row1[87:80];
            6'd6: data_out  = row1[79:72];
            6'd7: data_out  = row1[71:64];
            6'd8: data_out  = row1[63:56];
            6'd9: data_out  = row1[55:48];
            6'd10: data_out = row1[47:40];
            6'd11: data_out = row1[39:32];
            6'd12: data_out = row1[31:24];
            6'd13: data_out = row1[23:16];
            6'd14: data_out = row1[15:8];
            6'd15: data_out = row1[7:0];
            6'd16: data_out = row2[127:120];
            6'd17: data_out = row2[119:112];
            6'd18: data_out = row2[111:104];
            6'd19: data_out = row2[103:96];
            6'd20: data_out = row2[95:88];
            6'd21: data_out = row2[87:80];
            6'd22: data_out = row2[79:72];
            6'd23: data_out = row2[71:64];
            6'd24: data_out = row2[63:56];
            6'd25: data_out = row2[55:48];
            6'd26: data_out = row2[47:40];
            6'd27: data_out = row2[39:32];
            6'd28: data_out = row2[31:24];
            6'd29: data_out = row2[23:16];
            6'd30: data_out = row2[15:8];
            6'd31: data_out = row2[7:0];
        endcase
    end
endmodule

module ObstacleFruitGen(//????????
    input clk,
    input loading,
    output reg [2:0] Fruit_type,
    output reg [3:0] Fruit_location,
    output [1:0] obstacle_type,
    output [4:0] obstacle_location_x
);  
    parameter [2:0] enlarge=3'd1,reduce=3'd2,opposite=3'd3,double=3'd4,return=3'd5;
    //??Obstacle
    random_generator r1(loading,obstacle_type,obstacle_location_x);
    integer obstacle_length;
    reg [4:0] Fruit_length;
    //??Obstacle Length?Fruit Length
    always @(obstacle_type) begin 
        case(obstacle_type)
            2'b00 : obstacle_length = 4;
            2'b01 : obstacle_length = 4;
            2'b10 : obstacle_length = 1;
            2'b11 : obstacle_length = 3;
            default : obstacle_length = 0;
        endcase
    end
    //??Fruit
    integer max_attempts;
    wire have_fruit;
    probability_generator p1(clk,have_fruit); //?25%????????
    reg [2:0] LFSR1 = 3'd1; 
    reg [3:0] LFSR2 = 4'b1000;
    always @(negedge loading) begin //????
        max_attempts = 10; //?????
        if(have_fruit == 1'b1) begin
            LFSR1 = {LFSR1[1:0], LFSR1[2] ^ LFSR1[1]}; //??????
            if(LFSR1 == 3'd0) begin //???0
                LFSR1 = 3'd1;
                Fruit_type = 3'd1;
            end
            else if(LFSR1==3'd6) begin
                if(Fruit_type==3'd0) Fruit_type = 3'd2;
                else Fruit_type = LFSR1%Fruit_type + 3'd1;
            end
            else if(LFSR1==3'd7) begin
                if(Fruit_type==3'd0) Fruit_type = 3'd3;
                else Fruit_type = LFSR1%Fruit_type + 3'd1;
            end
            else Fruit_type= LFSR1;
            //??fruit Length 
            case(Fruit_type)
                3'd0 : Fruit_length = 5'd0;
                3'd1 : Fruit_length = 5'd2;
                3'd2 : Fruit_length = 5'd1;
                3'd3 : Fruit_length = 5'd3;
                3'd4 : Fruit_length = 5'd3;
                3'd5 : Fruit_length = 5'd3;
                default : Fruit_length = 5'd0;
            endcase
            //??fruit??
            if(Fruit_type==enlarge) begin//????????? (???2*2????)
            //?????????
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                //??????????
                while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd14||({1'b0,LFSR2}>=obstacle_location_x&&{1'b0,LFSR2}<=(obstacle_location_x+obstacle_length))||({1'b0,LFSR2}<=obstacle_location_x)&&{1'b0,LFSR2}>=(obstacle_location_x-Fruit_length))&&max_attempts>0) begin
                    LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                    max_attempts = max_attempts - 1;
                end
                if(max_attempts==0) begin //????????
                    if(obstacle_location_x >= 5'd7) Fruit_location = 4'd1;
                    else Fruit_location = 4'd12;
                end
                else Fruit_location = LFSR2;
            end
            else if(Fruit_type==reduce) begin //????????? (???1*2??)
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                while((LFSR2==4'd0||LFSR2==4'd15||{1'b0,LFSR2}==obstacle_location_x||{1'b0,(LFSR2+4'd1)}==obstacle_location_x)&&max_attempts>0) begin
                    LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                    max_attempts = max_attempts - 1;
                end
                Fruit_location = LFSR2;
            end
            else if(Fruit_type==opposite) begin //????????? (???T)
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd14||LFSR2==4'd13||({1'b0,LFSR2}>=obstacle_location_x&&{1'b0,LFSR2}<=(obstacle_location_x+obstacle_length))||({1'b0,LFSR2}<=obstacle_location_x)&&{1'b0,LFSR2}>=(obstacle_location_x-Fruit_length))&&max_attempts>0) begin
                    LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                    max_attempts = max_attempts - 1;
                end
                if(max_attempts==0) begin //????????
                    if(obstacle_location_x >= 5'd7) Fruit_location = 4'd1;
                    else Fruit_location = 4'd12;
                end
                else Fruit_location = LFSR2;
            end
            else if(Fruit_type==double) begin //????????? (???+) 
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd14||LFSR2==4'd13||({1'b0,LFSR2}>=obstacle_location_x&&{1'b0,LFSR2}<=(obstacle_location_x+obstacle_length))||({1'b0,LFSR2}<=obstacle_location_x)&&{1'b0,LFSR2}>=(obstacle_location_x-Fruit_length))&&max_attempts>0) begin
                    LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                    max_attempts = max_attempts - 1;
                    Fruit_location = 4'd10;
                end
                if(max_attempts==0) begin //????????
                    if(obstacle_location_x >= 5'd7) Fruit_location = 4'd1;
                    else Fruit_location = 4'd12;
                end
                else Fruit_location = LFSR2;            
            end
            else if(Fruit_type==return) begin //????0???? (???-)
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd14||LFSR2==4'd13||({1'b0,LFSR2}>=obstacle_location_x&&{1'b0,LFSR2}<=(obstacle_location_x+obstacle_length))||({1'b0,LFSR2}<=obstacle_location_x)&&{1'b0,LFSR2}>=(obstacle_location_x-Fruit_length))&&max_attempts>0) begin
                    LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                    max_attempts = max_attempts - 1;
                end
                if(max_attempts==0) begin //????????
                    if(obstacle_location_x >= 5'd7) Fruit_location = 4'd1;
                    else Fruit_location = 4'd12;
                end
                else Fruit_location = LFSR2;
            end
            else;       
        end
        else Fruit_type <= 3'd0;
    end
endmodule

module probability_generator ( // 0.25 ?????
    input clk,                
    output reg have_fruit // ????????
);
    reg [7:0] LFSR1 = 8'b00000001; // ??? 8 ? LFSR
    reg [5:0] LFSR2 = 6'b000001;   // ??? 6 ? LFSR

    always @(posedge clk) begin 
        LFSR1 <= {LFSR1[6:0], LFSR1[7] ^ LFSR1[5] ^ LFSR1[4] ^ LFSR1[3]}; //??LFSR
        LFSR2 <= {LFSR2[4:0], LFSR2[5] ^ LFSR2[3]}; //??LFSR
        //??? LFSR ????
        if ((LFSR1[7:6] ^ LFSR2[5:4]) == 2'b00) have_fruit <= 1'b1; //about 25%???
        else have_fruit <= 1'b0;
    end
endmodule

module random_generator(
    input loading, //clk???????????
    output reg [1:0] obstacle_type, //????? (??or??or??or???)
    output reg [4:0] random_number_x
);
   //?????????
   reg [15:0] LFSR1 = 16'b1010101010101010;
   reg [3:0] LFSR2 = 4'b0011;
   reg [3:0] temp;
   integer max_attempts; //????????
   always @(negedge loading) begin
        max_attempts = 10;
        LFSR1 = {LFSR1[14:0],LFSR1[15]^LFSR1[14]^LFSR1[12]^LFSR1[3]};
        temp = {LFSR1[15], LFSR1[10], LFSR1[5], LFSR1[0]}; //??lFSR
        obstacle_type = ((temp[3:2]&temp[1:0])^(temp[2:1]|temp[3:2])) % 4;  //?%4??00/01/10/11?????
        if(obstacle_type==2'b00) begin //????4bits???
            LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
            while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd12||LFSR2==4'd13||LFSR2==4'd14)&&max_attempts>0) begin
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                max_attempts = max_attempts - 1;
            end
            if(max_attempts == 0) random_number_x = 5'd7; //???
            else random_number_x = {1'b0,LFSR2};
        end
        else if(obstacle_type==2'b01) begin //????4*4bits????
            LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
            while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd12||LFSR2==4'd13||LFSR2==4'd14)&&max_attempts>0) begin
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                max_attempts = max_attempts - 1;
            end
            if(max_attempts == 0) random_number_x = 5'd7; //???
            else random_number_x = {1'b0,LFSR2};
        end
        else if(obstacle_type==2'b10) begin //?????? 
            LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
            while((LFSR2==4'd0||LFSR2==4'd15)&&max_attempts>0) begin
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                max_attempts = max_attempts - 1;
            end
            random_number_x = {1'b0,LFSR2}; 
        end
        else begin //?????? 3*5 
            while((LFSR2==4'd0||LFSR2==4'd15||LFSR2==4'd14||LFSR2==4'd13)&&max_attempts>0) begin
                LFSR2 = {LFSR2[2:0],LFSR2[3]^LFSR2[2]};
                max_attempts = max_attempts - 1;
            end
            if(max_attempts == 0) random_number_x = 5'd7; //???
            else random_number_x = {1'b0,LFSR2};     
        end
    end
endmodule

module FruitEffectHandler( //??????
    input clk,
    input hit_fruit,
    input [2:0] Fruit_type,
    output reg enlarge,
    output reg zoomout,
    output reg addheat,
    output reg subheat,
    output reg reverse
);
    reg [15:0] counter;
    initial {enlarge,zoomout,addheat,subheat,reverse} = 5'd0;
    initial counter = 16'd0;
    always @(posedge clk) begin
        if(counter==16'd8000) counter <= 16'd0;
        else if(enlarge||zoomout||addheat||subheat||reverse||counter!=16'd0) counter <= counter + 16'd1;
        else;
    end 
    always @(posedge hit_fruit) begin
        if(hit_fruit) begin
            case(Fruit_type)
                3'd1: begin
                    enlarge <= 1'b1;
                    {zoomout,reverse,addheat,subheat} <= 4'd0;
                    counter <= 16'd0;
                end
                3'd2: begin
                    zoomout <= 1'b1;
                    {enlarge,reverse,addheat,subheat} <= 4'd0;
                    counter <= 16'd0;
                end
                3'd3: begin
                    reverse <= 1'b1;
                    {enlarge,zoomout,addheat,subheat} <= 4'd0;
                    counter <= 16'd0;
                end
                3'd4: begin
                    addheat <= 1'b1;
                    {enlarge,zoomout,addheat,subheat} <= 4'd0;
                    counter <= 16'd0;
                end
                3'd5: begin
                    subheat <= 1'b1;
                    {enlarge,zoomout,reverse,addheat} <= 4'd0;
                    counter <= 16'd0;
                end
                default: {enlarge,zoomout,addheat,subheat,reverse} <= 5'b00000;
            endcase
        end
    end
endmodule

module Heatcontroller(
	input clk,
    input hit_obstacle,
    input enlarge,
    input addheat, //??
    input subheat, //??
    output reg [1:0] heat,//??
    output reg done
);
    //initial heat = 2'b11;
    always @(posedge hit_obstacle or posedge addheat or posedge subheat) begin
			if(hit_obstacle) begin
				if(enlarge!=1'b1) begin
					heat = heat + 2'd1;
					if(heat==2'b11) done = 1'b1; //game over
				end
			end
			if(addheat) begin
				if(heat==2'b00) heat = heat;
				else heat = heat - 2'd1;
			end
			if(subheat) begin
				heat = heat + 2'd1;
			end
	end
endmodule
// number of product=3
// price of product = 10,15,20
// number of states =5(S0,S5,S10,S15,S20)
// Coins allowed 5,10,20:
// no coin =00;
// coin 5 = 01;
// coin 10 = 10;
// coin 20 = 11;
// sel=00=none
// sel=01=prdA
// sel=10=prdB
// sel=11=prdC
// for now the quantity is 1.

module machine(
    input       clk,
    input       rst,
    input       cancel,
    input  [1:0]coin,
    input  [1:0]sel,
    output reg  change,
    output reg  prdA,
    output reg  prdB,
    output reg  prdC
);



    parameter S0=3'b000, S5=3'b001, S10=3'b010, S15=3'b011, S20=3'b100;


//  STATE TRANSITIONS

    always @(posedge clk or posedge rst) begin
        if(rst)begin
            current_state<=S0;
        end
        else 
            current_state<=next_state;
        end

    
    reg [2:0]current_state;
    reg [2:0]next_state;
    
    
    always @(*) begin    
        next_state=current_state;          
        case (current_state)                            
            S0:begin                        
                if (coin == 2'b01)      next_state=S5;
                else if (coin == 2'b10) next_state=S10;
                else if (coin == 2'b11) next_state=S20;
                end
            S5:begin
                if(cancel)              next_state=S0;
                else if (coin == 2'b01) next_state=S10;
                else if (coin == 2'b10) next_state=S15;
                else                    next_state=S20;
                end   
            S10:begin
                if (cancel)             next_state=S0;
                else if(sel==2'b01)     next_state=S0;     //priority is given to sel over coin
                else if (coin ==2'b01)  next_state=S15;
                else                    next_state=S20;
                end
            S15:begin
                if (cancel)             next_state=S0;
                else if(sel==2'b01)     next_state=S0;
                else if(sel==2'b10)     next_state=S0;
                else                    next_state=S20;
                end
            S20:begin
                if (cancel)             next_state=S0;
                else if(sel==2'b01)     next_state=S0;
                else if(sel==2'b10)     next_state=S0;
                else if(sel==2'b11)     next_state=S0;
                end
            default:                    next_state=S0;
        endcase
    end


    // LOGIC DESIGN
    

    always @(*) begin  
            prdA = 0;
            prdB = 0;
            prdC = 0;
            change = 0;
            if (cancel && current_state != S0) begin
                change = 1;
            end
            else begin
            case (current_state)                                           
            
            S10:begin
                if (sel==2'b01) begin
                    prdA    =1'b1;
                    change  =0;
                end  
                 
            end
            S15:begin
                if (sel==2'b01) begin
                    prdA    =1'b1;
                    change  =1'b1;
                end
                else if(sel == 2'b10) begin
                    prdB    =1'b1;
                    change  =0;
                end
            
            end
            S20:begin
                if (sel == 2'b01)begin
                    prdA    =1'b1;
                    change  =1'b1;
                end
                else if (sel == 2'b10)begin
                    prdB     =1'b1;
                    change   =1'b1;
                end
                else if (sel == 2'b11)begin
                    prdC    =1'b1;
                    change  =0;
                end
            end 
                 
        endcase
    end
    end
endmodule

module machine_tb;
    reg clk,rst,cancel;
    reg [1:0]coin,sel;
    wire change,prdA,prdB,prdC;

    machine dut(.clk(clk),.rst(rst),.cancel(cancel),.coin(coin),.sel(sel),
                .change(change),.prdA(prdA),.prdB(prdB),.prdC(prdC));

    initial clk=0;
    always #5 clk = ~clk;

    initial begin
        rst=1;
        cancel=0;
        coin=2'b00;
        sel=2'b00;
        #10 rst=0;
        #10
        sel=11; #10   
        coin=01; #10
        coin=10; #10
        coin=01; #10   //prdc=1 and change=0

        sel=11; #10   
        coin=01; #10
        coin=10; #10
        coin=11; #10   //prdc=1 and change=1  here is problem regarding the coin amount longest path with max amount

        sel=01; #10
        coin=10; #10   // prdb=1 change=0

        sel=10; #10
        coin=01;#10
        coin=11;#10  // prdb=1 and change=1    here is same problem

        sel=10;#10
        coin=01;#10
        coin=01;#10  // prdb=1 and change=0

        coin=01;#10
        cancel=1;#10
        cancel=0;#10  //prd=0 and change =1


        #20 $finish;
    end

    initial begin
    $dumpfile("machine.vcd");   // waveform file
    $dumpvars(0, machine_tb);   // dump all signals
    end


    // initial begin
    //     $monitor("Time=%d,rst=%b,Coin=%b,Sel=%b,Cancel=%b,prdA=%b,prdB=%b,prdC=%b,change=%b",
    //             $time,rst,coin,sel,cancel,prdA,prdB,prdC,change);
    // end
    always @(posedge clk) begin
    $display("T=%0t |coin=%b  |  state=%b | cancel=%b  | sel=%b | prdA=%b | prdB=%b | prdC=%b | change=%b",
              $time,coin,dut.current_state, cancel, sel, prdA, prdB, prdC, change);
    end

    

    
endmodule
module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

reg [12:0]cycle=13'd0;
reg [2:0]state=3'd0;


always @ (posedge clk)
begin
    if(rst)
    	begin
       	cycle<=13'd0;
       	state<=3'd0;
    	R<=1'b0;
      	G<=1'b1;
       	Y<=1'b0;
    	end
    else if(pass)
	begin
	cycle<=cycle+1'd1;
	    if(state == 3'd0)
	    begin
	        if(cycle == 13'd1023)
		begin
            	state<=3'd1;
		cycle<=13'd0;
		R<=1'b0;
            	G<=1'b0;
            	Y<=1'b0;
		end
	    end
	    else
	    	begin
          	cycle<=13'd0;
          	state<=3'd0;
		R<=1'b0;
          	G<=1'b1;
          	Y<=1'b0;
		end
	end
    else
    	begin
	cycle<=cycle+1'd1;
        case(state)
	    3'd0:
	    begin
            	if(cycle == 13'd1023)
          	begin
                    state<=3'd1;
		    cycle<=13'd0;
	  	    R<=1'b0;
          	    G<=1'b0;
                    Y<=1'b0;
            	end
            end
	    3'd1:
	    begin
	    	if(cycle == 13'd127)
                begin
                    state<=3'd2;
	 	    cycle<=13'd0;
                    R<=1'b0;
                    G<=1'b1;
                    Y<=1'b0;
                end
            end
            3'd2:
	    begin
                if(cycle == 13'd127)
                begin
                    state<=3'd3;
		    cycle<=13'd0;
                    R<=1'b0;
                    G<=1'b0;
                    Y<=1'b0;
                end
            end
            3'd3:
	    begin
                if(cycle == 13'd127)
            	begin
                    state<=3'd4;
		    cycle<=13'd0;
                    R<=1'b0;
            	    G<=1'b1;
                    Y<=1'b0;
                end
            end
            3'd4:
	    begin
                if(cycle == 13'd127)
                begin
                    state<=3'd5;
		    cycle<=13'd0;
	            R<=1'b0;
                    G<=1'b0;
                    Y<=1'b1;
                end
            end
            3'd5:
 	    begin
	        if(cycle == 13'd511)
                begin
                    state<=3'd6;
	 	    cycle<=13'd0;
	            R<=1'b1;
                    G<=1'b0;
                    Y<=1'b0;
              	end
            end
            3'd6:
	    begin
                if(cycle == 13'd1023)
                begin
                    state<=3'd0;
		    cycle<=13'd0;
		    R<=1'b0;
                    G<=1'b1;
                    Y<=1'b0;
                end
            end
        endcase
        end
end

endmodule

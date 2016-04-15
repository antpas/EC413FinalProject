
// This can be used to replace the original nbit_register_file in lab6.
// In iSim you can actually expand this reg_file to view the contents in it. 

module nbit_register_file(write_data, 
                          read_data_1, read_data_2, 
                          read_sel_1, read_sel_2, 
                          write_address, RegWrite, WordPosition, clk);
                          
    parameter data_width = 32;
    parameter select_width = 5; 
                          
    input                                       clk, RegWrite;
	 input			  [1:0]								WordPosition;				
    input           [data_width-1:0]            write_data;
    input           [4:0]                       read_sel_1, read_sel_2, write_address;
    output		     [data_width-1:0]            read_data_1, read_data_2;
    
    reg             [data_width-1:0]            register_file [0:data_width-1];
    
    // for loop initializes all registers to 0, no need to rst
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin 
            register_file[i] = 32'd0;
        end     
    end
    

	 assign		read_data_1 = register_file[read_sel_1];
	 assign		read_data_2 = register_file[read_sel_2];

    
    always @ (negedge clk) begin
        if (RegWrite) 
		  begin
				if(WordPosition == 2'b1)
					register_file[write_address] <= {register_file[write_address][31:16], write_data[15:0]};
				else if(WordPosition == 2'b10)
					register_file[write_address] <= {write_data[15:0], register_file[write_address][15:0]};
				else
					register_file[write_address] <= write_data;
			end
    end
endmodule